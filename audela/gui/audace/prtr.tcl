#
# Fichier : prtr.tcl
# Description : Script dedie au menu deroulant pretraitement
# Auteur : Raymond ZACHANTKE
# Mise à jour $Id: prtr.tcl,v 1.3 2010-12-28 22:08:10 robertdelmas Exp $
#

namespace eval ::prtr {

   #--------------------------------------------------------------------------
   #  ::prtr::run nom_de_fonction
   #  Liste les operations proposees dans le menubutton de la fenetre
   #--------------------------------------------------------------------------
   proc run {oper} {
      variable private
      global audace

      #--   la variable ::prtr::script sert pour le deboggage (mettre a 1)
      set ::prtr::script 0

      set visuNo $audace(visuNo)
      set ::prtr::operation $oper
      set private(in_visu) ""
      set private(profil) ""

      ::prtr::changeDir $visuNo
      ::prtr::changeExtension $visuNo
      ::prtr::searchFunction $oper
      ::prtr::getTypeVar

      #--   surveille le changement de fonction
      trace add variable "::prtr::operation" write "::prtr::changeOp $visuNo"
      #--   surveille le changement de repertoire
      trace add variable "::audace(rep_images)" write "::prtr::updateTbl $audace(base).prtr.usr.choix $visuNo"
      #--   surveille le chargement d'une image
      trace add variable "::confVisu::private($visuNo,lastFileName)" write "::prtr::changeDir $visuNo"
      #--   surveille le dessin d'une boite de selection
      trace add variable "::confVisu::private($visuNo,boxSize)" write "::prtr::updateBox $visuNo"
      #--   surveille le changement d'extension
      trace add variable "::conf(extension,defaut)" write "::prtr::changeExtension $visuNo"
      #--   surveille le changement de compression
      trace add variable "::conf(fichier,compres)" write "::prtr::changeExtension $visuNo"

      #---
      set private(this) "$audace(base).prtr"
      ::prtr::initConf
      ::prtr::confToWidget
      if { [ winfo exists $private(this) ] } {
         wm withdraw $private(this)
         wm deiconify $private(this)
         focus $private(this)
      } else {
         if { [ info exists pretraitement(geometry) ] } {
            set deb [ expr 1 + [ string first + $pretraitement(geometry) ] ]
            set fin [ string length $pretraitement(geometry) ]
            set widget(pretraitement,position) "+[string range $pretraitement(geometry) $deb $fin]"
         }
         ::prtr::createDialog $visuNo
      }
   }

   #--------------------------------------------------------------------------
   #  ::prtr::createDialog
   #  Cree l'interface graphique si elle n'existe pas
   #--------------------------------------------------------------------------
   proc createDialog {visuNo} {
      variable private
      variable widget
      global audace caption color conf

      set This $private(this)
      #--   initialisation des variables
      set ::prtr::disp        "1"   ; # booleen, affichage de la derniere image
      set ::prtr::out         ""    ; # nom de sortie
      set ::prtr::ttoptions   "0"   ; # booleen, affichage des options
      set ::prtr::all         "0"   ; # booleen, sélection des images

      toplevel $This
      wm resizable $This 0 0
      wm deiconify $This
      set titre "$caption(audace,menu,[string tolower $private(ima)])"
      wm title $private(this) "$caption(audace,menu,images) - $titre"
      wm geometry $This $widget(prtr,position)
      wm transient $This $audace(base)
      wm protocol $This WM_DELETE_WINDOW "::prtr::cmdClose $visuNo"

      frame $This.usr -borderwidth 0 -relief raised

      set this [::blt::table $This.usr]
      set private(table) $this

      #--   cree 8 frames permamnents
      foreach fr {select scroll all sortie affiche edit info cmd} {
         frame $this.$fr -borderwidth 1 -relief raised
      }

      ::prtr::configMenuButton

      set tbl $this.choix
      #--- definit la structure et les caracteristiques
      ::tablelist::tablelist $tbl \
         -height 9 -width 60 -borderwidth 2 \
         -columns [list 0 "" center \
            0 $caption(prtr,src) left \
            0 $caption(prtr,type) center \
            0 $caption(prtr,dimension) center] \
         -xscrollcommand [list $this.hscroll set] \
         -yscrollcommand [list $this.vscroll set] \
         -editendcommand {::prtr::applyValue} \
         -exportselection 0 -setfocus 1 \
         -activestyle none -stretch all
      scrollbar $this.hscroll -orient horizontal -command [list $tbl xview]
      scrollbar $this.vscroll -command [list $tbl yview]
      pack $tbl -side top

      #---  le check bouton pour selectionner tout
      checkbutton $this.all.select -variable ::prtr::all \
         -text "$caption(prtr,select_all)" -command "::prtr::selectAll $tbl"
      pack $this.all.select -side left -padx 10 -pady 5

      #---  frame pour le fichier de sortie
      LabelEntry $this.sortie.out \
         -label "$caption(prtr,image_sortie)" -labelanchor w \
         -labelwidth [string length "$caption(prtr,image_sortie)"]\
         -textvariable ::prtr::out -padx 10 -justify center
      pack $this.sortie.out -side left -padx 5 -pady 5 -fill x -expand 1

      button $this.sortie.explore -text "$caption(prtr,parcourir)" -width 1 \
         -command "::prtr::parcourir \"$this.sortie\" out"
      pack $this.sortie.explore -side left -pady 5 -ipady 5 \
         -padx [$private(table).vscroll cget -width] -pady 5 -ipady 5

      #---  le check bouton pour la compression
      checkbutton $this.affiche.compress -variable ::prtr::compress \
         -text "$caption(prtr,compress)"
      pack $this.affiche.compress -side left -padx 10 -pady 5

      #---  le check bouton pour l'affichage
      checkbutton $this.affiche.disp -variable ::prtr::disp \
         -text "$caption(prtr,afficher_image_fin)"
      pack $this.affiche.disp -side left -padx 10 -pady 5

      #---  le check bouton pour l'edition du script
      checkbutton $this.edit.script -variable ::prtr::script \
         -text "$caption(prtr,afficher_script)"
      #pack $this.edit.script -side left -padx 10 -pady 5

      #---  frame pour l'affichage du deroulement du traitement
      label $this.info.labURL1 -textvariable ::prtr::avancement -fg $color(blue)
      pack $this.info.labURL1 -side top -padx 10 -pady 5

      #---  les commandes habituelles
      button $this.cmd.ok -text "$caption(prtr,ok)" \
         -width 7 -command "::prtr::cmdOk $tbl $visuNo"
      if {$conf(ok+appliquer) eq 1} {
         pack $this.cmd.ok -side left -padx 3 -pady 3 -ipady 5
      }
      button $this.cmd.appliquer -text "$caption(prtr,appliquer)" \
         -width 8 -command "::prtr::cmdApply $tbl $visuNo"
      pack $this.cmd.appliquer -side left -padx 3 -pady 3 -ipady 5

      button $this.cmd.fermer -text "$caption(prtr,fermer)" \
         -width 7 -command "::prtr::cmdClose $visuNo"
      pack $this.cmd.fermer -side right -padx 3 -pady 3 -ipady 5
      button $this.cmd.aide -text "$caption(prtr,hlp_function)" \
         -width 7 -command "::prtr::afficheAide"
      pack $this.cmd.aide -side right -padx 3 -pady 3
      button $this.cmd.hlp -text "$caption(prtr,hlp_gene)" -width 8 \
         -command "::audace::showHelpItem \"$::audace(rep_doc_html)/french/05pretraitement\" \"1240prtr.htm\""
      pack $this.cmd.hlp -side right -padx 3 -pady 3

      #--- positionne les elements dans la table
      ::blt::table  $this \
         $this.select 0,0 -fill x -cspan 2 \
         $this.choix 1,0 -fill both \
         $this.vscroll 1,1 -fill y -anchor e -width $this.vscroll \
         $this.hscroll 2,0 -fill x -height $this.hscroll \
         $this.all 3,0 -fill x -cspan 2 \
         $this.sortie 6,0 -fill x -cspan 2 \
         $this.affiche 7,0 -fill x -cspan 2 \
         $this.edit 8,0 -fill x -cspan 2 \
         $this.info 9,0 -fill x -cspan 2 \
         $this.cmd 10,0 -fill x -cspan 2
      pack $This.usr -in $This -side top -fill both -expand 1

      #--   remplit la tablelist
      ::prtr::updateTbl $tbl $visuNo

      #--- selectionne le traitement
      set i [lsearch -exact $private(fonctions) $::prtr::operation]
      incr i
      $this.select.but.menu invoke $i

      bind $This <Key-Return> [list ::prtr::cmdOk $tbl $visuNo]
      bind $This <Key-Escape> [list ::prtr::cmdClose $visuNo]
      bind $This <Key-F1> {::console::GiveFocus}

      #--- Focus
      focus $This

      #--- Mise a jour dynamique des couleurs
      ::confColor::applyColor $This
   }

   #--------------------------------------------------------------------------
   #  ::prtr::configMenuButton
   #  Construit la zone du menubutton et gere le nom de la fenetre
   #  Lancee par ::prtr::createDialog et par ::prtr::changeOp
   #--------------------------------------------------------------------------
   proc configMenuButton {} {
      variable private
      global caption

      set this $private(table).select

      #--   actualise le titre de la fenetre
      set titre "$::caption(audace,menu,[string tolower $private(ima)])"

      if { $titre == $::caption(audace,menu,amel) } {
         wm title $private(this) "$::caption(audace,menu,images) - $titre"
      } elseif { $titre == $::caption(audace,menu,extract) } {
         wm title $private(this) "$::caption(audace,menu,analysis) - $titre"
      } else {
         wm title $private(this) "$::caption(audace,menu,images) - $titre"
      }

      #--   detruit la zone de commande
      if {[winfo exists $this]} {
         destroy $this.lbl
         destroy $this.but
      }

      #--- cherche la longueur maximale du libelle des formules
      #--- pour dimensionner la largeur du menuboutton
      set bwidth "0"
      foreach formule $private(fonctions) {
         set bwidth [expr {max([ string length $formule ],$bwidth)}]
      }

      if {$private(ima) eq "SERIES"} {
         set texte "$::caption(prtr,operation_disk)"
      } else {
         set texte "$::caption(prtr,operation_lot)"
      }
      label $this.lbl -text $texte

      #--- bouton de menu
      menubutton $this.but -relief raised -width $bwidth -borderwidth 2 \
         -textvariable ::prtr::operation -menu $this.but.menu

      #--- menu du bouton
      set m [menu $this.but.menu -tearoff "1"]
      foreach form $private(fonctions) {
         $m add radiobutton -label "$form" -value "$form" \
            -variable ::prtr::operation
      }
      pack $this.lbl -side left -padx 10 -pady 10
      pack $this.but -side right -padx 10 -pady 10
   }


   #--------------------------------------------------------------------------
   #  ::prtr::changeOp visuNo
   #  Au lancement d'une fonction, extrait le nom de la fonction TT, la liste
   #  des parametres obligatoires et optionnels, les coordonnees de la doc,
   #  Lancee par trace variable ::prtr::operation
   #--------------------------------------------------------------------------
   proc changeOp {visuNo args} {
      variable private

      if {![info exists private(fonctions)]} {
         ::prtr::run $::prtr::operation
      } elseif {$::prtr::operation ni $private(fonctions)} {
         #--   cherche le nouveau dictionnaire
         ::prtr::searchFunction $::prtr::operation
         #--   configure la zone de commande
         ::prtr::configMenuButton
      }

      #--   detruit les zones, les widgets et les variables
      foreach frame {funoptions ttoptions} liste {obligatoire optionnel} {
         set w $private(table).$frame
         if {![winfo exists $w]} {
            continue
         } else {
            destroy $w
            foreach v $private($liste) {unset ::prtr::$v}
            unset private($liste)
         }
      }

      #--   charge les nouvelles info
      lassign [${private(ima)}Functions "$::prtr::operation"] private(function) \
         private(l_obligatoire) private(l_optionnel) private(aide)

      ::prtr::configOutName

      #--   actualise le checkbutton "Comprimer les images"
      set ::prtr::compress $::conf(fichier,compres)

      #--   cree et initialise les variables lies aux parametres
      foreach liste {obligatoire optionnel} child {funoptions ttoptions} {
         set content [set private(l_$liste)]
         if {$content ne ""} {
            foreach {var init} $content {set ::prtr::$var $init}
            set l [llength $content]
            set private($liste) ""
            for {set i 0} {$i < $l} {incr i 2} {
               lappend private($liste) [lindex $content $i]
            }
            ::prtr::buildParam_$liste $private(table).$child $visuNo
         }
      }
   }

   #--------------------------------------------------------------------------
   #  ::prtr::buildParam_obligatoire
   #  Configure la zone des parametres obligatoires
   #--------------------------------------------------------------------------
   proc buildParam_obligatoire {w visuNo} {
      variable private

      set obligatoire $private(obligatoire)
      set l [llength $obligatoire]
      set lignes [expr {$l/2+int(fmod($l,2))}]

      frame $w -borderwidth 1 -relief raised
      #--   la case du titre
      label $w.label  -text "$::caption(prtr,param)"
      grid $w.label -row 0 -column 0 -padx 10 -pady 5 -rowspan $lignes
      ::blt::table $private(table) $w 4,0 -fill x -cspan 2

      ::prtr::configZone $w obligatoire

      #--   modifie les variables initiales
      if {$private(in_visu) ne ""} {
         if {"x0" in $obligatoire || "xcenter" in $obligatoire} {
            ::prtr::getCenterCoord
         }

         if {"x2" in $obligatoire && "y2" in $obligatoire} {
            if {[ ::confVisu::getBox $visuNo ] ne ""} {
               #--   affiche les coordonnees de la box
               ::prtr::updateBox $visuNo
            }
         }
      }
   }

   #--------------------------------------------------------------------------
   #  ::prtr::buildParam_optionnel
   #  Configure la zone des options
   #--------------------------------------------------------------------------
   proc buildParam_optionnel {w visuNo} {
      variable private

      if {![winfo exists $w]} {
         #--   premire construction
         set l [llength $private(optionnel)]
         set lignes [expr {$l/2+int(fmod($l,2))}]
         frame $w -borderwidth 1 -relief raised
         checkbutton $w.che -indicatoron 1 -offvalue 0 -onvalue 1 \
            -variable ::prtr::ttoptions -text "$::caption(prtr,options)" \
            -command "::prtr::dispOptions $w"
         grid $w.che -row 0 -column 0 -padx 10 -pady 5 -rowspan $lignes
         ::blt::table $private(table) $w 5,0 -fill x -cspan 2
      }
      dispOptions $w
   }

   #--------------------------------------------------------------------------
   #  ::prtr::configZone
   #  Selectionne le widget a appliquer a une variable
   #  Parametres : nom du parent, nom de la liste (obligatoire ou optionnel)
   #--------------------------------------------------------------------------
   proc configZone {w liste} {
      variable private
      variable Var

      lassign [list 2 0 1] nb_max row col
      foreach child $private($liste) {
         set labelwidth [string length $child]
         set d "3"
         if {[expr {fmod($col,2)}] == "0"} {set d "20"}
         switch [lindex [dict get $Var $child] end] {
            "checkbutton"  {
               checkbutton $w.$child -text "$child" \
                  -variable ::prtr::$child -width $labelwidth
               grid $w.$child -row $row -column $col -padx $d -pady 5 -sticky e
               namespace upvar ::prtr $child value
               if {$value eq 1} {set state disabled} else {set state normal}
               $w.$child configure -state
               if {$child eq "opt_black"} {incr col}
            }
            "labelentry"   {
               set valuewidth [expr {[string length [set ::prtr::$child]]+4}]
               if {$valuewidth < "6"} {set valuewidth 6}
               LabelEntry $w.$child -label "$child" -labelanchor e\
                  -labelwidth $labelwidth -textvariable ::prtr::$child \
                  -padx 3 -width $valuewidth -justify center
               grid $w.$child -row $row -column $col -padx $d -pady 5 -sticky e
               if {$child in {file bias dark flat}} {
                  $w.$child configure -width 30
                  incr col
                  button $w.explore_$child -text "$::caption(prtr,parcourir)" -width 1 \
                     -command "::prtr::parcourir $w $child"
                  grid $w.explore_$child -row $row -column $col -padx 3 -pady 5 -sticky w
               }
            }
            "radiobutton" {
               #--   reserve a offset
               if {![winfo exists $w.methode]} {
                  frame $w.methode
                  label $w.methode.label -text "$::caption(prtr,methode)"
                  pack $w.methode.label -side left
                  foreach radio {somme moyenne mediane} function {ADD MEAN MED} {
                     radiobutton $w.methode.$radio -text "$::caption(audace,menu,$radio)" \
                        -indicatoron 1 -variable ::prtr::methode -value $function
                     pack $w.methode.$radio -side left
                  }
                  grid $w.methode -row $row -column $col -columnspan 2 -padx $d -pady 5 -sticky e
               }
               incr col "1"
            }
            "combobox"     {
               #--   reserve a bitpix
               frame $w.combo
               label $w.combo.lbl_$child -text "$child" -width $labelwidth
               ComboBox $w.combo.$child -textvariable ::prtr::$child -relief sunken \
                  -width 4 -height 7 -values [list 8 16 +16 32 +32 -32 -64]
               pack $w.combo.lbl_$child $w.combo.$child -side left
               grid $w.combo -row $row -column $col -padx $d -pady 5 -sticky e
               #--   retablit la valeur par defaut de bitpix
               ::prtr::confBitPix
               set k [lsearch [$w.combo.$child cget -values] $::prtr::bitpix]
               $w.combo.$child setvalue @$k
            }
         }
         incr col
         if {$col > $nb_max} {
            incr row
            set col "1"
         }
      }
      grid columnconfigure $w 1 -minsize 120
      grid columnconfigure $w 3 -minsize [$private(table).vscroll cget -width]
   }

   #--------------------------------------------------------------------------
   #  ::prtr::selectAll
   #  Selectionne/deselectionne tous les checkbuttons de la tablelist
   #  Commande du checkbutton "Sélectionner tout"
   #--------------------------------------------------------------------------
   proc selectAll {tbl} {
      variable private

      #--   arrete si fonction d'extraction ou aucune selection
      if {$::prtr::operation in [list $::caption(audace,menu,ligne) $::caption(audace,menu,colonne) \
            $::caption(audace,menu,matrice)] || $private(profil) eq ""} {
         return
      }

      set cmd "deselect"
      if {$::prtr::all == 1} {set cmd "select"}

      for {set row 0} {$row < $private(size)} {incr row} {
         #--   selectionne/deselectionne l'image de profil identique a celui de la premiere image
         if {[ string match $private(profil) [lrange [$tbl get $row] 2 end]]} {
            [$tbl windowpath $row,0] $cmd
         }
      }
      ::prtr::selectFiles $tbl $row
   }

   #--------------------------------------------------------------------------
   #  ::prtr::dispOptions
   #  Commande du checkbutton pour afficher les options
   #--------------------------------------------------------------------------
   proc dispOptions {w} {

      if {$::prtr::ttoptions == "1"} {
         ::prtr::configZone $w optionnel
      } else {
         set children [lreplace [winfo children "$w"] 0 0]
         destroy {*}$children
      }
   }

   #--------------------------------------------------------------------------
   #  ::prtr::selectFiles table row
   #  Rafraichit la liste des fichiers selectionnes
   #  Lancee lors de la construction de la fenetre et
   #  par la selection d'une image dans la table
   #--------------------------------------------------------------------------
   proc selectFiles {tbl row} {
      variable bd
      variable private
      global caption

      #--   arrete si le repertoire est vide
      if {[$tbl cellcget 0,1 -text] eq "$caption(prtr,no_file)" } {return}

      #--   recommence la liste
      set private(todo) ""

      #--   cree un profil referent avec la premiere image selectionnee
      if {$private(profil) eq "" && [set ::prtr::private(file_$row)]} {
         set private(profil) [lrange [$tbl get $row] 2 end]
         $tbl seecell $row,0
      }

      if {$private(profil) ne ""} {
         set  function_type 0
         set  filtre [list $caption(audace,menu,ligne) $caption(audace,menu,colonne) \
            $caption(audace,menu,matrice)]
         if {$::prtr::operation in $filtre} {
            set function_type 1
         }
         for {set row 0} {$row < $private(size)} {incr row} {
            set w [$tbl windowpath $row,0]
            set select_state [set ::prtr::private(file_$row)]
            if {$function_type == 1} {
               if {$select_state eq "0"} {
                  $w configure -state disabled
               } else {
                  lappend private(todo) [$tbl cellcget $row,1 -text]
               }
            } else {
               if {![ string match $private(profil) [lrange [$tbl get $row] 2 end]]} {
                  $w configure -state disabled
               } elseif {$select_state eq "1"} {
                  lappend private(todo) [$tbl cellcget $row,1 -text]
               }
            }
         }
      }

      #--   autorise toutes les selections si la liste est vide
      if {$private(todo) eq ""} {
         for {set row 0} {$row < $private(size)} {incr row} {
            [$tbl windowpath $row,0] configure -state normal
         }
         #--   detruit le profil s'il existe
         set private(profil) ""
         #--   retablit la valeur par defaut de bitpix
         ::prtr::confBitPix
      } else {
         #--   cherche la valeur de bitpix
         set info [lindex [array get bd [lindex $private(todo) 0]] 1]
         set ::prtr::bitpix [lindex [lindex $info 4]]
      }

      if {$::prtr::ttoptions eq 1} {
         #--   affiche la bonne valeur de bitpix
         set k [lsearch [$private(table).ttoptions.combo.bitpix cget -values] $::prtr::bitpix]
         $private(table).ttoptions.combo.bitpix setvalue @$k
      }
      ::prtr::displayAvancement "3"
   }

   #--------------------------------------------------------------------------
   #  ::prtr::confBitPix
   #  Fixe la valeur de bitpix identique a celle du reglage
   #  Utilisee par ::prtr::configZone et ::prtr::selectFiles
   #--------------------------------------------------------------------------
   proc confBitPix {} {

      set ::prtr::bitpix "+16"
      if {$::conf(format_fichier_image) eq "1"} {
         set ::prtr::bitpix "-32"
      }
   }

   #--------------------------------------------------------------------------
   #  ::prtr::updateTbl
   #  Rafraichit la tablelist
   #  Lancee lors de la construction de la fenetre, apres execution d'une commande
   #  et au changement de repertoire images
   #--------------------------------------------------------------------------
   proc updateTbl {w visuNo args} {
      variable private
      variable bd

      set dir $::audace(rep_images)
      #if {![info exists ::prtr::ext]} {::prtr::changeExtension $visuNo}
      set ::prtr::ext "$::conf(extension,defaut)"
      #--   rajoute l'extension de compression
      if {$::conf(fichier,compres) eq "1"} {append ::prtr::ext ".gz"}
      array unset bd

      #--   liste les images dans le repertoire
      if { $::tcl_platform(platform) eq "windows" } {
         set pattern "\{$::prtr::ext\}"
      } else {
         set pattern "\{[string tolower $::prtr::ext] [string toupper $::prtr::ext]\}"
         regsub -all " " $pattern "," pattern
      }
      regsub -all " " $pattern "," pattern
      set files [glob -nocomplain -type f -tails -dir $dir *$pattern]

      #--   efface tout
      $w delete 0 end

      #--      arrete si le repertoire est vide
      if {$files eq ""} {
         set private(size) "0"
         ::prtr::configTableState $w normal
         return
      }

      #--   construit la bdd
      foreach file $files {
         set result [::prtr::analyseFitsHeader [file join $dir $file]]
         if {$result ne ""} {
            regsub "$::prtr::ext" [file tail $file] "" nom_court
            array set bd [list $nom_court $result]
         }
      }

      #--   rafraichit la tablelist
      set list_files [lsort -dictionary [ array names bd]]
      set private(size) [array size bd]

      #--   arrete si la bd est vide et que le répertoire n'est pas vide
      ::prtr::configTableState $w normal
      if {$private(size) == "0"} {return}

      set nb 0
      for {set i 0} {$i < $private(size)} {incr i} {
         set cible [lindex $list_files $i]
         foreach {naxis naxis3 naxis1 naxis2} [lindex [array get bd $cible] 1] {break}
         if {$naxis eq 2} {set type "M"} else {set type "C"}
         if {$type eq "M" || ($type eq "C" && $private(ima) ni {MAITRE PRETRAITEE})} {
            incr nb
            $w insert end [list "" "$cible" "$type" "${naxis1} X ${naxis2}"]
            #--- insere le checkbutton
            $w cellconfigure end,0 -window [list ::prtr::createCheckButton]
            set z [$w windowpath end,0]
            $z deselect
         }
      }
      set private(size) $nb
      if {$private(size) == "0"} {return}

      #--   coche l'image dans la visu si elle est dans le repertoire
      set w $private(table).choix
      if {[buf[visu$visuNo buf] imageready]} {
         #--   decompose le nom en dir nom_court
         lassign [::prtr::getInfoFile [::confVisu::getFileName $visuNo]] dir nom_court
         if {$dir eq "$::audace(rep_images)"} {
            set private(in_visu) $nom_court
            set k [lsearch [$w  getcolumns 1] $private(in_visu)]
            if {$k ne "-1"} {
               [$w windowpath $k,0] invoke
            }
         }
      }
   }

   #--------------------------------------------------------------------------
   #  ::prtr::analyseFitsHeader $file (nom complet)
   #  Retourne les caractéristiques d'une image ou rien (si erreur)
   #--------------------------------------------------------------------------
   proc analyseFitsHeader {file} {

      set result ""
      if {![catch {set kwds_list [fitsheader $file]}]} {
         #--- cree un array des kwds
         #--- detecte les erreurs dans les mots-cles
         set error "0"
         foreach kwd $kwds_list {
            set err1 [ catch { set nom [lindex $kwd 0] } ::errorInfo]
            set err2 [ catch { set valeur [lindex $kwd 1] } ::errorInfo]
            if { $err1 == "0" && $err2 == "0" } {
               array set kwds [ list $nom $valeur ]
            } else {
               set error "1"
            }
         }
         if { $error == "0" } {
            #--   affecte les valeurs aux variables
            foreach var {bitpix crpix1 crpix2 mean naxis naxis1 naxis2 naxis3} {
               set $var  [lindex [array get kwds [ string toupper $var]] 1]
            }
            array unset kwds
            if {$naxis eq "2" || $naxis eq "3"} {
               #--   si CRPIX1 et CRPIX2 indefinis, calcule le centre de l'image
               if {$crpix1 eq "" || $crpix2 eq ""} {
                  set crpix1 [expr {$naxis1/2}]
                  set crpix2 [expr {$naxis2/2}]
               }
               set result [list $naxis $naxis3 $naxis1 $naxis2 $bitpix $crpix1 $crpix2 mean]
            }
         }
      }
      if {$result eq ""} {
         ::console::affiche_erreur "$file $::caption(prtr,err_file_header) $::errorInfo\n\n"
      }
      return $result
   }

   #--------------------------------------------------------------------------
   #  ::prtr::configOutName
   #  Configure l'entree du nom de sortie
   #--------------------------------------------------------------------------
   proc configOutName {} {
      variable private

      set ::prtr::out ""
      if {$private(function) ni [list "PROFILE direction=x" "PROFILE direction=y" "MATRIX"]} {
         set state normal
      } else {
         #--   inhibe la saisie car nom de sortie==nom d'entree
         set state disabled
      }
      $private(table).sortie.out configure -state $state
   }

   #--------------------------------------------------------------------------
   #  ::prtr::configTableState
   #  Configure la fenetre
   #--------------------------------------------------------------------------
   proc configTableState { w  etat } {
      variable private

      #--   modifie inconditionnellement la variable etat si la liste est vide
      if {$private(size) == "0"} {
         $w insert end [list "" "$::caption(prtr,no_file)" " " " " ]
         set etat disabled
      }

      #--   inhibe/desinhibe tous les boutons critiques
      if {$::conf(ok+appliquer) eq 1} {
         $private(table).cmd.ok configure -state $etat
      }
      $private(table).cmd.appliquer configure -state $etat
   }

   #--------------------------------------------------------------------------
   #  ::prtr::getCenterCoord
   #  Affiche les coordonnees du centre
   #  Lancee lors de la construction de l'activation d'une fonction avec centre
   #--------------------------------------------------------------------------
   proc getCenterCoord {} {
      variable private
      variable bd

      #--   cherche les info dans bd
      set info [lindex [array get bd [lindex $private(todo) 0]] 1]
      #--   rem en absence de CRPIX les valeurs sont au centre de l'image
      set crpix1 [lindex $info 5]
      set crpix2 [lindex $info 6]

      #--   modifie les valeurs initiales
      foreach parametre $private(obligatoire) {
         switch $parametre {
            x0       {set ::prtr::x0       $crpix1   ; #-- REC2POL POL2REC}
            y0       {set ::prtr::y0       $crpix2   ; #-- REC2POL POL2REC}
            xcenter  {set ::prtr::xcenter  $crpix1   ; #-- RGRADIENT RADIAL}
            ycenter  {set ::prtr::ycenter  $crpix2   ; #-- RGRADIENT RADIAL}
            default  {}
         }
      }
   }

   #--------------------------------------------------------------------------
   #  ::prtr::updateBox
   #  Affiche les coordonnees de la box dans x1 y1 x2 y2
   #  Lancee lors de la construction, de l'activation de la fonction de recadrage
   #  ou lors du dessin/effacement d'une boite de selection
   #--------------------------------------------------------------------------
   proc updateBox {visuNo args} {
      variable private

      #--   arrete si pas fonction avec une box
      if {$private(function) ni {WINDOW MATRIX}} {return}

      set box  [::confVisu::getBox $visuNo]
      if {$box eq ""} {
         #--   les valeurs par defaut des fonctions a la box
         regsub -all {x1|y1|x2|y2} $private(l_obligatoire) "" box
      }
      foreach {::prtr::x1 ::prtr::y1 ::prtr::x2 ::prtr::y2} $box {break}
   }

   #--------------------------------------------------------------------------
   #  ::prtr::parcourir nom_de_variable
   #  Ouvre un explorateur pour choisir un fichier de sortie ou une image operande
   #  Produit ::prtr::nom_de_variable
   #--------------------------------------------------------------------------
   proc parcourir {w var} {
      variable private

      #--   ouvre la fenetre de choix des images
      set file [::tkutil::box_load $private(this) $::audace(rep_images) $::audace(bufNo) "1"]

      #--   arrete si pas de selection
      if {$file eq ""} {return}

      #--   decompose le nom en dir nom_court et extension(s)
      lassign [::prtr::getInfoFile $file] dir nom_court ext

      #--   verifie que l'extension est identique a celle des fichiers traites
      #if {$ext ne "$::prtr::ext"} {
      #   return [avertiUser err_file_ext "$::prtr:ext"]
      #}

      #--   affiche la valeur moyenne du flat dans la constante
      if {$var eq "flat"} {
         regexp {^(\.[a-zA-Z]{3,4})(\.gz)?} $ext ext_in ext_out compr
         ttscript2 "IMA/SERIES \"$dir\" $nom_court . . $ext_in \"$dir\" $nom_court . $ext_out STAT"
         set fileName [file join $dir $nom_court$ext_out]
         set ::prtr::constant [expr {int([lindex [analyseFitsHeader $fileName] 4])}]
         #--   supprime le fichier non zippe
         if {$compr ne ""} {file delete $fileName}
      }

      #--   remplace le nom du repertoire s'il est identique a celui d'entree
      if {$dir eq "$::audace(rep_images)"} {
         set dir "."
         set file [file join $dir $nom_court$::prtr::ext]
      }

      #--   fixe le nom du fichier
      set ::prtr::$var "$file"

      #--   montre la fin du nom du fichier
      switch $var {
         out      {$private(table).sortie.$var.e xview end}
         default  {$private(table).funoptions.$var.e xview end}
      }
   }

   #--------------------------------------------------------------------------
   #  ::prtr::changeExtension
   #  Trace les options d'extension
   #--------------------------------------------------------------------------
   proc changeExtension {visuNo args} {
      variable private

      set ::prtr::ext $::conf(extension,defaut)
      #--   actualise le checkbutton "Comprimer les images"
      set ::prtr::compress $::conf(fichier,compres)
      #--   rajoute l'extension de compression
      if {$::conf(fichier,compres) eq "1"} {
         append ::prtr::ext ".gz"
      }
      set private(profil) ""
      if {[info exists private(table)]} {
         updateTbl $private(table).choix $visuNo
      }
   }

   #--------------------------------------------------------------------------
   #  ::prtr::changeDir
   #  Change de repertoire
   #  Lancee par trace de "::confVisu::private($visuNo,lastFileName)"
   #--------------------------------------------------------------------------
   proc changeDir {visuNo args} {
      variable private

      if {[buf[visu$visuNo buf] imageready]} {
         #--   decompose le nom en dir nom_court et extension(s)
         set info [::prtr::getInfoFile [::confVisu::getFileName $visuNo]]
         set dir [lindex $info 0]
         if {$dir eq "$::audace(rep_images)"} {
            set private(in_visu) "[lindex $info 1]"
            set private(profil) ""
            if {[info exists private(table)]} {
               updateTbl $private(table).choix $visuNo
            }
         }
      }
   }

   #--------------------------------------------------------------------------
   #  ::prtr::cmdApply
   #  Procedure du bouton Appliquer
   #  Retourne 0 si la verification a echoue, 1 si la procedure a ete a son terme
   #--------------------------------------------------------------------------
   proc cmdApply { tbl visuNo } {
      variable private

      #--   arrete si une erreur ou un oubli
      set opt [::prtr::cmdVerif]
      if {$opt eq 0} {return 0}

      #--   inhibe toutes les zones sensibles
      ::prtr::windowActive $tbl disabled

      set dir "$::prtr::dir_out"
      set generique  "$::prtr::generique"
      set imgList "$private(todo)"
      set nbImg [llength $imgList]
      set data [list "$imgList" "$dir" "$generique" "$::prtr::ext"]

      #--   selectionne la fonction a activer
      switch -exact $private(function) {
         BIAS         {  set private(error) [faireOffset $data $opt]}
         DARK           {  lappend data $prtr::methode
                           set private(error) [faireDark $data $opt]}
         FLAT           {  set private(error) [faireFlat $data $opt]}
         PRETRAITEMENT  {  if {$::prtr::opt_black eq "1"} {
                              set private(error) [faireOptNoir $data $opt]
                           } else {
                              set private(error) [fairePretraitement $data $opt]
                           }
                        }
         CLIP           {  set private(error) [clipMinMax $data $opt]}
         default        {  switch $private(ima) PILE {set appl "IMA/STACK"} default {set appl "IMA/SERIES"}
                           set data [linsert $data 0 $appl]
                           lappend data "$private(function)"
                           set private(error) [::prtr::cmdExec $data $opt]
                        }
      }

      #--   post traitement
      if {$private(error) eq "0"} {

         set ext "$::conf(extension,defaut)"
         if {$dir eq "."} {set dir $::audace(rep_images)}
         if {$private(ima) in [list MAITRE PILE] || $nbImg eq "1"} {
            set lastImage [file join "$dir" $generique$ext]
            if {$::prtr::compress eq 1 } {
               ::prtr::compressFiles "$dir" "$generique" 1 "$ext"
               append lastImage ".gz"
            }
         } else {
            #--   cas d'images multiples
            set lastImage [file join "$dir" $generique$nbImg$ext]
            if {$::prtr::compress eq 1 } {
               ::prtr::compressFiles "$dir" "$generique" $nbImg "$ext"
               append lastImage ".gz"
            }
         }

         #--  charge la derniere image si demande
         if {$::prtr::disp eq 1} {::prtr::loadImg $lastImage}
      }

      #--   desinhibe les zones sensibles
      ::prtr::windowActive $tbl normal

      #--   rafraichit la tablelist avec les images produites
      ::prtr::updateTbl $tbl $visuNo

      return $private(error)
   }

   #--------------------------------------------------------------------------
   #  ::prtr::windowActive {normal|disabled}
   #  Active/desactive les zones sensibles de la fenetre
   #  Lancee par ::prtr::cmdApply
   #--------------------------------------------------------------------------
   proc windowActive {tbl etat} {
      variable private

      set this $private(table)

      #--   inhibe/desinhibe tous les checkbutton et le nom de sortie
      set children [list "all.select" "affiche.compress" "affiche.disp" "edit.script" "sortie.out"]
      foreach child $children {
         $this.$child configure -state $etat
      }

      #--   inhibe/desinhibe tous les boutons et l'entree du nom
      ::prtr::configTableState $this $etat

      #--- le bouton 'Appliquer' et le message
      if {$etat eq "disabled"} {
         ::prtr::displayAvancement "1"
         $this.cmd.appliquer configure -relief sunken
      } else {
         if {$private(error) ne "1"} {
            ::prtr::displayAvancement "2"
         } else {
            ::prtr::displayAvancement "0"
         }
         $this.cmd.appliquer configure -relief raised
      }

      #--   liste les widgets a inhiber/desinhiber
      if {$etat eq "disabled"} {
         set private(frames) ""
         foreach fr {funoptions ttoptions} {
            if {[winfo exists $this.$fr]} {
               set children [winfo children $this.$fr]
               if {"$this.$fr.combo" in $children} {
                  set k [lsearch $children "$this.$fr.combo"]
                  set children [lreplace $children $k $k "$this.$fr.combo.bitpix"]
               }
               if {"$this.$fr.methode" in $children} {
                  set k [lsearch $children "$this.$fr.methode"]
                  set children [lreplace $children $k $k]
                  set children [concat $children "$this.$fr.methode.somme" \
                     "$this.$fr.methode.moyenne" "$this.$fr.methode.mediane"]
               }
               set private(frames) [concat $private(frames) $children]
            }
         }
      }

      #--   inhibe/desinhibe tous les frames
      foreach frame $private(frames) {
         $frame configure -state $etat
      }

      #--- inhibe/desinhibe uniquement les checkbuttons selectionnables
      if {$etat eq "disabled"} {
         for {set row 0} {$row < $private(size)} {incr row} {
            set w [$tbl windowpath $row,0]
            if {[lindex [$w configure -state] end] eq "normal"} {
               #--   inhibe le checkbutton en etat normal
               $w configure -state $etat
            } else {
               #--   memorise le nom de l'image
               lappend private(disabled) "[$tbl windowpath $row,1]"
            }
         }
      } elseif {$etat eq "normal"} {
         #--   active uniquement la liste qui etait selectionnable
         for {set row 0} {$row < $private(size)} {incr row} {
            if {![info exists private(disabled)]} {
               set state $etat
            } else {
               if {[$tbl windowpath $row,1] ni $private(disabled)} {
                  set state normal
               } else {
                  set state disabled
               }
            }
            [$tbl windowpath $row,0] configure -state $etat
         }
         ::prtr::configOutName
      }
      update
   }

   #--------------------------------------------------------------------------
   #  ::prtr::compressFiles
   #  Compresse le ou les fichiers de sortie
   #--------------------------------------------------------------------------
   proc compressFiles {dir_out nom_out l ext_out} {

      set fileToCompres ""
      if {$l eq "1"} {
         lappend fileToCompress [file join $dir_out $nom_out$ext_out]
      } else {
         for {set i 1} {$i <=$l} {incr i} {
            lappend fileToCompress "[file join $dir_out $nom_out$i$ext_out]"
         }
      }
      #--   compresse tous les fichiers
      foreach file $fileToCompress {gzip $file}
   }

   #--------------------------------------------------------------------------
   #  ::prtr::loadImg $nom_complet
   #  Charge une image dans un buffer avec bitpix en accord
   #  avec la valeur par defaut ou avec la valeur demandee par l'utilisateur
   #  Lancee par cmdApply
   #--------------------------------------------------------------------------
   proc loadImg {name} {

      set visuNo $::audace(visuNo)
      set bufNo [visu$visuNo buf]
      set bitpix [::prtr::convertBitPix2BitPix $::prtr::bitpix]

      #--   convertit le reglage par defaut en valeur
      switch $::conf(format_fichier_image) {
         "0"   {set bitpix_defaut "ushort" }
         "1"   {set bitpix_defaut "float" }
      }

      #--   regle bitpix si different du reglage par defaut
      if {$bitpix ne "$bitpix_defaut"} {
         buf$bufNo bitpix $bitpix
      }

      #--   charge, affiche et nomme l'image
      buf$bufNo load $name
      ::confVisu::autovisu $visuNo
      ::confVisu::setFileName $visuNo $name
   }

   #--------------------------------------------------------------------------
   #  ::prtr::cmdOk
   #  Procedure du bouton OK
   #--------------------------------------------------------------------------
   proc cmdOk {tbl visuNo} {

      if {[::prtr::cmdApply $tbl $visuNo] eq "1"} {return}
      cmdClose $visuNo
   }

   #--------------------------------------------------------------------------
   #  ::prtr::cmdClose
   #  Procedure du bouton Fermer
   #--------------------------------------------------------------------------
   proc cmdClose {visuNo} {
      variable private
      variable bd

      trace remove variable "::prtr::operation" write "::prtr::changeOp $visuNo"
      trace remove variable "::audace(rep_images)" write "::prtr::updateTbl $private(table).choix $visuNo"
      trace remove variable "::confVisu::private($visuNo,boxSize)" write "::prtr::updateBox $visuNo"
      trace remove variable "::confVisu::private($visuNo,lastFileName)" write "::prtr::changeDir $visuNo"
      trace remove variable "::conf(extension,defaut)" write "::prtr::changeExtension $visuNo"
      trace remove variable "::conf(fichier,compres)" write "::prtr::changeExtension $visuNo"
      ::prtr::recupPosition
      destroy $private(this)
      array unset bd
      array unset private
      #array unset ::prtr::
   }

   #--------------------------------------------------------------------------
   #  ::prtr::displayAvancement
   #  Rafraichit l'affichage de la ligne d'info
   #--------------------------------------------------------------------------
   proc displayAvancement {c} {
      variable private

      switch $c {
         0  {  set ::prtr::avancement ""}
         1  {  set ::prtr::avancement $::caption(prtr,en_cours)}
         2  {  set ::prtr::avancement $::caption(prtr,fin_traitement)}
         3  {  set ::prtr::avancement \
                  "[format $::caption(prtr,nb_select) [llength $private(todo)] $private(size)]"
            }
      }
   }

   #--------------------------------------------------------------------------
   #  ::prtr::avertiUser
   #  Affiche une fenetre d'avertissement
   #--------------------------------------------------------------------------
   proc avertiUser {err args} {

      switch [llength $args] {
         0  {set msg "$::caption(prtr,$err)"}
         1  {set msg "[format $::caption(prtr,$err) $args]"}
         2  {set msg "[format $::caption(prtr,$err) [lindex $args 0] [lindex $args 1]]"}
      }
      tk_messageBox -title "$::caption(prtr,attention)" -type ok -message $msg
      return 0
   }

   #--------------------------------------------------------------------------
   #  ::prtr::Error
   #  Message d'erreur lie aux scripts TT
   #--------------------------------------------------------------------------
   proc Error {info} {

      tk_messageBox -title "$::caption(prtr,attention)" -icon error -message "$info"
   }

   #--------------------------------------------------------------------------
   #  ::prtr::afficheAide
   #  Selectionne l'aide associee a la fonction y compris avec l'item dans la page
   #  Procedure lancee par le bouton Aide
   #--------------------------------------------------------------------------
   proc afficheAide { } {
      variable private

      foreach {dir page item} $private(aide) {break}
      ::audace::showHelpItem $dir $page $item
   }

   #--------------------------------------------------------------------------
   #  ::prtr::createCheckButton tbl row col w
   #  Cree un checkbutton pour inserer dans une tablelist
   #  Parametres : tbl row col et w completes automatiquement
   #--------------------------------------------------------------------------
   proc createCheckButton {tbl row col w} {

      checkbutton $w -height 1 -indicatoron 1 -onvalue 1 -offvalue 0 \
         -variable ::prtr::private(file_$row) \
         -command [list ::prtr::selectFiles $tbl $row]
   }

   #--------------------------------------------------------------------------
   #  ::prtr::recupPosition
   #  Recupere la position de la fenetre
   #--------------------------------------------------------------------------
   proc recupPosition { } {
      variable private
      variable widget

      set private(geometry) [wm geometry $private(this)]
      set deb [expr {1 + [string first + $private(geometry)] }]
      set fin [string length $private(geometry)]
      set widget(prtr,position) "+[string range $private(geometry) $deb $fin]"
      widgetToConf
   }

   #-----------------------------------------------------------------------
   #  ::prtr::widgetToConf
   #  Charge les variables locales dans des variables de configuration
   #--------------------------------------------------------------------------
   proc widgetToConf { } {
      variable widget

      set ::conf(prtr,position) "$widget(prtr,position)"
   }

   #--------------------------------------------------------------------------
   #  ::prtr::initConf
   # Initialise les variables de configuration
   #--------------------------------------------------------------------------
   proc initConf { } {

      if {![info exists ::conf(prtr,position)]} {set ::conf(prtr,position) "+350+75"}
      return
   }

   #--------------------------------------------------------------------------
   #  ::prtr::confToWidget
   # Charge les variables de configuration dans des variables locales
   #--------------------------------------------------------------------------
   proc confToWidget { } {
      variable widget

     set widget(prtr,position) "$::conf(prtr,position)"
   }

      #--   chaque fonction est accompagnee de quatre variables (eventuellement vides) :
   #     -fun : nom de la fonction TT
   #     -hlp : nom du repertoire de la page, nom de la page et nom de l'ancre (si elle existe)
   #     -par : noms des parametres obligatoires alternant avec la valeur d'initialisation
   #     -opt : noms des parametres optionnels alternant avec la valeur d'initialisation

   #--------------------------------------------------------------------------
   #  ::prtr::PILEFunctions {0|nom_de_fonction}
   #  Cree le dictionnaire des fonctions IMA/STACK
   #  Retourne la liste des fonctions ou les parametres d'une fonction
   #--------------------------------------------------------------------------
   proc PILEFunctions {function} {
      variable STACK
      global caption help

      dict set STACK "$caption(audace,menu,somme)"                fun ADD
      dict set STACK "$caption(audace,menu,somme)"                hlp "$help(dir,prog) ttus1-fr.htm stackADD"
      dict set STACK "$caption(audace,menu,somme)"                par ""
      dict set STACK "$caption(audace,menu,somme)"                opt "bitpix 16 skylevel 0 nullpixel 0 jpegfile 0 jpeg_quality 75"
      dict set STACK "$caption(audace,menu,moyenne)"              fun MEAN
      dict set STACK "$caption(audace,menu,moyenne)"              hlp "$help(dir,prog) ttus1-fr.htm MEAN"
      dict set STACK "$caption(audace,menu,moyenne)"              par ""
      dict set STACK "$caption(audace,menu,moyenne)"              opt "bitpix 16 skylevel 0 nullpixel 0 jpegfile 0 jpeg_quality 75"
      dict set STACK "$caption(audace,menu,mediane)"              fun MED
      dict set STACK "$caption(audace,menu,mediane)"              hlp "$help(dir,prog) ttus1-fr.htm MED"
      dict set STACK "$caption(audace,menu,mediane)"              par ""
      dict set STACK "$caption(audace,menu,mediane)"              opt "bitpix 16 skylevel 0 nullpixel 0 jpegfile 0 jpeg_quality 75"
      dict set STACK "$caption(audace,menu,produit)"              fun PROD
      dict set STACK "$caption(audace,menu,produit)"              hlp "$help(dir,prog) ttus1-fr.htm stackPROD"
      dict set STACK "$caption(audace,menu,produit)"              par ""
      dict set STACK "$caption(audace,menu,produit)"              opt "powernorm 0 bitpix 16 skylevel 0 nullpixel 0 jpegfile 0 jpeg_quality 75"
      dict set STACK "$caption(audace,menu,racine_carree)"        fun PYTHAGORE
      dict set STACK "$caption(audace,menu,racine_carree)"        hlp "$help(dir,prog) ttus1-fr.htm PYTHAGORE"
      dict set STACK "$caption(audace,menu,racine_carree)"        par ""
      dict set STACK "$caption(audace,menu,racine_carree)"        opt "bitpix 16 skylevel 0 nullpixel 0 jpegfile 0 jpeg_quality 75"
      dict set STACK "$caption(audace,menu,ecart_type)"           fun SIG
      dict set STACK "$caption(audace,menu,ecart_type)"           hlp "$help(dir,prog) ttus1-fr.htm SIG"
      dict set STACK "$caption(audace,menu,ecart_type)"           par ""
      dict set STACK "$caption(audace,menu,ecart_type)"           opt "bitpix 16 skylevel 0 nullpixel 0 jpegfile 0 jpeg_quality 75"
      dict set STACK "$caption(audace,menu,moyenne_k)"            fun SK
      dict set STACK "$caption(audace,menu,moyenne_k)"            hlp "$help(dir,prog) ttus1-fr.htm SK"
      dict set STACK "$caption(audace,menu,moyenne_k)"            par ""
      dict set STACK "$caption(audace,menu,moyenne_k)"            opt "kappa 3. bitpix 16 skylevel 0 nullpixel 0 jpegfile 0 jpeg_quality 75"
      dict set STACK "$caption(audace,menu,moyenne_tri)"          fun SORT
      dict set STACK "$caption(audace,menu,moyenne_tri)"          hlp "$help(dir,prog) ttus1-fr.htm SORT"
      dict set STACK "$caption(audace,menu,moyenne_tri)"          par ""
      dict set STACK "$caption(audace,menu,moyenne_tri)"          opt "percent 50 bitpix 16 skylevel 0 nullpixel 0 jpegfile 0 jpeg_quality 75"
      dict set STACK "$caption(audace,menu,obturateur)"           fun SHUTTER
      dict set STACK "$caption(audace,menu,obturateur)"           hlp "$help(dir,prog) ttus1-fr.htm SHUTTER"
      dict set STACK "$caption(audace,menu,obturateur)"           par ""
      dict set STACK "$caption(audace,menu,obturateur)"           opt "bitpix 16 skylevel 0 nullpixel 0 jpegfile 0 jpeg_quality 75"

      return [::prtr::consultDic STACK $function]
   }

   #--------------------------------------------------------------------------
   #  ::prtr::TRANSFORMFunctions {0|nom_de_fonction}
   #  Cree le dictionnaire des fonctions IMA/SERIES qui modifient la geometrie
   #  Retourne la liste des fonctions ou les parametres d'une fonction
   #--------------------------------------------------------------------------
   proc TRANSFORMFunctions {function} {
      variable SERIES
      global caption help

      dict set SERIES "$caption(audace,menu,miroir_x)"            fun "INVERT mirror"
      dict set SERIES "$caption(audace,menu,miroir_x)"            hlp "$help(dir,prog) ttus1-fr.htm INVERT"
      dict set SERIES "$caption(audace,menu,miroir_x)"            par ""
      dict set SERIES "$caption(audace,menu,miroir_x)"            opt "bitpix 16 skylevel 0 nullpixel 0 jpegfile 0 jpeg_quality 75"
      dict set SERIES "$caption(audace,menu,miroir_y)"            fun "INVERT flip"
      dict set SERIES "$caption(audace,menu,miroir_y)"            hlp "$help(dir,prog) ttus1-fr.htm INVERT"
      dict set SERIES "$caption(audace,menu,miroir_y)"            par ""
      dict set SERIES "$caption(audace,menu,miroir_y)"            opt "bitpix 16 skylevel 0 nullpixel 0 jpegfile 0 jpeg_quality 75"
      dict set SERIES "$caption(audace,menu,miroir_xy)"           fun "INVERT xy"
      dict set SERIES "$caption(audace,menu,miroir_xy)"           hlp "$help(dir,prog) ttus1-fr.htm INVERT"
      dict set SERIES "$caption(audace,menu,miroir_xy)"           par ""
      dict set SERIES "$caption(audace,menu,miroir_xy)"           opt "bitpix 16 skylevel 0 nullpixel 0 jpegfile 0 jpeg_quality 75"
      dict set SERIES "$caption(audace,menu,window1)"             fun WINDOW
      dict set SERIES "$caption(audace,menu,window1)"             hlp "$help(dir,prog) ttus1-fr.htm WINDOW"
      dict set SERIES "$caption(audace,menu,window1)"             par "x1 1 y1 1 x2 2 y2 2"
      dict set SERIES "$caption(audace,menu,window1)"             opt "bitpix 16 skylevel 0 nullpixel 0 jpegfile 0 jpeg_quality 75"
      dict set SERIES "$caption(audace,menu,scale)"               fun RESAMPLE
      dict set SERIES "$caption(audace,menu,scale)"               hlp "$help(dir,prog) ttus1-fr.htm RESAMPLE"
      dict set SERIES "$caption(audace,menu,scale)"               par "paramresample \"1.  0  0  0  1.  0\""
      dict set SERIES "$caption(audace,menu,scale)"               opt "normaflux 0 bitpix 16 skylevel 0 nullpixel 0 jpegfile 0 jpeg_quality 75"
      dict set SERIES "$caption(audace,menu,translate)"           fun TRANS
      dict set SERIES "$caption(audace,menu,translate)"           hlp "$help(dir,prog) ttus1-fr.htm TRANS"
      dict set SERIES "$caption(audace,menu,translate)"           par "trans_x 1. trans_y 1."
      dict set SERIES "$caption(audace,menu,translate)"           opt "bitpix 16 skylevel 0 nullpixel 0 jpegfile 0 jpeg_quality 75"
      dict set SERIES "$caption(audace,menu,bin_x)"               fun BINX
      dict set SERIES "$caption(audace,menu,bin_x)"               hlp "$help(dir,prog) ttus1-fr.htm BINX"
      dict set SERIES "$caption(audace,menu,bin_x)"               par "x1 1 x2 2 width 20"
      dict set SERIES "$caption(audace,menu,bin_x)"               opt "bitpix 16 skylevel 0 nullpixel 0 jpegfile 0 jpeg_quality 75"
      dict set SERIES "$caption(audace,menu,med_x)"               fun "MEDIANX"
      dict set SERIES "$caption(audace,menu,med_x)"               hlp "$help(dir,prog) ttus1-fr.htm MEDIANX"
      dict set SERIES "$caption(audace,menu,med_x)"               par "x1 1 x2 2 width 20"
      dict set SERIES "$caption(audace,menu,med_x)"               opt "bitpix 16 skylevel 0 nullpixel 0 jpegfile 0 jpeg_quality 75"
      dict set SERIES "$caption(audace,menu,sort_x)"              fun "SORTX"
      dict set SERIES "$caption(audace,menu,sort_x)"              hlp "$help(dir,prog) ttus1-fr.htm SORTX"
      dict set SERIES "$caption(audace,menu,sort_x)"              par "x1 1 x2 2 width 20 percent 50"
      dict set SERIES "$caption(audace,menu,sort_x)"              opt "bitpix 16 skylevel 0 nullpixel 0 jpegfile 0 jpeg_quality 75"
      dict set SERIES "$caption(audace,menu,bin_y)"               fun BINY
      dict set SERIES "$caption(audace,menu,bin_y)"               hlp "$help(dir,prog) ttus1-fr.htm BINY"
      dict set SERIES "$caption(audace,menu,bin_y)"               par "y1 1 y2 2 height 20"
      dict set SERIES "$caption(audace,menu,bin_y)"               opt "bitpix 16 skylevel 0 nullpixel 0 jpegfile 0 jpeg_quality 75"
      dict set SERIES "$caption(audace,menu,med_y)"               fun "MEDIANY"
      dict set SERIES "$caption(audace,menu,med_y)"               hlp "$help(dir,prog) ttus1-fr.htm MEDIANY"
      dict set SERIES "$caption(audace,menu,med_y)"               par "y1 1 y2 2 height 20"
      dict set SERIES "$caption(audace,menu,med_y)"               opt "bitpix 16 skylevel 0 nullpixel 0 jpegfile 0 jpeg_quality 75"
      dict set SERIES "$caption(audace,menu,sort_y)"              fun "SORTY"
      dict set SERIES "$caption(audace,menu,sort_y)"              hlp "$help(dir,prog) ttus1-fr.htm SORTY"
      dict set SERIES "$caption(audace,menu,sort_y)"              par "y1 1 y2 2 height 20 percent 50"
      dict set SERIES "$caption(audace,menu,sort_y)"              opt "bitpix 16 skylevel 0 nullpixel 0 jpegfile 0 jpeg_quality 75"
      dict set SERIES "$caption(audace,menu,rotation1)"           fun ROT
      dict set SERIES "$caption(audace,menu,rotation1)"           hlp "$help(dir,prog) ttus1-fr.htm ROT"
      dict set SERIES "$caption(audace,menu,rotation1)"           par "x0 1. y0 1. angle 1."
      dict set SERIES "$caption(audace,menu,rotation1)"           opt "bitpix 16 skylevel 0 nullpixel 0 jpegfile 0 jpeg_quality 75"
      dict set SERIES "$caption(audace,menu,rotation2)"           fun ROTENTIERE
      dict set SERIES "$caption(audace,menu,rotation2)"           hlp "$help(dir,prog) ttus1-fr.htm ROTENTIERE"
      dict set SERIES "$caption(audace,menu,rotation2)"           par "x0 1. y0 1. angle 1."
      dict set SERIES "$caption(audace,menu,rotation2)"           opt "bitpix 16 skylevel 0 nullpixel 0 jpegfile 0 jpeg_quality 75"
      dict set SERIES "$caption(audace,menu,cart2pol)"            fun REC2POL
      dict set SERIES "$caption(audace,menu,cart2pol)"            hlp "$help(dir,prog) ttus1-fr.htm REC2POL"
      dict set SERIES "$caption(audace,menu,cart2pol)"            par "x0 1. y0 1. scale_theta 1. scale_rho 1."
      dict set SERIES "$caption(audace,menu,cart2pol)"            opt "bitpix 16 skylevel 0 nullpixel 0 jpegfile 0 jpeg_quality 75"
      dict set SERIES "$caption(audace,menu,pol2cart)"            fun POL2REC
      dict set SERIES "$caption(audace,menu,pol2cart)"            hlp "$help(dir,prog) ttus1-fr.htm POL2REC"
      dict set SERIES "$caption(audace,menu,pol2cart)"            par "x0 1.  y0 1. scale_theta 1. scale_rho 1. width 100 height 100"
      dict set SERIES "$caption(audace,menu,pol2cart)"            opt "bitpix 16 skylevel 0 nullpixel 0 jpegfile 0 jpeg_quality 75"

      return [::prtr::consultDic SERIES $function]
   }

   #--------------------------------------------------------------------------
   #  ::prtr::ARITHMFunctions {0|nom_de_fonction}
   #  Cree le dictionnaire des fonctions IMA/SERIES qui modifient les valeurs
   #  Retourne la liste des fonctions ou les parametres d'une fonction
   #--------------------------------------------------------------------------
    proc ARITHMFunctions {function} {
      variable SERIES
      global caption help

      dict set SERIES "$caption(audace,menu,addition)"            fun ADD
      dict set SERIES "$caption(audace,menu,addition)"            hlp "$help(dir,prog) ttus1-fr.htm seriesADD"
      dict set SERIES "$caption(audace,menu,addition)"            par "file img"
      dict set SERIES "$caption(audace,menu,addition)"            opt "offset 0 bitpix 16 skylevel 0 nullpixel 0 jpegfile 0 jpeg_quality 75"
      dict set SERIES "$caption(audace,menu,soust)"               fun SUB
      dict set SERIES "$caption(audace,menu,soust)"               hlp "$help(dir,prog) ttus1-fr.htm SUB"
      dict set SERIES "$caption(audace,menu,soust)"               par "file img"
      dict set SERIES "$caption(audace,menu,soust)"               opt "offset 0 bitpix 16 skylevel 0 nullpixel 0 jpegfile 0 jpeg_quality 75"
      dict set SERIES "$caption(audace,menu,division)"            fun DIV
      dict set SERIES "$caption(audace,menu,division)"            hlp "$help(dir,prog) ttus1-fr.htm DIV"
      dict set SERIES "$caption(audace,menu,division)"            par "file img"
      dict set SERIES "$caption(audace,menu,division)"            opt "constant 1. bitpix 16 skylevel 0 nullpixel 0 jpegfile 0 jpeg_quality 75"
      dict set SERIES "$caption(audace,menu,multipli)"            fun PROD
      dict set SERIES "$caption(audace,menu,multipli)"            hlp "$help(dir,prog) ttus1-fr.htm seriesPROD"
      dict set SERIES "$caption(audace,menu,multipli)"            par "file img"
      dict set SERIES "$caption(audace,menu,multipli)"            opt "constant 1. bitpix 16 skylevel 0 nullpixel 0 jpegfile 0 jpeg_quality 75"
      dict set SERIES "$caption(audace,menu,offset)"              fun OFFSET
      dict set SERIES "$caption(audace,menu,offset)"              hlp "$help(dir,prog) ttus1-fr.htm OFFSET"
      dict set SERIES "$caption(audace,menu,offset)"              par "offset 0"
      dict set SERIES "$caption(audace,menu,offset)"              opt "bitpix 16 skylevel 0 nullpixel 0 jpegfile 0 jpeg_quality 75"
      dict set SERIES "$caption(audace,menu,mult_cte)"            fun MULT
      dict set SERIES "$caption(audace,menu,mult_cte)"            hlp "$help(dir,prog) ttus1-fr.htm MULT"
      dict set SERIES "$caption(audace,menu,mult_cte)"            par "constant 1."
      dict set SERIES "$caption(audace,menu,mult_cte)"            opt "bitpix 16 skylevel 0 nullpixel 0 jpegfile 0 jpeg_quality 75"
      dict set SERIES "$caption(audace,menu,log)"                 fun LOG
      dict set SERIES "$caption(audace,menu,log)"                 hlp "$help(dir,prog) ttus1-fr.htm LOG"
      dict set SERIES "$caption(audace,menu,log)"                 par "coef 20. offsetlog 1."
      dict set SERIES "$caption(audace,menu,log)"                 opt "bitpix 16 skylevel 0 nullpixel 0 jpegfile 0 jpeg_quality 75"
      dict set SERIES "$caption(audace,menu,noffset)"             fun NORMOFFSET
      dict set SERIES "$caption(audace,menu,noffset)"             hlp "$help(dir,prog) ttus1-fr.htm NORMOFFSET"
      dict set SERIES "$caption(audace,menu,noffset)"             par "normoffset_value 0."
      dict set SERIES "$caption(audace,menu,noffset)"             opt "bitpix 16 skylevel 0 nullpixel 0 jpegfile 0 jpeg_quality 75"
      dict set SERIES "$caption(audace,menu,ngain)"               fun NORMGAIN
      dict set SERIES "$caption(audace,menu,ngain)"               hlp "$help(dir,prog) ttus1-fr.htm NORMGAIN"
      dict set SERIES "$caption(audace,menu,ngain)"               par "normgain_value 200."
      dict set SERIES "$caption(audace,menu,ngain)"               opt "bitpix 16 skylevel 0 nullpixel 0 jpegfile 0 jpeg_quality 75"
      #--   fonction artificielle inexistante dans IMA/SERIES
      dict set SERIES "$caption(audace,menu,clip)"                fun CLIP
      dict set SERIES "$caption(audace,menu,clip)"                hlp "$help(dir,pretrait) 1070ecreter.htm"
      dict set SERIES "$caption(audace,menu,clip)"                par "mini 0. maxi 32767."
      dict set SERIES "$caption(audace,menu,clip)"                opt "bitpix 16"

      return [::prtr::consultDic SERIES $function]
   }

   #--------------------------------------------------------------------------
   #  ::prtr::IMPROVEFunctions {0|nom_de_fonction}
   #  Cree le dictionnaire des fonctions IMA/SERIES qui ameliorent les images
   #  Retourne la liste des fonctions ou les parametres d'une fonction
   #--------------------------------------------------------------------------
    proc IMPROVEFunctions {function} {
      variable SERIES
      global caption help

      dict set SERIES "$caption(audace,menu,trainee)"             fun UNSMEARING
      dict set SERIES "$caption(audace,menu,trainee)"             hlp "$help(dir,prog) ttus1-fr.htm UNSMEARING"
      dict set SERIES "$caption(audace,menu,trainee)"             par "unsmearing 0.0005"
      dict set SERIES "$caption(audace,menu,trainee)"             opt "bitpix 16 skylevel 0 nullpixel 0 jpegfile 0 jpeg_quality 75"
      dict set SERIES "$caption(audace,menu,cosmic)"              fun COSMIC
      dict set SERIES "$caption(audace,menu,cosmic)"              hlp "$help(dir,prog) ttus1-fr.htm COSMIC"
      dict set SERIES "$caption(audace,menu,cosmic)"              par "cosmic_threshold 400"
      dict set SERIES "$caption(audace,menu,cosmic)"              opt "bitpix 16 skylevel 0 nullpixel 0 jpegfile 0 jpeg_quality 75"
      dict set SERIES "$caption(audace,menu,opt_noir)"            fun OPT
      dict set SERIES "$caption(audace,menu,opt_noir)"            hlp "$help(dir,prog) ttus1-fr.htm OPT"
      dict set SERIES "$caption(audace,menu,opt_noir)"            par "bias img dark img therm_kappa 0.25"
      dict set SERIES "$caption(audace,menu,opt_noir)"            opt "unsmearing 0.0005 bitpix 16 skylevel 0 nullpixel 0 jpegfile 0 jpeg_quality 75"
      dict set SERIES "$caption(audace,menu,subsky)"              fun BACK
      dict set SERIES "$caption(audace,menu,subsky)"              hlp "$help(dir,prog) ttus1-fr.htm BACK"
      dict set SERIES "$caption(audace,menu,subsky)"              par "back_kernel 4 back_threshold 0."
      dict set SERIES "$caption(audace,menu,subsky)"              opt "sub 0 div 0 bitpix 16 skylevel 0 nullpixel 0 jpegfile 0 jpeg_quality 75"

      return [::prtr::consultDic SERIES $function]
   }

   #--------------------------------------------------------------------------
   #  ::prtr::EXTRACTFunctions {0|nom_de_fonction}
   #  Cree le dictionnaire des fonctions IMA/SERIES qui extrait des infomations numeriques
   #  Retourne la liste des fonctions ou les parametres d'une fonction
   #--------------------------------------------------------------------------
   proc EXTRACTFunctions {function} {
      variable SERIES
      global caption help

      dict set SERIES "$caption(audace,menu,ligne)"               fun "PROFILE direction=x"
      dict set SERIES "$caption(audace,menu,ligne)"               hlp "$help(dir,prog) ttus1-fr.htm PROFILE"
      dict set SERIES "$caption(audace,menu,ligne)"               par "offset 1 filename row"
      dict set SERIES "$caption(audace,menu,ligne)"               opt "bitpix 16 skylevel 0 nullpixel 0 jpegfile 0 jpeg_quality 75"
      dict set SERIES "$caption(audace,menu,colonne)"             fun "PROFILE direction=y"
      dict set SERIES "$caption(audace,menu,colonne)"             hlp "$help(dir,prog) ttus1-fr.htm PROFILE"
      dict set SERIES "$caption(audace,menu,colonne)"             par "offset 1 filename col"
      dict set SERIES "$caption(audace,menu,colonne)"             opt "bitpix 16 skylevel 0 nullpixel 0 jpegfile 0 jpeg_quality 75"
      dict set SERIES "$caption(audace,menu,matrice)"             fun MATRIX
      dict set SERIES "$caption(audace,menu,matrice)"             hlp "$help(dir,prog) ttus1-fr.htm MATRIX"
      dict set SERIES "$caption(audace,menu,matrice)"             par "x1 1 y1 1 x2 2 y2 2 filematrix matrice"
      dict set SERIES "$caption(audace,menu,matrice)"             opt "bitpix 16 skylevel 0 nullpixel 0 jpegfile 0 jpeg_quality 75"

      return [::prtr::consultDic SERIES $function]
   }

   #--------------------------------------------------------------------------
   #  ::prtr::AMELFunctions {0|nom_de_fonction}
   #  Cree le dictionnaire des fonctions IMA/SERIES avec filtre d'amélioration
   #  Retourne la liste des fonctions ou les parametres d'une fonction
   #--------------------------------------------------------------------------
    proc AMELFunctions {function} {
      variable SERIES
      global caption help

      dict set SERIES "$caption(audace,menu,filtre_gaussien)"     fun "CONV kernel_type=gaussian"
      dict set SERIES "$caption(audace,menu,filtre_gaussien)"     hlp "$help(dir,prog) ttus1-fr.htm CONV"
      dict set SERIES "$caption(audace,menu,filtre_gaussien)"     par ""
      dict set SERIES "$caption(audace,menu,filtre_gaussien)"     opt "sigma 2. bitpix 16 skylevel 0 nullpixel 0 jpegfile 0 jpeg_quality 75"
      dict set SERIES "$caption(audace,menu,ond_morlet)"          fun "CONV kernel_type=morlet"
      dict set SERIES "$caption(audace,menu,ond_morlet)"          hlp "$help(dir,prog) ttus1-fr.htm CONV"
      dict set SERIES "$caption(audace,menu,ond_morlet)"          par ""
      dict set SERIES "$caption(audace,menu,ond_morlet)"          opt "sigma 2. bitpix 16 skylevel 0 nullpixel 0 jpegfile 0 jpeg_quality 75"
      dict set SERIES "$caption(audace,menu,ond_mexicain)"        fun "CONV kernel_type=mexican"
      dict set SERIES "$caption(audace,menu,ond_mexicain)"        hlp "$help(dir,prog) ttus1-fr.htm CONV"
      dict set SERIES "$caption(audace,menu,ond_mexicain)"        par ""
      dict set SERIES "$caption(audace,menu,ond_mexicain)"        opt "sigma 2. bitpix 16 skylevel 0 nullpixel 0 jpegfile 0 jpeg_quality 75"
      dict set SERIES "$caption(audace,menu,grad_rot)"            fun RGRADIENT
      dict set SERIES "$caption(audace,menu,grad_rot)"            hlp "$help(dir,prog) ttus1-fr.htm RGRADIENT"
      dict set SERIES "$caption(audace,menu,grad_rot)"            par "xcenter 1. ycenter 1. radius 1. angle 1."
      dict set SERIES "$caption(audace,menu,grad_rot)"            opt "bitpix 16 skylevel 0 nullpixel 0 jpegfile 0 jpeg_quality 75"
      dict set SERIES "$caption(audace,menu,radial)"              fun RADIAL
      dict set SERIES "$caption(audace,menu,radial)"              hlp "$help(dir,prog) ttus1-fr.htm RADIAL"
      dict set SERIES "$caption(audace,menu,radial)"              par "sigma 10 power 2 xcenter 1. ycenter 1. radius 1."
      dict set SERIES "$caption(audace,menu,radial)"              opt "bitpix 16 skylevel 0 nullpixel 0 jpegfile 0 jpeg_quality 75"
      dict set SERIES "$caption(audace,menu,hough)"               fun HOUGH
      dict set SERIES "$caption(audace,menu,hough)"               hlp "$help(dir,prog) ttus1-fr.htm HOUGH"
      dict set SERIES "$caption(audace,menu,hough)"               par ""
      dict set SERIES "$caption(audace,menu,hough)"               opt "threshold 0 binary 0 bitpix 16 skylevel 0 nullpixel 0 jpegfile 0 jpeg_quality 75"

      return [::prtr::consultDic SERIES $function]
   }

   #--------------------------------------------------------------------------
   #  ::prtr::MAITREFunctions {0|nom_de_fonction}
   #  Cree le dictionnaire des fonctions de pretraitement creant des maitres (offset,dark et flat)
   #  Retourne la liste des fonctions ou les parametres d'une fonction
   #--------------------------------------------------------------------------
    proc MAITREFunctions {function} {
      variable MAITRE
      global caption help

      dict set MAITRE "$caption(audace,menu,faire_offset)"        fun "BIAS"
      dict set MAITRE "$caption(audace,menu,faire_offset)"        hlp "$help(dir,pretrait) 1250faire_maitre.htm OFFSET"
      dict set MAITRE "$caption(audace,menu,faire_offset)"        par ""
      dict set MAITRE "$caption(audace,menu,faire_offset)"        opt "bitpix 16 skylevel 0 nullpixel 0"
      dict set MAITRE "$caption(audace,menu,faire_dark)"          fun "DARK"
      dict set MAITRE "$caption(audace,menu,faire_dark)"          hlp "$help(dir,pretrait) 1250faire_maitre.htm DARK"
      dict set MAITRE "$caption(audace,menu,faire_dark)"          par "methode MED bias \"\" "
      dict set MAITRE "$caption(audace,menu,faire_dark)"          opt "bitpix 16 skylevel 0 nullpixel 0"
      dict set MAITRE "$caption(audace,menu,faire_flat_field)"    fun "FLAT"
      dict set MAITRE "$caption(audace,menu,faire_flat_field)"    hlp "$help(dir,pretrait) 1250faire_maitre.htm FLAT"
      dict set MAITRE "$caption(audace,menu,faire_flat_field)"    par "bias  \"\" dark \"\" normoffset_value 0."
      dict set MAITRE "$caption(audace,menu,faire_flat_field)"    opt "bitpix 16 skylevel 0 nullpixel 0"

      return [consultDic MAITRE $function]
   }

   #--------------------------------------------------------------------------
   #  ::prtr::PRETRAITEEFunctions {0|nom_de_fonction}
   #  Cree le dictionnaire des fonctions de pretraitement
   #  Retourne la liste des fonctions ou les parametres d'une fonction
   #--------------------------------------------------------------------------
    proc PRETRAITEEFunctions {function} {
      variable PRETRAITEE
      global caption help

      dict set PRETRAITEE "$caption(audace,menu,pretraitee)"      fun "PRETRAITEMENT"
      dict set PRETRAITEE "$caption(audace,menu,pretraitee)"      hlp "$help(dir,pretrait) 1250faire_maitre.htm PRETRAITER"
      dict set PRETRAITEE "$caption(audace,menu,pretraitee)"      par "bias \"\" dark \"\" opt_black 0 flat \"\" constant 1."
      dict set PRETRAITEE "$caption(audace,menu,pretraitee)"      opt "bitpix 16 skylevel 0 nullpixel 0"

      return [consultDic PRETRAITEE $function]
   }

   #--------------------------------------------------------------------------
   #  ::prtr::consultDic dico {0|nom_de_fonction}
   #  Consulte un dictionnaire
   #  Retourne la liste des fonctions ou des parametres de la fonction
   #--------------------------------------------------------------------------
   proc consultDic {dico function} {
      variable $dico

      upvar $dico dictionnaire
      if {$function ne 0} {
         foreach key {fun par opt hlp} {
            lappend result "[dict get $dictionnaire $function $key]"
         }
      } else {
         set result "[dict keys $dictionnaire]"
      }
      unset $dico
      return $result
   }

   #--------------------------------------------------------------------------
   #  ::prtr::searchFunction nom_de_fonction
   #  Recherche le dictionnaire de la fonction et afficher la liste dans le menubutton
   #--------------------------------------------------------------------------
   proc searchFunction {oper} {
      variable private

      foreach dico {PILE ARITHM IMPROVE TRANSFORM EXTRACT AMEL MAITRE PRETRAITEE} {
         set fonctions [${dico}Functions 0]
         if {$oper in $fonctions} {
            set private(fonctions) "$fonctions"
            set private(ima) $dico
            break
         }
      }
   }

   #--------------------------------------------------------------------------
   #  ::prtr::consultDic getTypeVar
   #  Liste les parametres  avec les tests et le widget associes
   #  Consulte par une cmd [dict get $Var $child]
   #--------------------------------------------------------------------------
   proc getTypeVar {} {
      variable Var

      dict set Var   bitpix            "integer combobox"            ;#options IMA
      dict set Var   skylevel          "boolean checkbutton"         ;#options IMA
      dict set Var   nullpixel         "double labelentry"           ;#options IMA
      dict set Var   jpegfile          "boolean checkbutton"         ;#options IMA
      dict set Var   jpeg_quality      "integer 100 labelentry"      ;#options IMA
      dict set Var   powernorm         "boolean checkbutton"         ;#PROD
      dict set Var   percent           "double 100 labelentry"       ;#IMA/STACK SORT
      dict set Var   kappa             "double labelentry"           ;#SK
      dict set Var   offset            "integer labelentry"          ;#OFFSET ADD SUB PROFILE
      dict set Var   constant          "double labelentry"           ;#MULT flat
      dict set Var   coef              "double labelentry"           ;#LOG
      dict set Var   offsetlog         "double labelentry"           ;#LOG
      dict set Var   back_threshold    "double 1. labelentry"        ;#BACK
      dict set Var   back_kernel       "integer 4 labelentry"        ;#BACK
      dict set Var   sub               "boolean checkbutton"         ;#BACK
      dict set Var   div               "boolean checkbutton"         ;#BACK
      dict set Var   binary            "boolean checkbutton"         ;#HOUGH
      dict set Var   normoffset_value  "double labelentry"           ;#NORMOFFSET flat
      dict set Var   normgain_value    "double labelentry"           ;#NORMGAIN
      dict set Var   unsmearing        "double labelentry"           ;#UNSMEARING
      dict set Var   cosmic_threshold  "double labelentry"           ;#COSMIC
      dict set Var   sigma             "double labelentry"           ;#CONV RADIAL
      dict set Var   radius            "double labelentry"           ;#RGRADIENT RADIAL
      dict set Var   xcenter           "double labelentry"           ;#RGRADIENT RADIAL
      dict set Var   ycenter           "double labelentry"           ;#RGRADIENT RADIAL
      dict set Var   power             "double labelentry"           ;#RADIAL
      dict set Var   x0                "double naxis1 labelentry"    ;#ROT ROTENTIERE REC2POL POL2REC
      dict set Var   y0                "double naxis2 labelentry"    ;#ROT ROTENTIERE REC2POL POL2REC
      dict set Var   angle             "double labelentry"           ;#ROT ROTENTIERE RGRADIENT
      dict set Var   scale_rho         "double labelentry"           ;#REC2POL POL2REC
      dict set Var   scale_theta       "double labelentry"           ;#REC2POL POL2REC
      dict set Var   trans_x           "double labelentry"           ;#TRANS
      dict set Var   trans_y           "double labelentry"           ;#TRANS
      dict set Var   threshold         "double labelentry"           ;#HOUGH
      dict set Var   therm_kappa       "double labelentry"           ;#OPT
      dict set Var   x1                "integer naxis1 labelentry"   ;#WINDOW BINX MATRIX MEDIANX SORTX
      dict set Var   y1                "integer naxis2 labelentry"   ;#WINDOW BINY MATRIX MEDIANY SORTY
      dict set Var   x2                "integer naxis1 labelentry"   ;#WINDOW BINX MATRIX MEDIANX SORTX
      dict set Var   y2                "integer naxis2 labelentry"   ;#WINDOW BINY MATRIX MEDIANY SORTY
      dict set Var   width             "integer naxis1 labelentry"   ;#BINX POL2REC MEDIANX SORTX
      dict set Var   height            "integer naxis2 labelentry"   ;#BINY POL2REC MEDIANY SORTY
      dict set Var   normaflux         "boolean checkbutton"         ;#RESAMPLE
      dict set Var   paramresample     "liste labelentry"            ;#RESAMPLE
      dict set Var   filename          "filename labelentry"         ;#PROFILE
      dict set Var   filematrix        "filename labelentry"         ;#MATRIX
      dict set Var   file              "img labelentry"              ;#ADD SUB DIV PROD
      dict set Var   bias              "img labelentry"              ;#OPT flat prt
      dict set Var   dark              "img labelentry"              ;#OPT flat prt
      dict set Var   flat              "img labelentry"              ;#prt
      dict set Var   mini              "double labelentry"           ;#CLIP
      dict set Var   maxi              "double labelentry"           ;#CLIP
      dict set Var   opt_black         "boolean checkbutton"         ;#prt
      dict set Var   methode           "boolean radiobutton"         ;#dark
   }

   #--------------------------------------------------------------------------
   #  ::prtr::cmdVerif
   #  Verifie les donnees saisies : nb de selections, nom de sortie, parametres numeriques
   #  Produit options formatees pour le scriptTT
   #  Retourne options si pas d'erreur, sinon 0
   #--------------------------------------------------------------------------
   proc cmdVerif {} {
      variable private

      set nb_images "1"
      #--   pour ces fonctions il faut au moins 2 images
      if {$private(ima) in [list MAITRE PILE]} {set nb_images "2"}

      #--   nb d'images est inferieur au seuil ?
      if {![info exists private(todo)] || [llength $private(todo)] < $nb_images} {
         return [avertiUser err_file_nb $nb_images]
      }

      #--   nom de sortie defini ?
      if {$private(function) ni [list "PROFILE direction=x" "PROFILE direction=y" "MATRIX"]} {

         if {$prtr::out eq "" || $prtr::out eq "\"\""} {
            return [avertiUser sortie_generique]
         }

         #--   separe les elements
         set info [getInfoFile $::prtr::out]
         set dir "[lindex $info 0]"
         set ::prtr::generique "[lindex $info 1]"
         set extension "[lindex $info 2]"

         if {![file exists $dir]} {
            return [avertiUser err_file_dir $dir]
         } else {
            set ::prtr::dir_out $dir
         }

         #--   verifie l'extension si l'utilisateur en a donnee une
         if {$extension ne "" && $extension ne "$::prtr::ext"} {
            return [avertiUser err_file_ext "$prtr::out" "$::prtr::ext"]
         }

         #--   nom_court correct ?
         regexp -all {[\w_-]+} $::prtr::generique match
         if {![ info exists match] || $match ne $::prtr::generique} {
            return [avertiUser err_file_generique]
         }

      } else {
         set ::prtr::dir_out "."
         set ::prtr::out ""
         #--      definit le nom de sortie comme le premier de la liste
         set ::prtr::generique "[lindex $private(todo) 0]"
      }

      set options " "
      foreach type {obligatoire optionnel} val {1 0} {
         #--   si la liste n'existe pas, passe a la liste suivante
         if {![ info exists private($type)]} {continue}
         if {$options == "0"} {break}
         #--   isole la liste
         set content $private($type)
         set l [llength $content]
         for {set i 0} {$i < $l} {incr i} {
            #--   extrait le parametre
            set parametre [lindex $content $i]
            set res [cmdTestVariable $parametre $val]
            switch $res {
                  "0"      {set options 0 ; #--    une erreur}
                  ""       {#--parametre optionnel non pris en compte}
                  default  {append options " $res" ;#--   bonne valeur}
            }
            if {$options == "0"} {break}
         }
      }
      return $options
   }

   #--------------------------------------------------------------------------
   # ::prtr::cmdTestVariable nom_du_parametre {1=obligatoire | 0=optionnel}
   # Teste la valeur associe a un parametre
   # Retourne : 0 si erreur, parametre=$valeur si test ok, rien si parametre optionnel inchange
   #--------------------------------------------------------------------------
   proc cmdTestVariable {parametre obl} {
      variable Var
      variable bd
      variable private

      #--   recupere la nature du test et la valeur par defaut du parametre
      foreach {test seuil} [lrange [dict get $Var $parametre] 0 end-1] {break}

      #--   capture la valeur du parametre
      namespace upvar ::prtr:: $parametre value

      #--   si parametre optionnel, compare la valeur a la valeur par defaut
      #--   arrete si les deux valeurs sont identiques car non pris en compte
      if {$obl eq "0"} {
         set index [lsearch $private(l_optionnel) $parametre]
         incr index
         if { [lindex $private(l_optionnel) $index] eq "$value"} {
            return ""
         }
      }

      #--   teste si une valeur existe
      if {$value eq ""} {
         if {$parametre ni {bias dark flat}} {
            return [avertiUser err_par_def $parametre ]
         } else {
            return ""
         }
      }

      if {$test == "boolean"} {
         #--   teste un parametre booleen
         if {$value == "1"}  {
               if {$parametre eq "opt_black" && ($::prtr::bias eq "" || $::prtr::dark eq "")} {
                  return [avertiUser err_opt_noir $parametre]
               } else {
                  return "$parametre"
               }
         }
      } elseif {$test in {double integer}} {
         #--   teste la nature de la variable
         if {![string is $test -strict $value]} {
            return [avertiUser err_par_type $parametre $test]
         }
         if {$seuil eq ""} {
            #--   si pas controle dimmensionnel
            return "$parametre=$value"
         } else {
            if {($parametre eq "jpeg_quality") && ($::prtr::jpegfile == "0")} {
               return ""
            }
            #--   si controle dimmensionnel
            set mini "0"
            if {$seuil in {naxis1 naxis2}} {
               #--   extrait le nom de la premiere image, naxis1 et naxis2
               set img [lindex $private(todo) 0]
               set info [lindex [array get bd $img] 1]
               foreach {nihil nihil naxis1 naxis2} $info {break}
               switch $seuil "naxis1" "set seuil $naxis1" "naxis2" "set seuil $naxis2" "default" ""
               set mini "1"
            }
            if {$value < $mini || $value > $seuil}  {
               return [avertiUser err_par_bornes $parametre]
            } else {
               return "$parametre=$value"
            }
         }
      } elseif {$test in {filename filematrix}} {
         #--   teste si le nom est valide
         regexp -all {[\w_-]+} $value match
         if {[info exists match] && $value eq "$match"} {
            #--   cas du nom d'un fichier .txt
            return "$parametre=$value.txt"
         }
      } elseif {$test eq "img"} {

         lassign [::prtr::getInfoFile $value] dir nom_court extension

         #--   verifie l'extension
         if {$extension ne "$::conf(extension,defaut)" && $extension ne "$::conf(extension,defaut).gz"} {
            return [avertiUser err_file_ext $parametre $::conf(extension,defaut)]
         }
         #--   verifie son orthographe
         regexp -all {[\w_-]+} $nom_court match
         if {![info exists match] || $nom_court ne "$match"} {
            return [avertiUser err_par_name $parametre]
         }

         set row [lsearch [$private(table).choix getcolumns 1] $nom_court]
         if {$row >=0} {
            if {[lrange [$private(table).choix get $row] 2 end] eq $private(profil)} {
               #--   l'image est du meme type que celles selectionnee
               if {$nom_court ni $private(todo)} {
                  #--   cas ou l'image n'a pas deja ete selectionnee
                  return "\"$parametre=$value\""
               } else {
                  #--   cas ou l'image deja ete selectionnee
                  return [avertiUser err_file_select $value]
               }
            } else {
               #--   cas du fichier de type different
               return [avertiUser err_file_type $parametre]
            }
         } else {
           #--   l'image vient d'un autre repertoire
            #--   verifie si elle existe
            if {![file exists $value]} {
               return [avertiUser err_no_file $value]
            }

            #--   verifie les dimensions des images
            lassign [::prtr::analyseFitsHeader $value] naxis naxis3 naxis1 naxis2
            if {[lindex $private(profil) 1] ne "${naxis1} X ${naxis2}"} {
               return [avertiUser err_file_dim $value]
            }

            #--   dans le cas de OPT et MAITRE verifie qu'il ne s'agit pas d'une image couleurs
            if {$private(function) in {OPT MAITRE} && $naxis eq "3" && $naxis3 eq "3"} {
               return [avertiUser err_par_file $parametre]
            }
            return "\"$parametre=$value\""
         }
      } elseif {$test eq "liste"} {
         #--   il doit y avoir exactement 6 parametres
         if {[llength $value] ne 6 } {
            return [avertiUser err_par_def $parametre]
         }
         #--   tous les parametres doivent etre numeriques
         ::blt::vector create temp -watchunset 1
         if {[catch {temp append $value}]} {
            ::blt::vector destroy temp
            return [avertiUser err_par_def $parametre]
         }
         #--   teste les valeurs
         if {[expr {$temp(1)*$temp(3)-$temp(0)*$temp(4)}] == "0"} {
            ::blt::vector destroy temp
            return [avertiUser err_list_val $parametre]
         }
         ::blt::vector destroy temp
         return "\"paramresample=$value\""
      }
   }

   #--------------------------------------------------------------------------
   #  ::prtr::getInfoFile
   #  Retourne le directory, le nom court et l'extension suivie ou non de .gz
   #--------------------------------------------------------------------------
   proc getInfoFile {file} {

      set dir [file dirname $file]
      set nom_avec_extensions "[file tail $file]"
      #--   extrait l'extension
      set extensions ""
      regexp {(\.[a-zA-Z]{3,4}|\.[a-zA-Z]{3,4}.gz)} $nom_avec_extensions extensions
      #--   ote toutes les extensions du nom
      regsub "$extensions" $nom_avec_extensions "" nom_court
      return [list $dir $nom_court $extensions]
   }


   #--------------------------------------------------------------------------
   #  ::prtr::cmdExec { {IMA/STACK|IMA/SERIES} in name_out fonctionTT parametres }
   #  Exemple ::prtr::cmdExec [ list "IMA/SERIES" "$liste_generique_avec_index" "$nom_sortie" "ADD" "bitpix=16" ]
   #  Procedure lancee par le bouton Appliquer
   #--------------------------------------------------------------------------
   proc cmdExec { data options } {

      set dir  $::audace(rep_images)
      cd $dir
      foreach {select in dir_out name_out extension function} $data {break}

      #--   fonctions necessitant une indexation de parametres en .fit ou .txt
      set filtre_file [list ADD SUB DIV PROD OPT]
      set filtre_txt [list "PROFILE direction=x" "PROFILE direction=y" MATRIX]
      set filtres [concat $filtre_file $filtre_txt]
      set nb_img [llength $in]

      #--   identifie le type d'images
      set type [getImgType $in]

      #--   si compression
      if {$::conf(fichier,compres) eq "0"} {
         set ext $extension
      } else {
         set to_compress ""
         regsub ".gz" $extension "" ext
         #--   decompresse les fichiers .gz
         foreach img $in {
            gunzip $img$extension
            #--   prepare la liste des compressions
            lappend to_compress [file join $dir $img$ext]
         }
      }

      #--   examine chaque fichier et
      #--   constitue la liste des nom en entree et en sortie
      if {$type eq "C"} {
         foreach file $in {
            decompRGB $file
            #--   liste les fichiers aÂ traiter
            foreach k {r g b} {
               lappend list_$k ${file}$k
               lappend to_destroy ${file}$k
            }
         }
         set list_in [list "$list_r" "$list_g" "$list_b"]
         set list_out [list ${name_out}r ${name_out}g ${name_out}b]
      } else {
         set gray "$in"
         set list_in [list $gray]
         set list_out [list $name_out]
      }

      #--   gere le repertoire de sortie
      set rep $dir_out
      if {$dir_out eq "."} {set rep "$::audace(rep_images)"}

      #--   gere les indices de sortie
      set indice_out "."
      #--   si plusieurs images de sortie
      if {$select eq "IMA/SERIES" && $nb_img ne "1"} {set indice_out "1"}

      #--   RGB2R+G+B des images RGB passees en parametres
      if {$select eq "IMA/SERIES" && $function in {ADD SUB DIV PROD} && $type == "C"} {
         set data [traiteImg $options file]
         set options [lindex $data 0]
         set img [lindex $data 1]
         ::prtr::decompRGB $img
         lappend to_destroy $img ${img}r ${img}g ${img}b
      }

      #--   fixe le generique de sortie sans indice ni plan couleur ni extension
      set racine [file join $rep $name_out]

      set catchError [catch {

         foreach file_type $list_in file_out $list_out {

            if {$type eq "C"} {set color [string index [lindex $file_type 0] end]}

            if {($type eq "C") && ($select eq "IMA/SERIES") && ($function in $filtres)} {
               regsub -all "$ext" $options "${color}$ext" options
               regsub -all ".txt" $options "${color}.txt" options
            }

            set script "$select . \"$file_type\" * * $ext \"$rep\" $file_out $indice_out $ext $function $options"
            if {$::prtr::script eq "1"} {
               ::console::affiche_resultat "Usage : ttscript2 \"$script\"\n"
            }
            ttscript2 $script

            if {($type eq "C") && ($select eq "IMA/SERIES") && ($function in $filtres)} {
               regsub -all "(r|g|b)$ext" $options "$ext" options
               regsub -all "(r|g|b)\.txt" $options ".txt" options
            }

            if {$type eq "C" && $indice_out eq "1"} {
               for {set i 1} {$i <= $nb_img} {incr i} {
                  #--   intervertit le nom du plan et l'indice
                  file rename -force "$racine$color$i$ext" "$racine$i$color$ext"
                  if {[lsearch -regexp $options "jpegfile"] >= 0} {
                     file rename -force $racine$color$i.jpg $racine$i$color.jpg
                  }
               }
            }
         }

         #--   convertir en RGB
         if {$indice_out eq "."} {
            if {$type eq "C"} {::prtr::convertitRGB $racine$ext}
         } else {
            for {set i 1} {$i <= $nb_img} {incr i} {
               if {$type eq "C"} {::prtr::convertitRGB $racine$i$ext}
            }
         }

         #--   recompresse les fichiers d'entree et les fichiers de sortie
         if {$::conf(fichier,compres) eq "1"} {
            foreach file $to_compress {gzip $file}
            set ext "$ext.gz"
         }

         #--   efface les plans couleurs des images entrantes
         if {[info exists to_destroy]} {
           ttscript2 "IMA/SERIES . \"$to_destroy\" * * $ext . . . . DELETE"
         }

      }  ErrInfo]
      if {$catchError eq "1"} {::prtr::Error "$ErrInfo"}
      return $catchError
   }

   #--------------------------------------------------------------------------
   #  ::prtr::traiteImg
   #  Copie l'image operande et la decompose en plans couleurs
   #  et modifie le parametre file en consequence
   #  Lancee par cmdExec
   #--------------------------------------------------------------------------
   proc traiteImg {options p} {

      #--   cherche le rang du parametre "$p="
      set pattern "$p="
      set k [lsearch -regexp $options $pattern]
      #--   extrait tout le parametre
      set param [lindex $options $k]
      #--   extrait le nom complet du fichier
      regsub ($pattern) $param "" file
      if {[file dirname $file] ne "$::audace(rep_images)"} {
         set ext [file extension $file]
         #--   recopie le fichier dans rep_images
         file copy -force $file $::audace(rep_images)
         set file [file tail [file rootname $file]]
         #--   remplace le parametre dans options
         set options [lreplace $options $k $k "$pattern$file$ext"]
      }
      return [list $options $file]
   }

   #--------------------------------------------------------------------------
   #  ::prtr::decompRGB
   #  Decompose l'image couleur en plans couleurs
   #--------------------------------------------------------------------------
   proc decompRGB {file} {

      set ext $::prtr::ext
      set nom_sans_extension [file join $::audace(rep_images) $file]
      ::conv2::Do_rgb2r+g+b $nom_sans_extension$ext $nom_sans_extension
   }

   #--------------------------------------------------------------------------
   #  ::prtr::convertitRGB
   #  Reconstitue l'image couleur et efface les plans couleurs
   #  Parametre : nom de sortie (avec ou sans indice) de l'image
   #--------------------------------------------------------------------------
   proc convertitRGB {name_out} {

      set file [file rootname $name_out]
      set ext [file extension $name_out]
      #--   convertit les plans couleurs en RGB
      ::conv2::Do_r+g+b2rgb $file $file
      #--   efface les plans couleurs
      file delete ${file}r$ext ${file}g$ext ${file}b$ext
   }

   #--------------------------------------------------------------------------
   #  ::prtr::getImgType files
   #  Definit le type d'image a traiter
   #  Retourne : {C|M|error} ;C pour couleur, M pour monochrome
   #  Lancee par ::prtr::cmdApply
   #--------------------------------------------------------------------------
   proc getImgType {files } {
      variable private
      variable bd

      #--   accelere pour le cas particulier d'une image isolee
      if {[llength $files] eq "1"} {
         set w "$private(table).choix"
         set k [lsearch [$w getcolumns 1] $files]
         return "[$w cellcget $k,2 -text]"
      }

      ::blt::vector create Vnaxis Vnaxis3 -watchunset 1
      foreach file $files {
         foreach {naxis naxis3} [lindex [array get bd $file] 1] {break}
         Vnaxis append $naxis
         Vnaxis3 append $naxis3
      }
      switch [Vnaxis3 length] 0 {set type "M"} [Vnaxis length] {set type "C"} default {set type "error"}
      ::blt::vector destroy Vnaxis Vnaxis3
      return $type
   }

   #--------------------------------------------------------------------------
   #  ::prtr::convertBitPix2BitPix {8|16|+16|32|+32|-32|-64}
   #  Convertit bitpix de TT vers bitpix pour buf
   #--------------------------------------------------------------------------
   proc convertBitPix2BitPix {bitpix} {

      set convert [list byte 8 short 16 ushort +16 long 32 ulong +32 float -32 double -64]
      set k [lsearch $convert $bitpix]
      incr k "-1"
      return [lindex $convert $k]
   }

   #--------------------------------------------------------------------------
   #  ::prtr::clipMinMax $data
   #  Ex-tournement de multi-ecreter
   #--------------------------------------------------------------------------
   proc clipMinMax { data options } {

      lassign $data imgList dir out ext
      set l [llength $imgList]

      if {$dir eq "."} {set dir $::audace(rep_images)}

      #---  extrait les valeurs numeriques
      foreach type {mini maxi bitpix} {
        lassign [extractData $options "$type"] options $type
      }
      set bitpix [::prtr::convertBitPix2BitPix $bitpix]

      set catchError [catch {

         set buf_clip [::buf::create]
         buf$buf_clip extension $ext
         if {$bitpix ne ""} {buf$buf_clip bitpix $bitpix}
         set l [llength $imgList]

         #--   identifie le type d'images
         set type [::prtr::getImgType $imgList]

         foreach in $imgList {
            set index [lsearch $imgList $in]
            #--   decompose l'image RGB
            if {$type eq "C"} {
               decompRGB $in
               foreach color {r g b} {
                  buf$buf_clip load [file join $dir $in$color$ext]
                  buf$buf_clip clipmin $mini
                  buf$buf_clip clipmax $maxi
                  if {$l == "1"} {
                     set name_out [file join $dir $out]
                  } else {
                     set name_out [file join $dir $out$index]
                  }
                  buf$buf_clip save $name_out$color$ext
               }
               #--   convertit en RGB
               ::prtr::convertitRGB $name_out$ext
               #--   efface les plans couleurs intermediaires
               file delete [file join $dir ${in}r$ext] [file join $dir ${in}g$ext] \
                  [file join $dir ${in}b$ext]
            }  else {
               buf$buf_clip load [file join $dir $in$ext]
               buf$buf_clip clipmin $mini
               buf$buf_clip clipmax $maxi
               if {$l == "1"} {
                  set name_out [file join $dir $out]
               } else {
                  set name_out [file join $dir $out$index]
               }
               buf$buf_clip save $name_out$ext
            }
         }
         ::buf::delete $buf_clip
      } ErrInfo]
      if {$catchError eq "1"} {::prtr::Error "$ErrInfo"}
      return $catchError
   }

   #----------------------fonctions du pretraitement--------------------------

   #--------------------------------------------------------------------------
   #  ::prtr::faireOffset
   #  Fait la mediane des images d'offset
   #  Parmetres : donnees du script, options TT sous forme de listes
   #--------------------------------------------------------------------------
   proc faireOffset { data options } {

      cd $::audace(rep_images)
      set extOut $::conf(extension,defaut)
      lassign $data imgList dirOut nameOut extIn

      set script "IMA/STACK . \"$imgList\" * * $extIn \"$dirOut\" \"$nameOut\" .  $extOut MED"
      if {$options ne ""} {append script " " $options}
      if {$::prtr::script eq "1"} {
         ::console::affiche_resultat "$script\n"
      }
      set catchError [catch {ttscript2 $script} ErrInfo]
      if {$catchError eq "1"} {::prtr::Error "$ErrInfo"}
      return $catchError
   }

   #--------------------------------------------------------------------------
   #  ::prtr::faireDark
   #  Applique la methode choisie apres soustraction de l'offset s'il existe
   #  Parmetres : donnees du script, options T sous forme de listes
   #--------------------------------------------------------------------------
   proc faireDark { data options } {

      cd $::audace(rep_images)
      set extOut $::conf(extension,defaut)
      lassign $data imgList dirOut nameOut extIn methode
      set l [llength $imgList]

      #--   cherche le nom de l'offset
      lassign [extractData $options "bias"] options bias

      set catchError [catch {
         if {$bias ne ""} {
            #--   soustrait l'offset des images
            set script "IMA/SERIES . \"$imgList\" * * $extIn . temp 1 $extOut SUB \"file=$bias\" "
            if {$::prtr::script eq "1"} {
               ::console::affiche_resultat "$script\n"
            }
            ttscript2 "$script"

            #--   met a jour la liste des images a traiter
            set imgList [buildNewList temp $l]

            #--   change l'extension des fichiers entrants
            set extIn $::conf(extension,defaut)
         }

         set script "IMA/STACK . \"$imgList\" * * $extIn \"$dirOut\" \"$nameOut\" . $extOut $methode"
         if {$options ne ""} {append script " " $options}
         if {$::prtr::script eq "1"} {
            ::console::affiche_resultat "$script\n"
         }
         ttscript2 $script

         #--   detruit les fichiers temporaires
         if {[lsearch -regexp $imgList temp] >= "0"} {
            set script "IMA/SERIES . \"$imgList\" * * $extOut . . . . DELETE"
            if {$::prtr::script eq "1"} {
               ::console::affiche_resultat "$script\n"
            }
            ttscript2 $script
         }

      }  ErrInfo]
      if {$catchError eq "1"} {::prtr::Error "$ErrInfo"}
      return $catchError
   }

   #--------------------------------------------------------------------------
   #  ::prtr::faireFlat
   #--------------------------------------------------------------------------
   proc faireFlat { data options } {

      cd $::audace(rep_images)
      set extOut $::conf(extension,defaut)
      lassign $data imgList dirOut nameOut extIn
      set l [llength $imgList]

      #--   isole le nom complet de l'image d'offset et de dark
      foreach type {bias dark} {
        lassign [extractData $options "$type"] options $type
      }

      #--   cree l'image Offset+Dark si l'offset et/ou le dark existe
      if {$dark ne "" || $bias ne ""} {
         if {[createOffset+Dark $dark $bias] ne "0"} {return 1}

         set file Offset+Dark$extOut

         if {[file exists $file]} {
            if {[subsOffset+Dark $data $file] ne "0"} {return 1}

             #--   met a jour la liste des images a traiter
            set imgList [buildNewList temp $l]

            #--   extrait la valeur de normalisation de l'offset
            lassign [extractData $options "normoffset_value"] options opt

            #--   normalise l'offset
            set script "IMA/SERIES . \"$imgList\" * * $extOut . temp 1 $extOut NORMOFFSET normoffset_value=$opt"
            if {$::prtr::script eq "1"} {
               ::console::affiche_resultat "$script\n"
            }
            ttscript2 "$script"
            set extIn $extOut
         }
      }

      set catchError [catch {
         set script "IMA/STACK . \"$imgList\" * * $extOut \"$dirOut\" $nameOut . $extOut MED "
         if {$options ne ""} {append script "$options"}
         if {$::prtr::script eq "1"} {
            ::console::affiche_resultat "$script\n"
         }
         ttscript2 "$script"
         #--   supprime les fichiers intermediaires
         if {[lsearch -regexp $imgList temp] >= "0"} {
            set script "IMA/SERIES . \"$imgList\" * * $extOut . . . . DELETE"
            if {$::prtr::script eq "1"} {
               ::console::affiche_resultat "$script\n"
            }
            ttscript2 "$script"
         }
      }  ErrInfo]
      if {$catchError eq "1"} {::prtr::Error "$ErrInfo"}
      return $catchError
   }

   #--------------------------------------------------------------------------
   #  ::prtr::faireOptNoir
   #  Pretraitement avec optimisation du noir,
   #  suivi d'un division par le flat et d'une multiplication par la constante
   #--------------------------------------------------------------------------
   proc faireOptNoir { data options } {
      variable private

      cd $::audace(rep_images)
      set extOut $::conf(extension,defaut)
      lassign $data imgList dirOut nameOut extIn
      set l [llength $imgList]
      if {$l eq "1"} {
         lassign [list . . ] indexIn indexOut
      } else {
         lassign [list * 1 ] indexIn indexOut
      }

      #--   ote opt_black des options
      lassign [extractData $options "opt_black"] options opt

      #--   extrait le nom des fichiers operandes
      foreach type {bias dark flat} {
        lassign [extractData $options "$type"] options $type
      }

      set catchError [catch {
         #--   cree les images optimisees dans le repertoire de destination
         set script "IMA/SERIES . \"$imgList\" $indexIn $indexIn $extIn \"$dirOut\" $nameOut $indexOut $extOut OPT \"bias=$bias\" \"dark=$dark\" "
         if {$::prtr::script eq "1"} {
            ::console::affiche_resultat "$script\n"
         }
         ttscript2 "$script"
         #--   divise les images par le flat s'il existe et multiplie par la constante
         if {$flat ne ""} {

            #--   met a jour la liste des images a traiter
            set imgList [buildNewList $nameOut $l]

            #--   divise les images par le flat
            set script "IMA/SERIES \"$dirOut\" \"$imgList\" $indexIn $indexIn $extOut \"$dirOut\" $nameOut $extOut $extOut DIV \"file=$flat\" $options"
            if {$::prtr::script eq "1"} {
               ::console::affiche_resultat "$script\n"
            }
            ttscript2 "$script"
         }
      }  ErrInfo]
      if {$catchError eq "1"} {::prtr::Error "$ErrInfo"}
      return $catchError
   }

   #--------------------------------------------------------------------------
   #  ::prtr::fairePretraitement
   #  Prétraitement sans optimisation du noir
   #--------------------------------------------------------------------------
   proc fairePretraitement  { data options } {
      variable private

      cd $::audace(rep_images)
      set extOut $::conf(extension,defaut)
      lassign $data imgList dirOut nameOut extIn
      set l [llength $imgList]
      if {$l eq "1"} {
         lassign [list . . ] indexIn indexOut
      } else {
         lassign [list * 1 ] indexIn indexOut
      }

      #--   extrait le nom des fichiers operandes
      foreach type {bias dark flat} {
        lassign [extractData $options "$type"] options $type
      }

      if {$dark ne "" || $bias ne ""} {
         if {[createOffset+Dark $dark $bias] ne "0"} {return 1}
         set file Offset+Dark$extOut
         if {[file exists $file]} {

            if {[subsOffset+Dark $data $file] ne "0"} {return 1}

            #--   met a jour la liste des images a traiter
            set imgList [buildNewList temp $l]
            set extIn $extOut
         }
      }

      set catchError [catch {
         if {$flat ne ""} {

            #--   divise les images par le flat et multiplie par la constante
            set script "IMA/SERIES . \"$imgList\" $indexIn $indexIn $extIn \"$dirOut\" $nameOut $indexOut $extOut DIV \"file=$flat\" $options"
            if {$::prtr::script eq "1"} {
               ::console::affiche_resultat "$script\n"
            }
            ttscript2 "$script"

            #--   detruit les fichiers temporaires
            if {[lsearch -regexp $imgList temp] >= "0"} {
               set script "IMA/SERIES . \"$imgList\" $indexIn $indexIn $extIn . . . . DELETE"
               if {$::prtr::script eq "1"} {
                  ::console::affiche_resultat "$script\n"
               }
               ttscript2 "$script"
            }
         } else {
            #--   renomme les fichiers temp en l'absence de flat
            foreach file $private(todo) {
               regsub "temp" $file "$nameOut" newName
               file rename-force [file join $dir_out $file$ext_out] [file join $dir_out $newName$extOut]
            }
         }
       }  ErrInfo]

      if {$catchError eq "1"} {::prtr::Error "$ErrInfo"}
      return $catchError
   }

   #--------------------------------------------------------------------------
   #  ::prtr::createOffset+Dark
   #  Cree l'image Offset+Dark (non zippee) dans le repertoire audace(rep-images)
   #  a partir d'une image d'offset et/ou de dark (zippes ou non)
   #  Le dark et l'offset peuvent etre dans un repertoire different de audace(rep_images)
   #--------------------------------------------------------------------------
   proc createOffset+Dark { file1 file2 } {

      set catchError 0
      set nameOut "Offset+Dark"
      set extOut $::conf(extension,defaut)
      if {$file1 eq ""} {
         file copy -force $file2 [file join $::audace(rep_images) $nameOut$extOut]
      } elseif  {$file2 eq ""} {
         file copy -force $file1 [file join $::audace(rep_images) $nameOut$extOut]
      } else {
         #--   cas de deux fichiers
         set catchError [catch {
            set dir [file dirname $file1]
            set nameIn [file tail $file1]
            set script "IMA/SERIES \"$dir\" $nameIn . . . . $nameOut . $extOut ADD \"file=$file2\" "
            if {$::prtr::script eq "1"} {
               ::console::affiche_resultat "$script\n"
            }
            ttscript2 "$script"
         }  ErrInfo]
      }
      if {$catchError eq "1"} {::prtr::Error "$ErrInfo"}
      return $catchError
   }

   #--------------------------------------------------------------------------
   #  ::prtr::subsOffset+Dark
   #  Soustrait l'image 'file' de chaque image (zippee ou non)
   #  et stocke l'image produite dans audace(rep_images)
   #--------------------------------------------------------------------------
   proc subsOffset+Dark { data file } {

      set extOut $::conf(extension,defaut)
      lassign $data imgList dirOut nameOut extIn
      set index "."
      if {[llength $imgList] ne "1"} {set index 1}

      set catchError [catch {
         set script "IMA/SERIES . \"$imgList\" * * $extIn . temp $index $extOut SUB \"file=$file\" "
         if {$::prtr::script eq "1"} {
            ::console::affiche_resultat "$script\n"
         }
         ttscript2 "$script"
         #--   efface le fichier provisoire
         file delete $file
      }  ErrInfo]

      if {$catchError eq "1"} {::prtr::Error "$ErrInfo"}
      return $catchError
   }

   #--------------------------------------------------------------------------
   #  ::prtr::extractData
   #  Extrait une variable des options et met a jour les options
   #  Parametres : options globales, a extraire
   #--------------------------------------------------------------------------
   proc extractData { options what } {

      set extract [lsearch -regexp -inline $options "${what}="]
      set k [lsearch -regexp $options "$what"]
      set options [lreplace $options $k $k]
      regsub "${what}=" $extract "" extract
      return [list $options $extract]
   }

   #--------------------------------------------------------------------------
   #  ::prtr::buildNewList
   #  Renvoie une nouvelle liste d'images a traiter
   #  Parametres : nouveau nom, nb d'images
   #--------------------------------------------------------------------------
   proc buildNewList { newName l } {

      set newList ""
      if {$l eq "1"} {
         lappend newList $newName
      } else {
         for {set i 1} {$i <= $l} {incr i} {
            lappend newList $newName$i
         }
      }
      return $newList
   }

}

