#
# Fichier : prtr.tcl
# Description : Script dedie aux menus deroulants Images et Analyse --> Extraire
# Auteur : Raymond ZACHANTKE
# Mise à jour $Id$
#

#--   pour un acces plus rapide, liste des proc, hors dictionanires
   #  ::prtr::run nom_de_fonction
   #  ::prtr::createDialog
   #  ::prtr::configWindow
   #  ::prtr::changeOp visuNo
   #  ::prtr::buildParam_obligatoire
   #  ::prtr::buildParam_optionnel
   #  ::prtr::configZone w liste
   #  ::prtr::selectAll
   #  ::prtr::dispOptions w
   #  ::prtr::selectFiles row
   #  ::prtr::confBitPix
   #  ::prtr::updateTbl visuNo args
   #  ::prtr::analyseFitsHeader file
   #  ::prtr::configOutName
   #  ::prtr::configTableState w  etat
   #  ::prtr::getWidthHeight visuNo
   #  ::prtr::getCenterCoord
   #  ::prtr::updateBox visuNo args
   #  ::prtr::getFileName w nom_de_variable
   #  ::prtr::getDirName
   #  ::prtr::changeExtension visuNo args
   #  ::prtr::cmdApply tbl visuNo
   #  ::prtr::windowActive tbl {normal|disabled}
   #  ::prtr::compressFiles dirOut nameOut nb
   #  ::prtr::loadImg
   #  ::prtr::cmdOk tbl visuNo
   #  ::prtr::cmdClose visuNo
   #  ::prtr::widgetToConf
   #  ::prtr::confToWidget
   #  ::prtr::displayAvancement c
   #  ::prtr::avertiUser err args
   #  ::prtr::Error info
   #  ::prtr::afficheAide
   #  ::prtr::createCheckButton tbl row col w
   #  ::prtr::cmdVerif
   #  ::prtr::cmdTestVariable nom_du_parametre {1=obligatoire | 0=optionnel}
   #  ::prtr::getInfoFile file
   #  ::prtr::cmdExec data options
   #  ::prtr::traiteImg options p
   #  ::prtr::decompRGB file
   #  ::prtr::convertitRGB nameOut
   #  ::prtr::getImgType files
   #  ::prtr::convertBitPix2BitPix {8|16|+16|32|+32|-32|-64}
   #  ::prtr::clipMinMax data options
   #  ::prtr::cmdRot data options
   #  ::prtr::cmdMasqueFlou data options
   #  ::prtr::faireOffset data options
   #  ::prtr::faireDark data options
   #  ::prtr::faireFlat data options
   #  ::prtr::faireOptNoir data options
   #  ::prtr::fairePretraitement data options
   #  ::prtr::createOffset+Dark file1 file2
   #  ::prtr::subsOffset+Dark data file
   #  ::prtr::editScript script
   #  ::prtr::extractData options what
   #  ::prtr::buildNewList newName l
   #  ::prtr::informeUser v1 v2
   #  ::prtr::cmdAligner data options
   #  ::prtr::searchMax box buf

namespace eval ::prtr {

   #--------------------------------------------------------------------------
   #  ::prtr::run nom_de_fonction
   #  Liste les operations proposees dans le bouton de menu de la fenetre
   #--------------------------------------------------------------------------
   proc run {oper} {
      variable private
      global audace conf

      set visuNo $audace(visuNo)
      set ::prtr::operation $oper
      set private(inVisu) ""
      set private(profil) ""

      ::prtr::searchFunction $oper
      ::prtr::getTypeVar

      if {![ winfo exists $audace(base).prtr]} {
         #--   surveille le changement de fonction
         trace add variable "::prtr::operation" write "::prtr::changeOp $visuNo"
         #--   surveille le changement de repertoire
         trace add variable "::audace(rep_images)" write "::prtr::updateTbl $visuNo"
         #--   surveille le chargement d'une image
         trace add variable "::confVisu::private($visuNo,lastFileName)" write "::prtr::updateTbl $visuNo"
         #--   surveille le changement d'extension
         trace add variable "::conf(extension,defaut)" write "::prtr::changeExtension $visuNo"
         #--   surveille le changement de compression
         trace add variable "::conf(fichier,compres)" write "::prtr::changeExtension $visuNo"

         set private(lineHeight) 40
         set private(minWidth) 550
         set private(minHeight) 404

         #--   intialise la variable si elle n'existe pas
         if {![info exists conf(prtr,geometry)]} {
            set conf(prtr,geometry) "${private(minWidth)}x${private(minHeight)}+350+75"
         }

         set private(this) "$audace(base).prtr"
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
      set ::prtr::all         "0"   ; # booleen, sélection des images
      set ::prtr::ttoptions   "0"   ; # booleen, affichage des options
      set ::prtr::disp        "1"   ; # booleen, affichage de la derniere image
      set ::prtr::script      "0"   ; # booleen, edition ud script
      set ::prtr::out         "./"  ; # nom de sortie
      set private(fun_lignes) "0"

      toplevel $This
      wm resizable $This 1 1
      #--   pm la geometrie est fixee ::prtr::confToWidget
      set height $private(minHeight)
      wm minsize $private(this) $private(minWidth) $height
      wm transient $This $audace(base)
      wm geometry $private(this) $conf(prtr,geometry)
      wm protocol $This WM_DELETE_WINDOW "::prtr::cmdClose $visuNo"

      frame $This.usr -borderwidth 0 -relief raised
      pack $This.usr -fill both -expand 1

      frame $This.usr.select -height 40
      #--   configure la fenetre
      ::prtr::configWindow
      pack $This.usr.select -side top -fill x -expand 0

      frame $This.usr.choix
      set tbl $This.usr.choix.tablelist
      set private(tbl) $tbl
      scrollbar $This.usr.choix.vscroll -command "$tbl yview" -width 18

      frame $This.usr.table
      set this [blt::table $This.usr.table]
      set private(table) $this
      foreach fr {all sortie affiche edit info cmd} {
         frame $this.$fr -borderwidth 1 -relief raised
      }

      scrollbar $this.hscroll -orient horizontal -command "$tbl xview"
      pack $this.hscroll -side left -anchor w
      frame $this.nihil -width 18
      pack $this.nihil -side right -anchor e

      #---  le check bouton pour selectionner tout
      checkbutton $this.all.select -variable ::prtr::all \
         -text "$caption(prtr,select_all)" -command "::prtr::selectAll"
      pack $this.all.select -side left -padx 10 -pady 5

      #---  frame pour le fichier de sortie
      LabelEntry $this.sortie.out \
         -label "$caption(prtr,image_sortie)" -labelanchor w \
         -labelwidth [string length "$caption(prtr,image_sortie)"]\
         -textvariable ::prtr::out -padx 10 -justify center
      pack $this.sortie.out -side left -padx 5 -pady 5 -fill x -expand 1

      button $this.sortie.explore -text "$caption(prtr,parcourir)" \
         -width 1 -command "::prtr::getDirName"
      pack $this.sortie.explore -side left -pady 5 -ipady 5 \
         -padx [$This.usr.choix.vscroll cget -width] -pady 5 -ipady 5

      #---  le check bouton pour l'affichage
      checkbutton $this.affiche.disp -variable ::prtr::disp \
         -text "$caption(prtr,afficher_image_fin)"
      pack $this.affiche.disp -side left -padx 10 -pady 5

      #---  le check bouton pour l'edition du script
      checkbutton $this.affiche.script -variable ::prtr::script \
         -text "$caption(prtr,afficher_script)"
      pack $this.affiche.script -side left -padx 10 -pady 5 -expand yes


      #---  frame pour l'affichage du deroulement du traitement
      label $this.info.labURL1 -textvariable ::prtr::avancement -fg $color(blue)
      pack $this.info.labURL1 -side top -padx 10 -pady 5

      #---  les commandes habituelles
       button $this.cmd.ok -text "$caption(prtr,ok)" \
         -command "::prtr::cmdOk $tbl $visuNo"
      if {$conf(ok+appliquer) eq 1} {
         pack $this.cmd.ok -side left -padx 3 -pady 3 -ipadx 25 -ipady 5
      }
      button $this.cmd.appliquer -text "$caption(prtr,appliquer)" \
         -command "::prtr::cmdApply $tbl $visuNo"
      pack $this.cmd.appliquer -side left -padx 3 -pady 3 -ipadx 5 -ipady 5
      button $this.cmd.fermer -text "$caption(prtr,fermer)" \
         -command "::prtr::cmdClose $visuNo"
      pack $this.cmd.fermer -side right -padx 3 -pady 3 -ipadx 5 -ipady 5
      button $this.cmd.aide -text "$caption(prtr,hlp_function)"\
         -command "::prtr::afficheAide"
      pack $this.cmd.aide -side right -padx 3 -pady 3 -ipadx 5
      button $this.cmd.hlp -text "$caption(prtr,hlp_gene)" \
         -command "::audace::showHelpItem \"$::audace(rep_doc_html)/french/05images\" \"1010images.htm\""
      pack $this.cmd.hlp -side right -padx 3 -pady 3 -ipadx 5

      #--- positionne les elements dans la table
      blt::table $this \
         $this.hscroll 1,0 -fill both -height {18} \
         $this.nihil 1,1 \
         $this.all 2,0 -fill both -cspan 2 -height {34} \
         $this.sortie 5,0 -fill both -cspan 2 -height {34} \
         $this.affiche 6,0 -fill both -cspan 2 -height {34} \
         $this.info 7,0 -fill both -cspan 2 -height {34} \
         $this.cmd 8,0 -fill both -cspan 2 -height {50}
      pack $this -in $This.usr -side bottom -fill both -expand 0
      blt::table configure $this c1 -width 18 -resize none

      #--- definit la structure et les caracteristiques
      ::tablelist::tablelist $tbl -borderwidth 2 \
         -columns [list \
            4 "" center \
            0 $caption(prtr,src) left \
            0 $caption(prtr,type) center \
            0 $caption(prtr,dimension) center] \
         -xscrollcommand [list $this.hscroll set] \
         -yscrollcommand [list $This.usr.choix.vscroll set] \
         -exportselection 0 -setfocus 1 \
        -activestyle none -stretch {1}

      #--- place la table et le vscrollbar dans la frame
      pack $tbl -anchor w -side left -fill both -expand 1
      pack $This.usr.choix.vscroll -side right -anchor e -fill y
      pack $This.usr.choix -side top -fill both -expand 1

      #--   remplit la tablelist
      ::prtr::updateTbl $visuNo

      #--- selectionne le traitement
      set i [lsearch -exact $private(fonctions) $::prtr::operation]
      incr i
      $This.usr.select.but.menu invoke $i

      bind $This <Key-Return> [list ::prtr::cmdOk $tbl $visuNo]
      bind $This <Key-Escape> [list ::prtr::cmdClose $visuNo]
      bind $This <Key-F1> {::console::GiveFocus}

      #--- Focus
      focus $This

      #--- Mise a jour dynamique des couleurs
      ::confColor::applyColor $This
   }

   #--------------------------------------------------------------------------
   #  ::prtr::configWindow
   #  Gere le titre de la fenetre, le libelle et le bouton de menu
   #  Lancee par ::prtr::createDialog et par ::prtr::changeOp
   #--------------------------------------------------------------------------
   proc configWindow {} {
      variable private
      global caption

      switch -regexp $private(ima) {
         ARIHTM      { set titre "$caption(audace,menu,images) - $caption(audace,menu,arithm)"}
         CENTER      { set titre "$caption(audace,menu,images) - $caption(audace,menu,center)"}
         EXTRACT     { set titre "$caption(audace,menu,analysis) - $caption(audace,menu,extract)"}
         FILTER      { set titre "$caption(audace,menu,images) - $caption(audace,menu,filter)"}
         GEOMETRY    { set titre "$caption(audace,menu,images) - $caption(audace,menu,geometry)"}
         IMPROVE     { set titre "$caption(audace,menu,images) - $caption(audace,menu,improve)"}
         MAITRE      { set titre "$caption(audace,menu,images) - $caption(audace,menu,maitre)"}
         PRETRAITEE  { set titre "$caption(audace,menu,images) - $caption(audace,menu,pretraitee)"}
         ROTATION    { set titre "$caption(audace,menu,images) - $caption(audace,menu,geometry)"}
         TRANSFORM   { set titre "$caption(audace,menu,images) - $caption(audace,menu,transform)"}
         STACK       { set titre "$caption(audace,menu,images) - $caption(audace,menu,pile)"}
         default     { set titre "$caption(audace,menu,images) - $caption(audace,menu,[string tolower $private(ima)])"}
      }
      wm title $private(this) "$titre"

      #--   detruit le libelle et bouton de menu
      set this $private(this).usr.select
      if {[winfo exists $this]} {destroy $this.lbl $this.but}

      #--   selectionne le libelle apparaissant a cote du bouton de menu
      if {$private(ima) eq "PILE" || $private(ima) eq "MAITRE" || $private(ima) eq "CENTER" } {
         set texte "$::caption(prtr,operation_lot)"
      } else {
         set texte "$::caption(prtr,operation_disk)"
      }
      label $this.lbl -text $texte
      pack $this.lbl -side left -padx 10 -pady 10

      #--- cherche la longueur maximale du libelle des formules
      #--- pour dimensionner la largeur du bouton de menu
      set bwidth "0"
      foreach formule $private(fonctions) {
         set bwidth [expr {max([string length $formule],$bwidth)}]
      }
      if {$bwidth < "20"} {set bwidth 20}

      menubutton $this.but -relief raised -width $bwidth -borderwidth 2 \
         -textvariable ::prtr::operation -menu $this.but.menu

      #--- menu du bouton
      set m [menu $this.but.menu -tearoff "1"]
      foreach form $private(fonctions) {
         $m add radiobutton -label "$form" -value "$form" \
            -variable ::prtr::operation
      }
      pack $this.but -side right -padx 18 -pady 10

      #--- Mise a jour dynamique des couleurs
      ::confColor::applyColor $private(this)
   }

   #--------------------------------------------------------------------------
   #  ::prtr::changeOp visuNo
   #  Au lancement d'une fonction, extrait le nom de la fonction TT, la liste
   #  des parametres obligatoires et optionnels, les coordonnees de la doc,
   #  Lancee par trace variable ::prtr::operation
   #--------------------------------------------------------------------------
   proc changeOp {visuNo args} {
      variable private

      #--   cherche le nouveau dictionnaire
      ::prtr::searchFunction $::prtr::operation
      #--   configure la fenetre
      ::prtr::configWindow

      #--   detruit les zones, les widgets et les variables
      destroy $private(table).lbl
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

      #--   force la maj de la liste des fichiers (du fait des images wcs)
      ::prtr::updateTbl $visuNo

      ::prtr::configOutName

      #--   initialise les compteurs de lignes
      set private(fun_lignes) 0
      set private(tt_lignes) 1

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

      if {$private(function) in {WINDOW MATRIX}} {
         #--   surveille le dessin d'une boite de selection
         trace add variable "::confVisu::private($visuNo,boxSize)" write "::prtr::updateBox $visuNo"
      } else  {
         if {[trace info variable "::confVisu::private($visuNo,boxSize)"] ne ""} {
            trace remove variable "::confVisu::private($visuNo,boxSize)" write "::prtr::updateBox $visuNo"
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

      frame $w -borderwidth 1 -relief raised
      #--   la case du titre
      label $w.label  -text "$::caption(prtr,param)"
      set private(fun_lignes) [::prtr::configZone $w obligatoire]
      grid $w.label -row 0 -column 0 -padx 10 -pady 5 -rowspan $private(fun_lignes)
      blt::table $private(table) $w 3,0 -fill both -cspan 2 \
        -height [list [expr {$private(fun_lignes)*$private(lineHeight)}]]

      #--   modifie les variables initiales
      if {$private(inVisu) ne ""} {
         if {"x0" in $obligatoire || "xcenter" in $obligatoire} {
            ::prtr::getCenterCoord
         }

         if {"x2" in $obligatoire && "y2" in $obligatoire} {
            if {[ ::confVisu::getBox $visuNo ] ne ""} {
               #--   affiche les coordonnees de la box
               ::prtr::updateBox $visuNo
            }
         }
         if {$private(function) == "RESIZE"} {
            ::prtr::getWidthHeight $visuNo
         }
      }

      #--- Mise a jour dynamique des couleurs
      ::confColor::applyColor $private(this)
   }

   #--------------------------------------------------------------------------
   #  ::prtr::buildParam_optionnel
   #  Configure la zone des options
   #--------------------------------------------------------------------------
   proc buildParam_optionnel {w visuNo} {
      variable private

      #--   premiere construction
      if {![winfo exists $w]} {
         frame $w -borderwidth 1 -relief raised
         checkbutton $w.che -indicatoron 1 -offvalue 0 -onvalue 1 \
            -variable ::prtr::ttoptions -text "$::caption(prtr,options)" \
            -command "::prtr::dispOptions $w"
         grid $w.che -row 0 -column 0 -padx 10 -pady 5 -rowspan 1
      }
      ::prtr::confBitPix
      ::prtr::dispOptions $w
   }

   #--------------------------------------------------------------------------
   #  ::prtr::configZone w liste
   #  Selectionne le widget a appliquer a une variable
   #  Parametres : nom du parent, nom de la liste (obligatoire ou optionnel)
   #--------------------------------------------------------------------------
   proc configZone { w liste } {
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
               if {$valuewidth < "8"} {set valuewidth 9}
               LabelEntry $w.$child -label "$child" -labelanchor e \
                  -labelwidth $labelwidth -textvariable ::prtr::$child \
                  -padx $d -width $valuewidth -justify center
               grid $w.$child -row $row -column $col -padx $d -pady 5 -sticky e
               if {$child in {file bias dark flat image_ref}} {
                  $w.$child configure -width 30
                  incr col
                  button $w.explore_$child -text "$::caption(prtr,parcourir)" -width 1 \
                     -command "::prtr::getFileName $w $child"
                  grid $w.explore_$child -row $row -column $col -padx $d -pady 5
               }
            }
            "radiobutton" {
               if {![winfo exists $w.$child]} {
                  frame $w.$child
                  label $w.$child.label -text "$::caption(prtr,$child)"
                  pack $w.$child.label -side left
                  switch -exact $child {
                     "methode"   {  foreach radio {somme moyenne mediane} function {ADD MEAN MED} {
                                       radiobutton $w.$child.$radio -text "$::caption(audace,menu,$radio)" \
                                          -indicatoron 1 -variable ::prtr::${child} -value $function
                                       pack $w.$child.$radio -side left -expand 1
                                    }
                                 }
                     "plan"      {  foreach radio {r g b} {
                                       radiobutton $w.$child.$radio -text "$::caption(prtr,$child,$radio)" \
                                          -indicatoron 1 -variable ::prtr::${child} -value $radio
                                       pack $w.$child.$radio -side left -expand 1
                                    }
                                 }
                  }
                  grid $w.$child -row $row -column $col -columnspan 2 -padx $d -pady 5 -sticky ew
               }
               incr col "1"
            }
            "combobox"     {
               set bitpixValues  [list 8 16 +16 32 +32 -32 -64]
               set kernel_widthValues  [list 3 5 7 9 11 13 15 17 19 21]
               set kernel_coefValues  [list 0 0.1 0.2 0.3 0.4 0.5 0.6 0.7 0.8 0.9 1]
               set type_thresholdValues  [list -1 0 +1]
               set translateValues [list after before never only]
               set height [llength [set ${child}Values]]
               frame $w.combo$child
               label $w.combo$child.lbl_$child -text "$child" -width $labelwidth
               ComboBox $w.combo$child.$child -textvariable ::prtr::$child -relief sunken \
                  -width 6 -height $height -values [set ${child}Values]
               button $w.combo$child.aide -text "?" -width 2 \
                  -command "::prtr::afficheAideBitpix"
               pack $w.combo$child.lbl_$child $w.combo$child.$child $w.combo$child.aide -side left
               grid $w.combo$child -row $row -column $col -padx $d -pady 5 -sticky e
               #--   retablit la valeur par defaut de bitpix
               if {$child eq "bitpix"} {
                  ::prtr::confBitPix
                  set k [lsearch [$w.combo$child.$child cget -values] $::prtr::bitpix]
                  $w.combo$child.$child setvalue @$k
               }
            }
         }
         #--   memorise le nb de lignes
         set lignes $row
         incr col
         if {$col > $nb_max} {
            incr row
            set col "1"
         }
      }

      grid columnconfigure $w 1 -minsize 120 -weight 1
      grid columnconfigure $w 2 -weight 1
      grid columnconfigure $w 3 -minsize [$private(this).usr.choix.vscroll cget -width]
      incr lignes
      return $lignes
   }

   #--------------------------------------------------------------------------
   #  ::prtr::selectAll
   #  Selectionne/deselectionne tous les checkbuttons de la tablelist
   #  Commande du checkbutton "Sélectionner tout"
   #--------------------------------------------------------------------------
   proc selectAll { } {
      variable private

      #--   arrete si fonction d'extraction sur une image unique ou aucune selection
      if {$::prtr::operation in [list $::caption(audace,menu,ligne) $::caption(audace,menu,colonne) \
            $::caption(audace,menu,matrice)] || $private(profil) eq ""} {
         return
      }

      set tbl $private(tbl)
      set size [$tbl size]
      if {$::prtr::all == 0} {
         set cmd deselect
      } else {
         set cmd select
      }
      for {set row 0} {$row <= $size} {incr row} {
         #--   cherche le contenu
         set content "[lrange [$tbl get $row] 2 end]"
         #--   compare le contenu au profil
         if {[ string match $content  $private(profil)]} {
            #--   selectionne l'image de profil identique a celui de la premiere image
            [$tbl windowpath $row,0] $cmd
         }
      }
      ::prtr::selectFiles 0
   }

   #--------------------------------------------------------------------------
   #  ::prtr::dispOptions w
   #  Commande du checkbutton pour afficher les options
   #--------------------------------------------------------------------------
   proc dispOptions { w } {
      variable private

      if {$::prtr::ttoptions == "1"} {
         set private(tt_lignes) [::prtr::configZone $w optionnel]
      } else {
         set children [lreplace [winfo children "$w"] 0 0]
         destroy {*}$children
         #--   il y a toujours au moins une ligne
         set private(tt_lignes) "1"
      }
      ::prtr::confToWidget

      blt::table $private(table) $w 4,0 -fill both -cspan 2 \
            -height [list [expr {$private(tt_lignes)*$private(lineHeight)}]]

      #--- Mise a jour dynamique des couleurs
      ::confColor::applyColor $private(this)
   }

   #--------------------------------------------------------------------------
   #  ::prtr::selectFiles row
   #  Rafraichit la liste des fichiers selectionnes
   #  Lancee lors de la construction de la fenetre et
   #  par la selection d'une image dans la table
   #--------------------------------------------------------------------------
   proc selectFiles { row } {
      variable bd
      variable private
      global caption

      set tbl $private(tbl)

      #--   arrete si le repertoire est vide
      if {[$tbl cellcget 0,1 -text] eq "$caption(prtr,no_file)" } {return}

      #--   recommence la liste
      set private(todo) ""

      #--   identifie le profil de l'image selectionnee
      set profil [lrange [$tbl get $row] 2 end]

      #--   cree un profil referent avec la premiere image selectionnee
      if {$private(profil) eq "" || $private(profil) ne "" && $private(profil) ne "$profil"} {
         set private(profil) $profil
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
            set select_state $::prtr::private(file_$row)
            if {$function_type == 1} {
               #--   pour ces fonctions on ne peut selectionner qu'une seule image
               if {$select_state eq "0"} {
                  $w deselect
                  $w configure -state disabled
               } else {
                  lappend private(todo) [$tbl cellcget $row,1 -text]
               }
            } else {
               #--   pour ces fonctions on peut selectionner plusieurs images
               set match_profil [string match $private(profil) [lrange [$tbl get $row] 2 end]]
               if {$match_profil == "0"} {
                  $w deselect
                  $w configure -state disabled
               } else {
                  if {$select_state == "1"} {
                     lappend private(todo) [$tbl cellcget $row,1 -text]
                  }
               }
            }
         }
      }

      #--   autorise toutes les selections si la liste est vide
      if {$private(todo) eq ""} {
         foreach file $private(listFiles) {
            [$tbl windowpath $file,0] configure -state normal
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
         set k [lsearch [$private(table).ttoptions.combobitpix.bitpix cget -values] $::prtr::bitpix]
         $private(table).ttoptions.combobitpix.bitpix setvalue @$k
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
   #  ::prtr::updateTbl visuNo args
   #  Rafraichit la tablelist
   #  Lancee lors de la construction de la fenetre, apres execution d'une commande
   #  et au changement de repertoire images
   #--------------------------------------------------------------------------
   proc updateTbl { visuNo args} {
      variable private
      variable bd

      set w $private(tbl)
      set dir $::audace(rep_images)

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
         if {$::prtr::operation eq "$::caption(audace,menu,reg_wcs)" && [lindex $result 8] == "0"} {
            #--   filtre les images non wcs
            set result ""
         }
         if {$result ne ""} {
            regsub "$::prtr::ext" [file tail $file] "" nom_court
            array set bd [list $nom_court $result]
         }
      }

      #--   rafraichit la tablelist
      set private(listFiles) [lsort -dictionary [ array names bd]]
      set private(size) [llength $private(listFiles)]

      #--   arrete si la bd est vide et que le répertoire n'est pas vide
      ::prtr::configTableState $w normal
      if {$private(size) == "0"} {return}

      set nb 0
      foreach cible $private(listFiles) {
         foreach {naxis naxis3 naxis1 naxis2} [lindex [array get bd $cible] 1] {break}
         if {$naxis eq 2} {set type "M"} else {set type "C"}
         if {$type eq "M" || ($type eq "C" && $private(ima) ni {MAITRE PRETRAITEE})} {
            $w insert end [list "" "$cible" "$type" "${naxis1} X ${naxis2}"]
            $w cellconfigure end,0 -window "::prtr::createCheckButton"
            $w configrows $nb -name "$cible"
            [$w windowpath $cible,0] deselect
            incr nb
         }
      }

      set private(size) $nb
      if {$private(size) == "0"} {return}

      set img  [::confVisu::getFileName $visuNo]
      if {[file exists $img]} {
         #--   image dans la visu
         lassign [::prtr::getInfoFile $img] dir nom
         set row [lsearch [$w getcolumns 1] $nom]
         if {$row ne "-1"} {
            set private(inVisu) $nom
            $w seecell $row,0
            [$w windowpath $nom,0] invoke
         }
      } else {
         #--   pas image dans la visu
         if {[info exists private(lastImage)]} {
            lassign [getInfoFile $private(lastImage)] dir nom
            unset private(lastImage)
            set row [lsearch [$w getcolumns 1] $nom]
            if {$row ne "-1"} {
               $w seecell $row,0
               [$w windowpath $nom,0] invoke
             }
         }
      }

      #--- Mise a jour dynamique des couleurs
      ::confColor::applyColor $private(this)
   }

   #--------------------------------------------------------------------------
   #  ::prtr::analyseFitsHeader file (nom complet)
   #  Retourne les caracteristiques d'une image ou rien (si erreur)
   #--------------------------------------------------------------------------
   proc analyseFitsHeader { file } {
      variable private

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
            #--   test wcs
            set wcs_kwd [list crota2 cd1_1 cd1_2 cd2_1 cd2_2 cdelt1 cdelt2 dec foclen pixsize1 pixsize2 ra]
            #--   test la presence des mot-cles
            foreach var $wcs_kwd {
               set $var 0
               set value [lindex [array get kwds [string toupper $var]] 1]
               if {$value ne ""} {set $var 1}
            }

            set wcs 0
            if {(($cd1_1 && $cd1_2 && $cd2_1 && $cd2_2) || ($cdelt1 && $cdelt2 && $crota2 ) || \
               ($foclen && $pixsize1 && $pixsize2 && $ra && $dec && $crota2))== "1"} {
                  set wcs 1
            }

            #--   affecte les valeurs aux variables
            foreach var {bitpix bzero crpix1 crpix2 mean naxis naxis1 naxis2 naxis3} {
               set $var [lindex [array get kwds [string toupper $var]] 1]
            }
            if {[info exists bzero] && $bzero ne ""} {set bitpix "$bitpix"}
            array unset kwds
            if {$naxis eq "2" || $naxis eq "3"} {
               #--   si CRPIX1 et CRPIX2 indefinis, calcule le centre de l'image
               if {$crpix1 eq "" || $crpix2 eq ""} {
                  set crpix1 [expr {$naxis1/2}]
                  set crpix2 [expr {$naxis2/2}]
               }
               #-- rajout de l'indicateur wcs
               set result [list $naxis $naxis3 $naxis1 $naxis2 $bitpix $crpix1 $crpix2 $mean $wcs]
            }
         }
      }
      if {$result eq ""} {
         set bad [info exists private(bad_file)]
         if {$bad == "0" || ($bad == "1" && $file ni $private(bad_file))} {
            ::console::affiche_erreur "$file $::caption(prtr,err_file_header) $::errorInfo\n\n"
            lappend private(bad_file) "$file"
         }
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
   #  ::prtr::configTableState w  etat
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
      $private(table).cmd.fermer configure -state $etat
   }

   #--------------------------------------------------------------------------
   #  ::prtr::getWidthHeight
   #  Affiche les dimensions d el'image
   #  Lancee lors de la construction de l'activation de RESIZE
   #--------------------------------------------------------------------------
   proc getWidthHeight { $visuNo } {
      variable private
      variable bd

      #--   cherche les info dans bd
      lassign [lindex [array get bd [lindex $private(todo) 0]] 1] -> -> width height

      set ::prtr::width  $width
      set ::prtr::height $height
   }

   #--------------------------------------------------------------------------
   #  ::prtr::getCenterCoord
   #  Affiche les coordonnees du centre
   #  Lancee lors de la construction de l'activation d'une fonction avec centre
   #--------------------------------------------------------------------------
   proc getCenterCoord { } {
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
            x0       {set ::prtr::x0       $crpix1   ; #-- ROT REC2POL POL2REC}
            y0       {set ::prtr::y0       $crpix2   ; #-- ROT REC2POL POL2REC}
            xcenter  {set ::prtr::xcenter  $crpix1   ; #-- RGRADIENT RADIAL}
            ycenter  {set ::prtr::ycenter  $crpix2   ; #-- RGRADIENT RADIAL}
            default  {}
         }
      }
   }

   #--------------------------------------------------------------------------
   #  ::prtr::updateBox visuNo args
   #  Affiche les coordonnees de la box dans x1 y1 x2 y2
   #  Lancee lors de la construction, de l'activation de la fonction de recadrage
   #  ou lors du dessin/effacement d'une boite de selection
   #--------------------------------------------------------------------------
   proc updateBox {visuNo args} {
      variable private
      variable bd

      #--   arrete si pas fonction avec une box
      #if {$private(function) ni {WINDOW MATRIX}} {return}

      set box  [::confVisu::getBox $visuNo]
      if {$box eq ""} {
         #--   les valeurs par defaut des fonctions a la box
         regsub -all {x1|y1|x2|y2} $private(l_obligatoire) "" box
      }

      foreach {::prtr::x1 ::prtr::y1 ::prtr::x2 ::prtr::y2} $box {break}
   }

   #--------------------------------------------------------------------------
   #  ::prtr::getFileName w nom_de_variable
   #  Ouvre un explorateur pour choisir une image operande
   #  Produit ::prtr::nom_de_variable
   #--------------------------------------------------------------------------
   proc getFileName { w var } {
      variable private

      #--   ouvre la fenetre de choix des images
      set file [::tkutil::box_load $private(this) $::audace(rep_images) $::audace(bufNo) "1"]

      #--   arrete si pas de selection
      if {$file eq ""} {return}

      #--   decompose le nom en dir nom_court et extension(s)
      lassign [::prtr::getInfoFile $file] dir nom_court ext

      #--   verifie que l'extension est identique a celle des fichiers traites
      if {$ext ne "$::prtr::ext"} {
         return [::prtr::avertiUser err_file_ext $ext $::prtr::ext]
      }

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
   #  ::prtr::getDirName
   #  Capture le nom d'un repertoire
   #  Commande du bouton "..." de saisie du nom générique de sortie
   #--------------------------------------------------------------------------
   proc getDirName { } {
      variable private

      set dirname [tk_chooseDirectory -title "$::caption(prtr,outfolder)" \
         -initialdir $::audace(rep_images)]

      if {$dirname eq "" || $dirname eq "$::audace(rep_images)"} {
         set dirname "./"
      }
      if {$dirname ne "" && [string index $dirname end] ne "/"} {
         append dirname "/"
      }

      set ::prtr::out $dirname
      $private(table).sortie.out.e xview end
   }

   #--------------------------------------------------------------------------
   #  ::prtr::changeExtension visuNo args
   #  Trace les options d'extension
   #--------------------------------------------------------------------------
   proc changeExtension {visuNo args} {
      variable private

      set ::prtr::ext $::conf(extension,defaut)
      #--   rajoute l'extension de compression
      if {$::conf(fichier,compres) eq "1"} {
         append ::prtr::ext ".gz"
      }
      set private(profil) ""
      if {[info exists private(table)]} {::prtr::updateTbl $visuNo}
   }

   #--------------------------------------------------------------------------
   #  ::prtr::cmdApply tbl visuNo
   #  Procedure du bouton Appliquer
   #  Retourne 0 si la verification a echoue, 1 si la procedure a ete a son terme
   #--------------------------------------------------------------------------
   proc cmdApply { tbl visuNo } {
      variable private
      variable bd

      #--   arrete si une erreur ou un oubli
      set opt [::prtr::cmdVerif]
      #--   pour bloquer la fermeture de la fenêtre dans ::prtr::cmdOk
      if {$opt eq 0} {return 1}

      #--   inhibe toutes les zones sensibles
      ::prtr::windowActive $tbl disabled

      set dir "$::prtr::dir_out"
      set generique  "$::prtr::generique"
      set imgList "$private(todo)"
      set nbImg [llength $imgList]
      set data [list "$imgList" "$dir" "$generique" "$::prtr::ext"]

      #--   selectionne la fonction a activer
      switch -exact $private(function) {
         "BIAS"            {  set private(error) [::prtr::faireOffset $data $opt]}
         "CENTER"          {  set private(error) [::prtr::cmdAligner $data $opt]}
         "CLIP"            {  set private(error) [::prtr::clipMinMax $data $opt]}
         "DARK"            {  lappend data $prtr::methode
                              set private(error) [::prtr::faireDark $data $opt]}
         "FLAT"            {  set private(error) [::prtr::faireFlat $data $opt]}
         "FLOU"            {  set private(error) [::prtr::cmdMasqueFlou $data $opt]}
         "PRETRAITEMENT"   {  if {$::prtr::opt_black eq "1"} {
                                 set private(error) [::prtr::faireOptNoir $data $opt]
                              } else {
                                 set private(error) [::prtr::fairePretraitement $data $opt]
                              }
                           }
         "ROT+90"          {  lappend data "$private(function)"
                              set private(error) [::prtr::cmdRot $data $opt]
                           }
         "ROT-90"          {  lappend data "$private(function)"
                              set private(error) [::prtr::cmdRot $data $opt]
                           }
         "ROT180"          {  lappend data "$private(function)"
                              set private(error) [::prtr::cmdRot $data $opt]
                           }
         "ROTENTIERE"      {  set data [concat \"IMA/SERIES\" $data]
                              lappend data "$private(function)"
                              set info [lindex [array get bd [lindex $private(todo) 0]] 1]
                              set x0 [expr {[lindex $info 2]/2.}]
                              set y0 [expr {[lindex $info 3]/2.}]
                              set opt [linsert $opt 0 "x0=$x0" "y0=$y0"]
                              set private(error) [::prtr::cmdExec $data $opt]
                           }
         default           {  switch $private(ima) PILE {set appl "IMA/STACK"} default {set appl "IMA/SERIES"}
                              set data [linsert $data 0 $appl]
                              lappend data "$private(function)"
                              set private(error) [::prtr::cmdExec $data $opt]
                           }
      }

      #--   post traitement
      if {$private(error) eq "0"} {

         set ext "$::conf(extension,defaut)"
         if {$dir eq "." || $dir eq "./"} {set dir $::audace(rep_images)}

         #--   image de reference en plus dans ce cas
         if {$private(function) eq "CENTER"} {incr nbImg}

         #--   ces fonctions ne produisent qu'une image
         if {$private(ima) in [list MAITRE PILE] || $nbImg eq "1"} { set nbImg "1"}

         #--   designe l'image a afficher
         if {$nbImg eq "1"} {
            set lastImage [file join "$dir" $generique$ext]
         } else {
            set lastImage [file join "$dir" $generique$nbImg$ext]
         }

         #--   compresse les images
         if {$::conf(fichier,compres) eq "1"} {
             ::prtr::compressFiles "$dir" "$generique" $nbImg
             append lastImage ".gz"
         }

         #--  charge la derniere image si demande
         set private(lastImage) $lastImage
         if {$::prtr::disp eq 1} {::prtr::loadImg}
      }

      ::prtr::updateTbl $visuNo

      #--   desinhibe les zones sensibles
      ::prtr::windowActive $tbl normal

      #--   evite une erreur si appuie sur Fermer avant la fin
      if {![info exists private(error)]} {
         set private(error) 0
      }
      return $private(error)
   }

   #--------------------------------------------------------------------------
   #  ::prtr::windowActive tbl {normal|disabled}
   #  Active/desactive les zones sensibles de la fenetre
   #  Lancee par ::prtr::cmdApply
   #--------------------------------------------------------------------------
   proc windowActive {tbl etat} {
      variable private

      set this $private(table)

      #--   inhibe/desinhibe tous les checkbutton et le nom de sortie
      set children [list "all.select" "affiche.disp" "affiche.script" "sortie.out"]
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
               #--   liste les descendants
               set children [winfo children $this.$fr]
               #--   liste les descendants dans une ComboBox
               set comboList [lsearch -regexp -all -inline $children "combo*"]
               #--   extrait le nom des combo
               regsub -all "$this.$fr.combo" $comboList "" descendants
               foreach descendant $descendants {
                  set k [lsearch $children "$this.$fr.combo$descendant"]
                  set children [lreplace $children $k $k "$this.$fr.combo$descendant.$descendant"]
               }
               if {"$this.$fr.methode" in $children} {
                  set k [lsearch $children "$this.$fr.methode"]
                  set children [lreplace $children $k $k]
                  set children [concat $children "$this.$fr.methode.somme" \
                     "$this.$fr.methode.moyenne" "$this.$fr.methode.mediane"]
               } elseif {"$this.$fr.plan" in $children} {
                  set k [lsearch $children "$this.$fr.plan"]
                  set children [lreplace $children $k $k]
                  set children [concat $children "$this.$fr.plan.label" "$this.$fr.plan.r" \
                     "$this.$fr.plan.g" "$this.$fr.plan.b"]
               }
               set private(frames) [concat $private(frames) $children]
            }
         }
      }

      #--   inhibe/desinhibe tous les frames
      foreach frame $private(frames) {$frame configure -state $etat}

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
         foreach file $private(listFiles) {
            if {![info exists private(disabled)]} {
               set state $etat
            } else {
               if {[$tbl windowpath $file,1] ni $private(disabled)} {
                  set state normal
               } else {
                  set state disabled
               }
            }
            [$tbl windowpath $file,0] configure -state $etat
         }
         ::prtr::configOutName
      }
      update
   }

   #--------------------------------------------------------------------------
   #  ::prtr::compressFiles dirOut nameOut nb
   #  Compresse le ou les fichiers de sortie
   #--------------------------------------------------------------------------
   proc compressFiles { dirOut nameOut nb } {

      set ext "$::conf(extension,defaut)"
      set fileToCompres ""

      if {$nb eq "1"} {
         lappend fileToCompress [file join $dirOut $nameOut$ext]
      } else {
         for {set i 1} {$i <=$nb} {incr i} {
            lappend fileToCompress "[file join $dirOut $nameOut$i$ext]"
         }
      }
      #--   compresse tous les fichiers
      foreach file $fileToCompress {gzip $file}
   }

   #--------------------------------------------------------------------------
   #  ::prtr::loadImg
   #  Charge une image dans un buffer avec bitpix en accord
   #  avec la valeur par defaut ou avec la valeur demandee par l'utilisateur
   #  Lancee par cmdApply
   #--------------------------------------------------------------------------
   proc loadImg { } {
      variable private

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

      trace remove variable "::confVisu::private($visuNo,lastFileName)" write "::prtr::updateTbl $visuNo"
      #--   charge, affiche et nomme l'image
      ::confVisu::autovisu $visuNo -no $private(lastImage)
      trace add variable "::confVisu::private($visuNo,lastFileName)" write "::prtr::updateTbl $visuNo"
   }

   #--------------------------------------------------------------------------
   #  ::prtr::cmdOk
   #  Procedure du bouton OK
   #--------------------------------------------------------------------------
   proc cmdOk {tbl visuNo} {

      if {[::prtr::cmdApply $tbl $visuNo] eq "1"} {return}
      ::prtr::cmdClose $visuNo
   }

   #--------------------------------------------------------------------------
   #  ::prtr::cmdClose
   #  Procedure du bouton Fermer
   #--------------------------------------------------------------------------
   proc cmdClose {visuNo} {
      variable private
      variable bd
      global conf

      trace remove variable "::prtr::operation" write "::prtr::changeOp $visuNo"
      trace remove variable "::audace(rep_images)" write "::prtr::updateTbl $visuNo"
      trace remove variable "::confVisu::private($visuNo,lastFileName)" write "::prtr::updateTbl $visuNo"
      if {[trace info variable "::confVisu::private($visuNo,boxSize)"] ne ""} {
         trace remove variable "::confVisu::private($visuNo,boxSize)" write "::prtr::updateBox $visuNo"
      }
      trace remove variable "::conf(extension,defaut)" write "::prtr::changeExtension $visuNo"
      trace remove variable "::conf(fichier,compres)" write "::prtr::changeExtension $visuNo"

      ::prtr::widgetToConf
      destroy $private(this)
      array unset bd
      array unset private
      array unset ::prtr
   }

   #--------------------------------------------------------------------------
   #  ::prtr::widgetToConf
   #  Calcul et sauvegarde de la geometrie avec la hauteur fixe
   #--------------------------------------------------------------------------
   proc widgetToConf { } {
      variable private
      global conf

      set geometry [wm geometry $private(this)]

      #--   cherche la hauteur totale de la fenetre
      lassign [string map -nocase [list x " " + " "] $geometry] widgetWidth widgetHeight x y

      if {$widgetHeight ne ""} {
         #--   cherche la hauteur de la table
         set tableHeight [lindex [string map [list \{ "" \} "" ] [blt::table configure $private(table) -reqheight]] 1]
         #--   calcule la hauteur sans la table
         set fixeHeight [expr {$widgetHeight-$tableHeight}]
         set conf(prtr,geometry) "${widgetWidth}x${fixeHeight}+${x}+${y}"
      } else {
         #--   configuration par defaut
         set ::conf(prtr,geometry) "${private(minWidth)}x${private(minHeight)}+350+75"
      }
   }

   #--------------------------------------------------------------------------
   #  ::prtr::confToWidget
   #  Adapte la geometrie de la fenetre
   #--------------------------------------------------------------------------
   proc confToWidget { } {
      variable private
      global conf

      #--   geometrie actuelle
      set geometry [wm geometry $private(this)]
      lassign [string map -nocase [list x " " + " "] $geometry] actualWidth height x y

      #--   hauteur fixe de la table = + 18 (hscroll) + 4 lignes x 40 + 50 (commandes) = 204
      set hauteurConstante 204
      set TableHeight [expr {($private(fun_lignes)+$private(tt_lignes))*$private(lineHeight)+$hauteurConstante}]
      blt::table configure $private(table) -reqheight $TableHeight

      #--   cherche la hauteur de la fenetre
      lassign [string map -nocase [list x " " + " "] $conf(prtr,geometry)] -> fixeHeight

      #--   calcule la hauteur totale de la fenetre
      set totalHeight [expr {$fixeHeight+$TableHeight}]

      #--   si la position existe (pas au demarrage)
      if {![info exists x] || ![info exists y]} {
         #--   configuration par defaut
         set x 350 ; set y 75
      }

      #--   actualise la geometrie de la fenetre
      wm geometry $private(this) "${actualWidth}x${totalHeight}+${x}+${y}"

      #--   calcule la hauteur minimale dans cette configuration
      #--   pour que la liste des images soit toujours visible
      set minHeight [expr {40+$TableHeight+120}]
      wm minsize $private(this) $private(minWidth) $minHeight
      update
   }

   #--------------------------------------------------------------------------
   #  ::prtr::displayAvancement c
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
   #  ::prtr::avertiUser err args
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
   #  ::prtr::Error info
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
   #  ::prtr::afficheAideBitpix
   #  Selectionne l'aide associee a la definition de bitpix
   #  Procedure lancee par le bouton ?
   #--------------------------------------------------------------------------
   proc afficheAideBitpix { } {
      variable private

      ::audace::showHelpItem "$::help(dir,prog)" "ttus1-fr.htm" "defBitpix"
   }

   #--------------------------------------------------------------------------
   #  ::prtr::createCheckButton tbl row col w
   #  Cree un checkbutton pour inserer dans une tablelist
   #  Parametres : tbl row col et w completes automatiquement
   #--------------------------------------------------------------------------
   proc createCheckButton {tbl row col w} {

      checkbutton $w -height 1 -indicatoron 1 -onvalue 1 -offvalue 0 \
         -variable ::prtr::private(file_$row) \
         -command "::prtr::selectFiles $row"
   }

   #--   chaque fonction est accompagnee de quatre variables (eventuellement vides) :
   #     -fun : nom de la fonction TT
   #     -hlp : nom du repertoire de la page, nom de la page et nom de l'ancre (si elle existe)
   #     -par : noms des parametres obligatoires alternant avec la valeur d'initialisation
   #     -opt : noms des parametres optionnels alternant avec la valeur d'initialisation

   #--------------------------------------------------------------------------
   #  ::prtr::MAITREFunctions {0|nom_de_fonction}
   #  Cree le dictionnaire des fonctions de pretraitement creant des maitres (offset,dark et flat)
   #  Retourne la liste des fonctions ou les parametres d'une fonction
   #--------------------------------------------------------------------------
   proc MAITREFunctions {function} {
      variable MAITRE
      global caption help

      set options "bitpix +16 skylevel 0"
      #--   l'option nullpixel est specifiee dans la fonction

      dict set MAITRE "$caption(audace,menu,faire_offset)"        fun "BIAS"
      dict set MAITRE "$caption(audace,menu,faire_offset)"        hlp "$help(dir,images) 1020elaborer_maitre.htm BIAS"
      dict set MAITRE "$caption(audace,menu,faire_offset)"        par ""
      dict set MAITRE "$caption(audace,menu,faire_offset)"        opt "$options nullpixel 0."
      dict set MAITRE "$caption(audace,menu,faire_dark)"          fun "DARK"
      dict set MAITRE "$caption(audace,menu,faire_dark)"          hlp "$help(dir,images) 1020elaborer_maitre.htm DARK"
      dict set MAITRE "$caption(audace,menu,faire_dark)"          par "methode MED bias \"\" "
      dict set MAITRE "$caption(audace,menu,faire_dark)"          opt "$options nullpixel 0."
      dict set MAITRE "$caption(audace,menu,faire_flat_field)"    fun "FLAT"
      dict set MAITRE "$caption(audace,menu,faire_flat_field)"    hlp "$help(dir,images) 1020elaborer_maitre.htm FLAT"
      dict set MAITRE "$caption(audace,menu,faire_flat_field)"    par "bias  \"\" dark \"\" normoffset_value 0."
      dict set MAITRE "$caption(audace,menu,faire_flat_field)"    opt "$options nullpixel 0."

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

      set options "bitpix +16 skylevel 0"
      #--   l'option nullpixel est specifiee dans la fonction

      dict set PRETRAITEE "$caption(audace,menu,pretraitee)"      fun "PRETRAITEMENT"
      dict set PRETRAITEE "$caption(audace,menu,pretraitee)"      hlp "$help(dir,images) 1020elaborer_maitre.htm PRETRAITER"
      dict set PRETRAITEE "$caption(audace,menu,pretraitee)"      par "bias \"\" dark \"\" opt_black 0 flat \"\" constant 1."
      dict set PRETRAITEE "$caption(audace,menu,pretraitee)"      opt "$options nullpixel 0."

      return [consultDic PRETRAITEE $function]
   }

   #--------------------------------------------------------------------------
   #  ::prtr::CENTERFunctions {0|nom_de_fonction}
   #  Cree le dictionnaire pour la fonction de recentrage
   #  Retourne la liste des fonctions ou les parametres d'une fonction
   #--------------------------------------------------------------------------
   proc CENTERFunctions {function} {
      variable CENTER
      global caption help

      set options "bitpix +16 skylevel 0"
      #--   l'option nullpixel est specifiee dans la fonction

      dict set CENTER "$caption(audace,menu,reg_inter)"           fun "CENTER"
      dict set CENTER "$caption(audace,menu,reg_inter)"           hlp "$help(dir,images) 1040aligner.htm"
      dict set CENTER "$caption(audace,menu,reg_inter)"           par "plan g image_ref \"\" "
      dict set CENTER "$caption(audace,menu,reg_inter)"           opt "$options nullpixel 0."
      dict set CENTER "$caption(audace,menu,reg_trans)"           fun "REGISTER translate=before"
      dict set CENTER "$caption(audace,menu,reg_trans)"           hlp "$help(dir,images) 1040aligner.htm"
      dict set CENTER "$caption(audace,menu,reg_trans)"           par "normaflux 1."
      dict set CENTER "$caption(audace,menu,reg_trans)"           opt "$options nullpixel 0."
      dict set CENTER "$caption(audace,menu,reg_tri)"             fun "REGISTER translate=never"
      dict set CENTER "$caption(audace,menu,reg_tri)"             hlp "$help(dir,images) 1040aligner.htm"
      dict set CENTER "$caption(audace,menu,reg_tri)"             par "normaflux 1."
      dict set CENTER "$caption(audace,menu,reg_tri)"             opt "$options nullpixel 0."
      dict set CENTER "$caption(audace,menu,reg_fine)"            fun "REGISTERFINE"
      dict set CENTER "$caption(audace,menu,reg_fine)"            hlp "$help(dir,images) 1040aligner.htm"
      dict set CENTER "$caption(audace,menu,reg_fine)"            par "file img oversampling 10 delta 2"
      dict set CENTER "$caption(audace,menu,reg_fine)"            opt "$options nullpixel 0."
      dict set CENTER "$caption(audace,menu,reg_wcs)"             fun "REGISTER matchwcs"
      dict set CENTER "$caption(audace,menu,reg_wcs)"             hlp "$help(dir,images) 1040aligner.htm"
      dict set CENTER "$caption(audace,menu,reg_wcs)"             par "normaflux 1."
      dict set CENTER "$caption(audace,menu,reg_wcs)"             opt "$options nullpixel 0."

      return [consultDic CENTER $function]
   }

   #--------------------------------------------------------------------------
   #  ::prtr::PILEFunctions {0|nom_de_fonction}
   #  Cree le dictionnaire des fonctions IMA/STACK
   #  Retourne la liste des fonctions ou les parametres d'une fonction
   #--------------------------------------------------------------------------
   proc PILEFunctions {function} {
      variable STACK
      global caption help conf

      if {![info exists conf(prtr,sk,kappa)]} {set conf(prtr,sk,kappa) "0.8"}

      set options "bitpix +16 skylevel 0"
      #--   l'option nullpixel est specifiee dans la fonction

      dict set STACK "$caption(audace,menu,somme)"                fun ADD
      dict set STACK "$caption(audace,menu,somme)"                hlp "$help(dir,prog) ttus1-fr.htm stackADD"
      dict set STACK "$caption(audace,menu,somme)"                par ""
      dict set STACK "$caption(audace,menu,somme)"                opt "$options nullpixel 0."
      dict set STACK "$caption(audace,menu,moyenne)"              fun MEAN
      dict set STACK "$caption(audace,menu,moyenne)"              hlp "$help(dir,prog) ttus1-fr.htm MEAN"
      dict set STACK "$caption(audace,menu,moyenne)"              par ""
      dict set STACK "$caption(audace,menu,moyenne)"              opt "$options nullpixel 0."
      dict set STACK "$caption(audace,menu,mediane)"              fun MED
      dict set STACK "$caption(audace,menu,mediane)"              hlp "$help(dir,prog) ttus1-fr.htm MED"
      dict set STACK "$caption(audace,menu,mediane)"              par ""
      dict set STACK "$caption(audace,menu,mediane)"              opt "$options nullpixel 0."
      dict set STACK "$caption(audace,menu,produit)"              fun PROD
      dict set STACK "$caption(audace,menu,produit)"              hlp "$help(dir,prog) ttus1-fr.htm stackPROD"
      dict set STACK "$caption(audace,menu,produit)"              par ""
      dict set STACK "$caption(audace,menu,produit)"              opt "powernorm 0 $options nullpixel 0."
      dict set STACK "$caption(audace,menu,racine_carree)"        fun PYTHAGORE
      dict set STACK "$caption(audace,menu,racine_carree)"        hlp "$help(dir,prog) ttus1-fr.htm PYTHAGORE"
      dict set STACK "$caption(audace,menu,racine_carree)"        par ""
      dict set STACK "$caption(audace,menu,racine_carree)"        opt "$options nullpixel 0."
      dict set STACK "$caption(audace,menu,ecart_type)"           fun SIG
      dict set STACK "$caption(audace,menu,ecart_type)"           hlp "$help(dir,prog) ttus1-fr.htm SIG"
      dict set STACK "$caption(audace,menu,ecart_type)"           par ""
      dict set STACK "$caption(audace,menu,ecart_type)"           opt "$options nullpixel 0."
      dict set STACK "$caption(audace,menu,moyenne_k)"            fun SK
      dict set STACK "$caption(audace,menu,moyenne_k)"            hlp "$help(dir,prog) ttus1-fr.htm SK"
      dict set STACK "$caption(audace,menu,moyenne_k)"            par "kappa $conf(prtr,sk,kappa)"
      dict set STACK "$caption(audace,menu,moyenne_k)"            opt "$options nullpixel 0."
      dict set STACK "$caption(audace,menu,moyenne_tri)"          fun SORT
      dict set STACK "$caption(audace,menu,moyenne_tri)"          hlp "$help(dir,prog) ttus1-fr.htm SORT"
      dict set STACK "$caption(audace,menu,moyenne_tri)"          par ""
      dict set STACK "$caption(audace,menu,moyenne_tri)"          opt "percent 50 $options nullpixel 0."
      dict set STACK "$caption(audace,menu,obturateur)"           fun SHUTTER
      dict set STACK "$caption(audace,menu,obturateur)"           hlp "$help(dir,prog) ttus1-fr.htm SHUTTER"
      dict set STACK "$caption(audace,menu,obturateur)"           par ""
      dict set STACK "$caption(audace,menu,obturateur)"           opt "$options nullpixel 0."

      return [::prtr::consultDic STACK $function]
   }

   #--------------------------------------------------------------------------
   #  ::prtr::PRETRAITEEFunctions {0|nom_de_fonction}
   #  Cree le dictionnaire des fonctions de rotation a angles droit
   #  Retourne la liste des fonctions ou les parametres d'une fonction
   #--------------------------------------------------------------------------
   proc ROTATIONFunctions {function} {
      variable ROTATION
      global caption help

      set options "bitpix +16 skylevel 0"
      #--   l'option nullpixel est specifiee dans la fonction
      #--   les fonctions combinent des fonctions INVERT qui ont l'option nullpixel

      dict set ROTATION "$caption(audace,menu,rot+90)"            fun "ROT+90"
      dict set ROTATION "$caption(audace,menu,rot+90)"            hlp "$help(dir,images) 1050tourner.htm ROT+90"
      dict set ROTATION "$caption(audace,menu,rot+90)"            par ""
      dict set ROTATION "$caption(audace,menu,rot+90)"            opt "$options nullpixel 0."
      dict set ROTATION "$caption(audace,menu,rot-90)"            fun "ROT-90"
      dict set ROTATION "$caption(audace,menu,rot-90)"            hlp "$help(dir,images) 1050tourner.htm ROT-90"
      dict set ROTATION "$caption(audace,menu,rot-90)"            par ""
      dict set ROTATION "$caption(audace,menu,rot-90)"            opt "$options nullpixel 0."
      dict set ROTATION "$caption(audace,menu,rot180)"            fun "ROT180"
      dict set ROTATION "$caption(audace,menu,rot180)"            hlp "$help(dir,images) 1050tourner.htm ROT180"
      dict set ROTATION "$caption(audace,menu,rot180)"            par ""
      dict set ROTATION "$caption(audace,menu,rot180)"            opt "$options nullpixel 0."

      return [consultDic ROTATION $function]
   }

   #--------------------------------------------------------------------------
   #  ::prtr::GEOMETRYFunctions {0|nom_de_fonction}
   #  Cree le dictionnaire des fonctions qui modifient la geometrie
   #  Retourne la liste des fonctions ou les parametres d'une fonction
   #--------------------------------------------------------------------------
   proc GEOMETRYFunctions {function} {
      variable SERIES
      global caption help conf

      if {![info exists conf(multx)] && ![info exists conf(multy)] && ![info exists conf(prtr,resample,paramresample)]} {
         set conf(prtr,resample,paramresample) "0.5 0 0 0 0.5 0"
      } elseif {[info exists conf(multx)] && [info exists conf(multy)]} {
         set conf(prtr,resample,paramresample) "$conf(multx) 0 0 0 $conf(multy) 0"
         unset conf(multx) conf(multy)
      }

      set options "bitpix +16 skylevel 0"
      #--   l'option nullpixel est specifiee dans la fonction

      dict set SERIES "$caption(audace,menu,miroir_x)"            fun "INVERT mirror"
      dict set SERIES "$caption(audace,menu,miroir_x)"            hlp "$help(dir,prog) ttus1-fr.htm INVERT"
      dict set SERIES "$caption(audace,menu,miroir_x)"            par ""
      dict set SERIES "$caption(audace,menu,miroir_x)"            opt "$options nullpixel 0."
      dict set SERIES "$caption(audace,menu,miroir_y)"            fun "INVERT flip"
      dict set SERIES "$caption(audace,menu,miroir_y)"            hlp "$help(dir,prog) ttus1-fr.htm INVERT"
      dict set SERIES "$caption(audace,menu,miroir_y)"            par ""
      dict set SERIES "$caption(audace,menu,miroir_y)"            opt "$options nullpixel 0."
      dict set SERIES "$caption(audace,menu,miroir_xy)"           fun "INVERT xy"
      dict set SERIES "$caption(audace,menu,miroir_xy)"           hlp "$help(dir,prog) ttus1-fr.htm INVERT"
      dict set SERIES "$caption(audace,menu,miroir_xy)"           par ""
      dict set SERIES "$caption(audace,menu,miroir_xy)"           opt "$options nullpixel 0."
      dict set SERIES "$caption(audace,menu,window1)"             fun WINDOW
      dict set SERIES "$caption(audace,menu,window1)"             hlp "$help(dir,prog) ttus1-fr.htm WINDOW"
      dict set SERIES "$caption(audace,menu,window1)"             par "x1 1 y1 1 x2 2 y2 2"
      dict set SERIES "$caption(audace,menu,window1)"             opt $options
      dict set SERIES "$caption(audace,menu,taille)"              fun RESIZE
      dict set SERIES "$caption(audace,menu,taille)"              hlp "$help(dir,prog) ttus1-fr.htm RESIZE"
      dict set SERIES "$caption(audace,menu,taille)"              par "width 100 height 100"
      dict set SERIES "$caption(audace,menu,taille)"              opt $options
      dict set SERIES "$caption(audace,menu,scale)"               fun RESAMPLE
      dict set SERIES "$caption(audace,menu,scale)"               hlp "$help(dir,prog) ttus1-fr.htm RESAMPLE"
      dict set SERIES "$caption(audace,menu,scale)"               par "paramresample \"$conf(prtr,resample,paramresample)\" normaflux 1."
      dict set SERIES "$caption(audace,menu,scale)"               opt "$options nullpixel 0."
      dict set SERIES "$caption(audace,menu,translate)"           fun TRANS
      dict set SERIES "$caption(audace,menu,translate)"           hlp "$help(dir,prog) ttus1-fr.htm TRANS"
      dict set SERIES "$caption(audace,menu,translate)"           par "trans_x 1. trans_y 1."
      dict set SERIES "$caption(audace,menu,translate)"           opt "$options nullpixel 0."
      dict set SERIES "$caption(audace,menu,rotation1)"           fun ROT
      dict set SERIES "$caption(audace,menu,rotation1)"           hlp "$help(dir,prog) ttus1-fr.htm ROT"
      dict set SERIES "$caption(audace,menu,rotation1)"           par "x0 1. y0 1. angle 1."
      dict set SERIES "$caption(audace,menu,rotation1)"           opt "$options nullpixel 0."
      dict set SERIES "$caption(audace,menu,rotation2)"           fun ROTENTIERE
      dict set SERIES "$caption(audace,menu,rotation2)"           hlp "$help(dir,prog) ttus1-fr.htm ROTENTIERE"
      dict set SERIES "$caption(audace,menu,rotation2)"           par "angle 1."
      dict set SERIES "$caption(audace,menu,rotation2)"           opt "$options nullpixel 0."

      return [::prtr::consultDic SERIES $function]
   }

   #--------------------------------------------------------------------------
   #  ::prtr::IMPROVEFunctions {0|nom_de_fonction}
   #  Cree le dictionnaire des fonctions IMA/SERIES qui ameliorent les images
   #  Retourne la liste des fonctions ou les parametres d'une fonction
   #--------------------------------------------------------------------------
   proc IMPROVEFunctions {function} {
      variable SERIES
      global caption help conf

      if {![info exists conf(back_kernel)] && ![info exists conf(prtr,back,back_kernel)]}  {
         set conf(prtr,back,back_kernel) "15"
      } elseif {[info exists conf(back_kernel)]} {
         set conf(prtr,back,back_kernel) $conf(back_kernel)
         unset conf(back_kernel)
      }
      if {![info exists conf(back_threshold)] && ![info exists conf(prtr,back,back_threshold)]}  {
         set conf(prtr,back,back_threshold) "0.2"
      } elseif {[info exists conf(back_threshold)]} {
         set conf(prtr,back,back_threshold) $conf(back_threshold)
         unset conf(back_threshold)
      }

      set options "bitpix +16 skylevel 0"
      #--   l'option nullpixel est specifiee dans la fonction

      dict set SERIES "$caption(audace,menu,trainee)"             fun UNSMEARING
      dict set SERIES "$caption(audace,menu,trainee)"             hlp "$help(dir,prog) ttus1-fr.htm UNSMEARING"
      dict set SERIES "$caption(audace,menu,trainee)"             par "unsmearing 0.0005"
      dict set SERIES "$caption(audace,menu,trainee)"             opt $options
      dict set SERIES "$caption(audace,menu,cosmic)"              fun COSMIC
      dict set SERIES "$caption(audace,menu,cosmic)"              hlp "$help(dir,prog) ttus1-fr.htm COSMIC"
      dict set SERIES "$caption(audace,menu,cosmic)"              par "cosmic_threshold 400"
      dict set SERIES "$caption(audace,menu,cosmic)"              opt $options
      dict set SERIES "$caption(audace,menu,opt_noir)"            fun OPT
      dict set SERIES "$caption(audace,menu,opt_noir)"            hlp "$help(dir,prog) ttus1-fr.htm OPT"
      dict set SERIES "$caption(audace,menu,opt_noir)"            par "bias img dark img therm_kappa 0.25"
      dict set SERIES "$caption(audace,menu,opt_noir)"            opt "unsmearing 0.0005 $options"
      dict set SERIES "$caption(audace,menu,subsky)"              fun BACK
      dict set SERIES "$caption(audace,menu,subsky)"              hlp "$help(dir,prog) ttus1-fr.htm BACK"
      dict set SERIES "$caption(audace,menu,subsky)"              par "back_kernel $conf(prtr,back,back_kernel) back_threshold $conf(prtr,back,back_threshold)"
      dict set SERIES "$caption(audace,menu,subsky)"              opt "sub 0 div 0 $options nullpixel 0."

      return [::prtr::consultDic SERIES $function]
   }

   #--------------------------------------------------------------------------
   #  ::prtr::ARITHMFunctions {0|nom_de_fonction}
   #  Cree le dictionnaire des fonctions IMA/SERIES qui modifient les valeurs
   #  Retourne la liste des fonctions ou les parametres d'une fonction
   #--------------------------------------------------------------------------
   proc ARITHMFunctions {function} {
      variable SERIES
      global caption help conf

      if {![info exists conf(clip_mini)] && ![info exists conf(prtr,clip,clip_mini)]}  {
         set conf(prtr,clip,clip_mini) "0"
      } elseif {[info exists conf(clip_mini)]} {
         set conf(prtr,clip,clip_mini) $conf(clip_mini)
         unset conf(clip_mini)
      }
      if {![info exists conf(clip_maxi)] && ![info exists conf(prtr,clip,clip_maxi)]}  {
         set conf(prtr,clip,clip_maxi) "32767"
      } elseif {[info exists conf(clip_maxi)]} {
         set conf(prtr,clip,clip_maxi) $conf(clip_maxi)
         unset conf(clip_maxi)
      }

      set options "bitpix +16 skylevel 0"
      #--   l'option nullpixel est specifiee dans la fonction

      dict set SERIES "$caption(audace,menu,addition)"            fun ADD
      dict set SERIES "$caption(audace,menu,addition)"            hlp "$help(dir,prog) ttus1-fr.htm seriesADD"
      dict set SERIES "$caption(audace,menu,addition)"            par "file img"
      dict set SERIES "$caption(audace,menu,addition)"            opt "offset 0 $options"
      dict set SERIES "$caption(audace,menu,soust)"               fun SUB
      dict set SERIES "$caption(audace,menu,soust)"               hlp "$help(dir,prog) ttus1-fr.htm SUB"
      dict set SERIES "$caption(audace,menu,soust)"               par "file img"
      dict set SERIES "$caption(audace,menu,soust)"               opt "offset 0 $options"
      dict set SERIES "$caption(audace,menu,division)"            fun DIV
      dict set SERIES "$caption(audace,menu,division)"            hlp "$help(dir,prog) ttus1-fr.htm DIV"
      dict set SERIES "$caption(audace,menu,division)"            par "file img"
      dict set SERIES "$caption(audace,menu,division)"            opt "constant 1. $options"
      dict set SERIES "$caption(audace,menu,multipli)"            fun PROD
      dict set SERIES "$caption(audace,menu,multipli)"            hlp "$help(dir,prog) ttus1-fr.htm seriesPROD"
      dict set SERIES "$caption(audace,menu,multipli)"            par "file img"
      dict set SERIES "$caption(audace,menu,multipli)"            opt "constant 1. $options"
      dict set SERIES "$caption(audace,menu,offset)"              fun OFFSET
      dict set SERIES "$caption(audace,menu,offset)"              hlp "$help(dir,prog) ttus1-fr.htm OFFSET"
      dict set SERIES "$caption(audace,menu,offset)"              par "offset 0"
      dict set SERIES "$caption(audace,menu,offset)"              opt $options
      dict set SERIES "$caption(audace,menu,mult_cte)"            fun MULT
      dict set SERIES "$caption(audace,menu,mult_cte)"            hlp "$help(dir,prog) ttus1-fr.htm MULT"
      dict set SERIES "$caption(audace,menu,mult_cte)"            par "constant 1."
      dict set SERIES "$caption(audace,menu,mult_cte)"            opt $options
      dict set SERIES "$caption(audace,menu,log)"                 fun LOG
      dict set SERIES "$caption(audace,menu,log)"                 hlp "$help(dir,prog) ttus1-fr.htm LOG"
      dict set SERIES "$caption(audace,menu,log)"                 par "coef 20. offsetlog 1."
      dict set SERIES "$caption(audace,menu,log)"                 opt "$options nullpixel 0."
      dict set SERIES "$caption(audace,menu,noffset)"             fun NORMOFFSET
      dict set SERIES "$caption(audace,menu,noffset)"             hlp "$help(dir,prog) ttus1-fr.htm NORMOFFSET"
      dict set SERIES "$caption(audace,menu,noffset)"             par "normoffset_value 0."
      dict set SERIES "$caption(audace,menu,noffset)"             opt "$options nullpixel 0."
      dict set SERIES "$caption(audace,menu,ngain)"               fun NORMGAIN
      dict set SERIES "$caption(audace,menu,ngain)"               hlp "$help(dir,prog) ttus1-fr.htm NORMGAIN"
      dict set SERIES "$caption(audace,menu,ngain)"               par "normgain_value 200."
      dict set SERIES "$caption(audace,menu,ngain)"               opt "$options nullpixel 0."
      #--   CLIP fonction artificielle inexistante dans IMA/SERIES
      dict set SERIES "$caption(audace,menu,clip)"                fun CLIP
      dict set SERIES "$caption(audace,menu,clip)"                hlp "$help(dir,images) 1080ecreter.htm"
      dict set SERIES "$caption(audace,menu,clip)"                par "mini $conf(prtr,clip,clip_mini) maxi $conf(prtr,clip,clip_maxi)"
      dict set SERIES "$caption(audace,menu,clip)"                opt "bitpix +16"

      return [::prtr::consultDic SERIES $function]
   }

   #--------------------------------------------------------------------------
   #  ::prtr::FILTERFunctions {0|nom_de_fonction}
   #  Cree le dictionnaire des fonctions IMA/SERIES avec les filtres
   #  Retourne la liste des fonctions ou les parametres d'une fonction
   #--------------------------------------------------------------------------
   proc FILTERFunctions {function} {
      variable SERIES
      global caption help conf

      if {![info exists conf(coef_etal)] && ![info exists conf(prtr,flou,sigma)]} {
         set conf(prtr,flou,sigma) "2.0"
      } elseif {[info exists conf(coef_etal)]} {
         set conf(prtr,flou,sigma) $conf(coef_etal)
         unset conf(coef_etal)
      }
      if {![info exists conf(coef_mult)] && ![info exists conf(prtr,flou,constant)]} {
         set conf(prtr,flou,constant) "5.0"
      } elseif {[info exists conf(coef_mult)]} {
        set conf(prtr,flou,constant) $conf(coef_mult)
         unset conf(coef_mult)
      }

      set options "bitpix +16 skylevel 0"
      #--   l'option nullpixel est specifiee dans la fonction

      #--   FLOU fonction artificielle inexistante dans IMA/SERIES
      dict set SERIES "$caption(audace,menu,masque_flou)"         fun FLOU
      dict set SERIES "$caption(audace,menu,masque_flou)"         hlp "$help(dir,images) 1090masque_flou.htm"
      dict set SERIES "$caption(audace,menu,masque_flou)"         par "sigma $conf(prtr,flou,sigma) constant $conf(prtr,flou,constant)"
      dict set SERIES "$caption(audace,menu,masque_flou)"         opt $options
      dict set SERIES "$caption(audace,menu,filtre_passe-bas)"    fun "FILTER kernel_type=fb"
      dict set SERIES "$caption(audace,menu,filtre_passe-bas)"    hlp "$help(dir,images) 1100passe_bas.htm"
      dict set SERIES "$caption(audace,menu,filtre_passe-bas)"    par "kernel_width 3 kernel_coef 0 threshold 0 type_threshold 0"
      dict set SERIES "$caption(audace,menu,filtre_passe-bas)"    opt $options
      dict set SERIES "$caption(audace,menu,filtre_passe-haut)"   fun "FILTER kernel_type=fh"
      dict set SERIES "$caption(audace,menu,filtre_passe-haut)"   hlp "$help(dir,images) 1110passe_haut.htm"
      dict set SERIES "$caption(audace,menu,filtre_passe-haut)"   par "kernel_width 3 kernel_coef 0 threshold 0 type_threshold 0"
      dict set SERIES "$caption(audace,menu,filtre_passe-haut)"   opt $options
      dict set SERIES "$caption(audace,menu,filtre_median)"       fun "FILTER kernel_type=med"
      dict set SERIES "$caption(audace,menu,filtre_median)"       hlp "$help(dir,prog) ttus1-fr.htm FILTER"
      dict set SERIES "$caption(audace,menu,filtre_median)"       par "kernel_width 3 kernel_coef 0 threshold 0 type_threshold 0"
      dict set SERIES "$caption(audace,menu,filtre_median)"       opt $options
      dict set SERIES "$caption(audace,menu,filtre_mean)"         fun "FILTER kernel_type=mean"
      dict set SERIES "$caption(audace,menu,filtre_mean)"         hlp "$help(dir,prog) ttus1-fr.htm FILTER"
      dict set SERIES "$caption(audace,menu,filtre_mean)"         par "kernel_width 3 kernel_coef 0 threshold 0 type_threshold 0"
      dict set SERIES "$caption(audace,menu,filtre_mean)"         opt $options
      dict set SERIES "$caption(audace,menu,filtre_minimum)"      fun "FILTER kernel_type=min"
      dict set SERIES "$caption(audace,menu,filtre_minimum)"      hlp "$help(dir,prog) ttus1-fr.htm FILTER"
      dict set SERIES "$caption(audace,menu,filtre_minimum)"      par "kernel_width 3 kernel_coef 0 threshold 0 type_threshold 0"
      dict set SERIES "$caption(audace,menu,filtre_minimum)"      opt $options
      dict set SERIES "$caption(audace,menu,filtre_maximum)"      fun "FILTER kernel_type=max"
      dict set SERIES "$caption(audace,menu,filtre_maximum)"      hlp "$help(dir,prog) ttus1-fr.htm FILTER"
      dict set SERIES "$caption(audace,menu,filtre_maximum)"      par "kernel_width 3 kernel_coef 0 threshold 0 type_threshold 0"
      dict set SERIES "$caption(audace,menu,filtre_maximum)"      opt $options
      dict set SERIES "$caption(audace,menu,filtre_up)"           fun "FILTER kernel_type=gradup"
      dict set SERIES "$caption(audace,menu,filtre_up)"           hlp "$help(dir,prog) ttus1-fr.htm FILTER"
      dict set SERIES "$caption(audace,menu,filtre_up)"           par "kernel_width 3 kernel_coef 0 threshold 0 type_threshold 0"
      dict set SERIES "$caption(audace,menu,filtre_up)"           opt $options
      dict set SERIES "$caption(audace,menu,filtre_left)"         fun "FILTER kernel_type=gradleft"
      dict set SERIES "$caption(audace,menu,filtre_left)"         hlp "$help(dir,prog) ttus1-fr.htm FILTER"
      dict set SERIES "$caption(audace,menu,filtre_left)"         par "kernel_width 3 kernel_coef 0 threshold 0 type_threshold 0"
      dict set SERIES "$caption(audace,menu,filtre_left)"         opt $options
      dict set SERIES "$caption(audace,menu,filtre_down)"         fun "FILTER kernel_type=graddown"
      dict set SERIES "$caption(audace,menu,filtre_down)"         hlp "$help(dir,prog) ttus1-fr.htm FILTER"
      dict set SERIES "$caption(audace,menu,filtre_down)"         par "kernel_width 3 kernel_coef 0 threshold 0 type_threshold 0"
      dict set SERIES "$caption(audace,menu,filtre_down)"         opt $options
      dict set SERIES "$caption(audace,menu,filtre_right)"        fun "FILTER kernel_type=gradright"
      dict set SERIES "$caption(audace,menu,filtre_right)"        hlp "$help(dir,prog) ttus1-fr.htm FILTER"
      dict set SERIES "$caption(audace,menu,filtre_right)"        par "kernel_width 3 kernel_coef 0 threshold 0 type_threshold 0"
      dict set SERIES "$caption(audace,menu,filtre_right)"        opt $options
      dict set SERIES "$caption(audace,menu,filtre_gaussien)"     fun "CONV kernel_type=gaussian"
      dict set SERIES "$caption(audace,menu,filtre_gaussien)"     hlp "$help(dir,prog) ttus1-fr.htm CONV"
      dict set SERIES "$caption(audace,menu,filtre_gaussien)"     par ""
      dict set SERIES "$caption(audace,menu,filtre_gaussien)"     opt "sigma 0.5 $options"
      dict set SERIES "$caption(audace,menu,ond_morlet)"          fun "CONV kernel_type=morlet"
      dict set SERIES "$caption(audace,menu,ond_morlet)"          hlp "$help(dir,prog) ttus1-fr.htm CONV"
      dict set SERIES "$caption(audace,menu,ond_morlet)"          par ""
      dict set SERIES "$caption(audace,menu,ond_morlet)"          opt "sigma 2. bitpix +16 skylevel 0 nullpixel 0."
      dict set SERIES "$caption(audace,menu,ond_mexicain)"        fun "CONV kernel_type=mexican"
      dict set SERIES "$caption(audace,menu,ond_mexicain)"        hlp "$help(dir,prog) ttus1-fr.htm CONV"
      dict set SERIES "$caption(audace,menu,ond_mexicain)"        par ""
      dict set SERIES "$caption(audace,menu,ond_mexicain)"        opt "sigma 2. bitpix +16 skylevel 0 nullpixel 0."
      dict set SERIES "$caption(audace,menu,grad_rot)"            fun RGRADIENT
      dict set SERIES "$caption(audace,menu,grad_rot)"            hlp "$help(dir,prog) ttus1-fr.htm RGRADIENT"
      dict set SERIES "$caption(audace,menu,grad_rot)"            par "xcenter 1. ycenter 1. radius 1. angle 1."
      dict set SERIES "$caption(audace,menu,grad_rot)"            opt "$options nullpixel 0."
      dict set SERIES "$caption(audace,menu,radial)"              fun RADIAL
      dict set SERIES "$caption(audace,menu,radial)"              hlp "$help(dir,prog) ttus1-fr.htm RADIAL"
      dict set SERIES "$caption(audace,menu,radial)"              par "sigma 10 power 2 xcenter 1. ycenter 1. radius 1."
      dict set SERIES "$caption(audace,menu,radial)"              opt $options

      return [::prtr::consultDic SERIES $function]
   }

   #--------------------------------------------------------------------------
   #  ::prtr::TRANSFORMFunctions {0|nom_de_fonction}
   #  Cree le dictionnaire des fonctions IMA/SERIES qui effectuent des transformations
   #  Retourne la liste des fonctions ou les parametres d'une fonction
   #--------------------------------------------------------------------------
   proc TRANSFORMFunctions {function} {
      variable SERIES
      global caption help

      set options "bitpix +16 skylevel 0"
      #--   l'option nullpixel est specifiee dans la fonction

      dict set SERIES "$caption(audace,menu,cart2pol)"            fun REC2POL
      dict set SERIES "$caption(audace,menu,cart2pol)"            hlp "$help(dir,prog) ttus1-fr.htm REC2POL"
      dict set SERIES "$caption(audace,menu,cart2pol)"            par "x0 1. y0 1. scale_theta 1. scale_rho 1."
      dict set SERIES "$caption(audace,menu,cart2pol)"            opt "$options nullpixel 0."
      dict set SERIES "$caption(audace,menu,pol2cart)"            fun POL2REC
      dict set SERIES "$caption(audace,menu,pol2cart)"            hlp "$help(dir,prog) ttus1-fr.htm POL2REC"
      dict set SERIES "$caption(audace,menu,pol2cart)"            par "x0 1.  y0 1. scale_theta 1. scale_rho 1. width 100 height 100"
      dict set SERIES "$caption(audace,menu,pol2cart)"            opt "$options nullpixel 0."
      dict set SERIES "$caption(audace,menu,hough)"               fun HOUGH
      dict set SERIES "$caption(audace,menu,hough)"               hlp "$help(dir,prog) ttus1-fr.htm HOUGH"
      dict set SERIES "$caption(audace,menu,hough)"               par ""
      dict set SERIES "$caption(audace,menu,hough)"               opt "threshold 0 binary 0 $options"

      return [::prtr::consultDic SERIES $function]
   }

   #--------------------------------------------------------------------------
   #  ::prtr::EXTRACTunctions {0|nom_de_fonction}
   #  Cree le dictionnaire des fonctions IMA/SERIES qui extrait des infomations numeriques
   #  Retourne la liste des fonctions ou les parametres d'une fonction
   #--------------------------------------------------------------------------
   proc EXTRACTFunctions {function} {
      variable SERIES
      global caption help

      set options "bitpix +16 skylevel 0"
      #--   l'option nullpixel est specifiee dans la fonction

      dict set SERIES "$caption(audace,menu,ligne)"               fun "PROFILE direction=x"
      dict set SERIES "$caption(audace,menu,ligne)"               hlp "$help(dir,prog) ttus1-fr.htm PROFILE"
      dict set SERIES "$caption(audace,menu,ligne)"               par "offset 1 filename row "
      dict set SERIES "$caption(audace,menu,ligne)"               opt $options
      dict set SERIES "$caption(audace,menu,bin_y)"               fun BINY
      dict set SERIES "$caption(audace,menu,bin_y)"               hlp "$help(dir,prog) ttus1-fr.htm BINY"
      dict set SERIES "$caption(audace,menu,bin_y)"               par "y1 1 y2 2 height 20"
      dict set SERIES "$caption(audace,menu,bin_y)"               opt $options
      dict set SERIES "$caption(audace,menu,med_y)"               fun "MEDIANY"
      dict set SERIES "$caption(audace,menu,med_y)"               hlp "$help(dir,prog) ttus1-fr.htm MEDIANY"
      dict set SERIES "$caption(audace,menu,med_y)"               par "y1 1 y2 2 height 20"
      dict set SERIES "$caption(audace,menu,med_y)"               opt $options
      dict set SERIES "$caption(audace,menu,sort_y)"              fun "SORTY"
      dict set SERIES "$caption(audace,menu,sort_y)"              hlp "$help(dir,prog) ttus1-fr.htm SORTY"
      dict set SERIES "$caption(audace,menu,sort_y)"              par "y1 1 y2 2 height 20 percent 50"
      dict set SERIES "$caption(audace,menu,sort_y)"              opt $options
      dict set SERIES "$caption(audace,menu,colonne)"             fun "PROFILE direction=y"
      dict set SERIES "$caption(audace,menu,colonne)"             hlp "$help(dir,prog) ttus1-fr.htm PROFILE"
      dict set SERIES "$caption(audace,menu,colonne)"             par "offset 1 filename col"
      dict set SERIES "$caption(audace,menu,colonne)"             opt $options
      dict set SERIES "$caption(audace,menu,bin_x)"               fun BINX
      dict set SERIES "$caption(audace,menu,bin_x)"               hlp "$help(dir,prog) ttus1-fr.htm BINX"
      dict set SERIES "$caption(audace,menu,bin_x)"               par "x1 1 x2 2 width 20"
      dict set SERIES "$caption(audace,menu,bin_x)"               opt $options
      dict set SERIES "$caption(audace,menu,med_x)"               fun "MEDIANX"
      dict set SERIES "$caption(audace,menu,med_x)"               hlp "$help(dir,prog) ttus1-fr.htm MEDIANX"
      dict set SERIES "$caption(audace,menu,med_x)"               par "x1 1 x2 2 width 20"
      dict set SERIES "$caption(audace,menu,med_x)"               opt $options
      dict set SERIES "$caption(audace,menu,sort_x)"              fun "SORTX"
      dict set SERIES "$caption(audace,menu,sort_x)"              hlp "$help(dir,prog) ttus1-fr.htm SORTX"
      dict set SERIES "$caption(audace,menu,sort_x)"              par "x1 1 x2 2 width 20 percent 50"
      dict set SERIES "$caption(audace,menu,sort_x)"              opt $options
      dict set SERIES "$caption(audace,menu,matrice)"             fun MATRIX
      dict set SERIES "$caption(audace,menu,matrice)"             hlp "$help(dir,prog) ttus1-fr.htm MATRIX"
      dict set SERIES "$caption(audace,menu,matrice)"             par "x1 1 y1 1 x2 2 y2 2 filematrix matrice"
      dict set SERIES "$caption(audace,menu,matrice)"             opt $options

      return [::prtr::consultDic SERIES $function]
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
   #  Recherche le dictionnaire de la fonction et afficher la liste dans le bouton de menu
   #--------------------------------------------------------------------------
   proc searchFunction {oper} {
      variable private

      set purDico {ARITHM CENTER EXTRACT FILTER IMPROVE MAITRE PILE PRETRAITEE TRANSFORM}
      set agregDico {ROTATION GEOMETRY}
      set private(fonctions) ""
      set private(ima) ""

      foreach dico $purDico {
         set fonctions [${dico}Functions 0]
         if {$oper in $fonctions} {
            set private(fonctions) "$fonctions"
            set private(ima) $dico
            break
         }
      }

      #--   si la liste des fonctions n'est pas identifiee
      if {$private(fonctions) eq "" && $private(ima) eq ""} {
         foreach dico $agregDico {
            set fonctions [${dico}Functions 0]
            append private(fonctions) $fonctions " "
            if {$oper in $fonctions} {
               set private(ima) $dico
            }
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
      dict set Var   powernorm         "boolean checkbutton"         ;#PROD
      dict set Var   percent           "double 100 labelentry"       ;#IMA/STACK SORT
      dict set Var   kappa             "double labelentry"           ;#SK
      dict set Var   offset            "integer labelentry"          ;#OFFSET ADD SUB PROFILE
      dict set Var   constant          "double labelentry"           ;#MULT FLAT
      dict set Var   coef              "double labelentry"           ;#LOG
      dict set Var   offsetlog         "double labelentry"           ;#LOG
      dict set Var   back_threshold    "double 1. labelentry"        ;#BACK
      dict set Var   back_kernel       "integer 50 labelentry"       ;#BACK
      dict set Var   sub               "boolean checkbutton"         ;#BACK
      dict set Var   div               "boolean checkbutton"         ;#BACK
      dict set Var   binary            "boolean checkbutton"         ;#HOUGH
      dict set Var   normoffset_value  "double labelentry"           ;#NORMOFFSET FLAT
      dict set Var   normgain_value    "double labelentry"           ;#NORMGAIN
      dict set Var   unsmearing        "double labelentry"           ;#UNSMEARING
      dict set Var   cosmic_threshold  "double labelentry"           ;#COSMIC
      dict set Var   sigma             "double labelentry"           ;#CONV RADIAL
      dict set Var   radius            "double labelentry"           ;#RGRADIENT RADIAL
      dict set Var   xcenter           "double labelentry"           ;#RGRADIENT RADIAL
      dict set Var   ycenter           "double labelentry"           ;#RGRADIENT RADIAL
      dict set Var   power             "double labelentry"           ;#RADIAL
      dict set Var   x0                "double naxis1 labelentry"    ;#ROT REC2POL POL2REC
      dict set Var   y0                "double naxis2 labelentry"    ;#ROT REC2POL POL2REC
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
      dict set Var   width             "integer naxis1 labelentry"   ;#BINX POL2REC MEDIANX SORTX RESIZE
      dict set Var   height            "integer naxis2 labelentry"   ;#BINY POL2REC MEDIANY SORTY RESIZE
      dict set Var   normaflux         "double labelentry"           ;#RESAMPLE REGISTER
      dict set Var   paramresample     "liste labelentry"            ;#RESAMPLE
      dict set Var   filename          "filename labelentry"         ;#PROFILE
      dict set Var   filematrix        "filename labelentry"         ;#MATRIX
      dict set Var   file              "img labelentry"              ;#ADD SUB DIV PROD REGISTERFINE
      dict set Var   bias              "img labelentry"              ;#OPT FLAT PRETRAITEMENT
      dict set Var   dark              "img labelentry"              ;#OPT FLAT PRETRAITEMENT
      dict set Var   flat              "img labelentry"              ;#PRETRAITEMENT
      dict set Var   mini              "double labelentry"           ;#CLIP
      dict set Var   maxi              "double labelentry"           ;#CLIP
      dict set Var   opt_black         "boolean checkbutton"         ;#PRETRAITEMENT
      dict set Var   methode           "boolean radiobutton"         ;#DARK
      dict set Var   plan              "boolean radiobutton"         ;#INTERCORRELATION
      dict set Var   kernel_width      "integer combobox"            ;#FILTER
      dict set Var   kernel_coef       "integer combobox"            ;#FILTER
      dict set Var   type_threshold    "integer combobox"            ;#FILTER
      dict set Var   image_ref         "img labelentry"              ;#CENTER
      dict set Var   matchwcs          "boolean checkbutton"         ;#REGISTER
      dict set Var   translate         "alpha combobox"              ;#REGISTER
      dict set Var   delta             "integer labelentry"          ;#REGISTERFINE
      dict set Var   oversampling      "integer labelentry"          ;#REGISTERFINE
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
         return [::prtr::avertiUser err_file_nb $nb_images]
      }

      #--   nom de sortie defini ?
      if {$private(function) ni [list "PROFILE direction=x" "PROFILE direction=y" "MATRIX"]} {

         if {$prtr::out eq "" || $prtr::out eq "\"\""} {
            return [::prtr::avertiUser sortie_generique]
         }

         #--   separe les elements
         set info [::prtr::getInfoFile $::prtr::out]
         set dir "[lindex $info 0]"
         set ::prtr::generique "[lindex $info 1]"
         set extension "[lindex $info 2]"

         if {![file exists $dir]} {
            return [::prtr::avertiUser err_file_dir $dir]
         } else {
            set ::prtr::dir_out $dir
         }

         #--   verifie l'extension si l'utilisateur en a donnee une
         if {$extension ne "" && $extension ne "$::prtr::ext"} {
            return [::prtr::avertiUser err_file_ext "$prtr::out" "$::prtr::ext"]
         }

         #--   nom_court correct ?
         regexp -all {[\w_-]+} $::prtr::generique match
         if {![ info exists match] || $match ne $::prtr::generique} {
            return [::prtr::avertiUser err_file_generique]
         }

      } else {
         set ::prtr::dir_out "./"
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
            return [::prtr::avertiUser err_par_def $parametre ]
         } else {
            return ""
         }
      }

      if {$test == "boolean"} {
         #--   teste un parametre booleen
         if {$value == "1"}  {
            if {$parametre eq "opt_black" && ($::prtr::bias eq "" || $::prtr::dark eq "")} {
               return [::prtr::avertiUser err_opt_noir $parametre]
            } else {
               return "$parametre"
            }
         } elseif {$value in [list r g b]} {
            return "$parametre=$value"
         }
      } elseif {$test eq "alpha"} {
         #--   teste un parametre alphanumerique
         if {![string is $test -strict $value]} {
            return [::prtr::avertiUser err_par_type $parametre $test]
         }
         return "$parametre=$value"
      } elseif {$test in {double integer}} {
         #--   teste la nature de la variable
         if {![string is $test -strict $value]} {
            return [::prtr::avertiUser err_par_type $parametre $test]
         }
         if {$seuil eq ""} {
            #--   si pas controle dimensionnel
            return "$parametre=$value"
         } else {
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
            if {$value < $mini || $value > $seuil && $private(function) ni [list POL2REC RESIZE]}  {
               return [::prtr::avertiUser err_par_bornes $parametre]
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
            return [::prtr::avertiUser err_file_ext $parametre $::conf(extension,defaut)]
         }
         #--   verifie son orthographe
         regexp -all {[\w_-]+} $nom_court match
         if {![info exists match] || $nom_court ne "$match"} {
            return [::prtr::avertiUser err_par_name $parametre]
         }

         set row [lsearch [$private(tbl) getcolumns 1] $nom_court]
         if {$row >=0} {
            if {[lrange [$private(tbl) get $row] 2 end] eq $private(profil)} {
               #--   l'image est du meme type que celles selectionnee
               if {$nom_court in $private(todo)} {
                  #--   cas ou l'image deja ete selectionnee
                  #--   juste un message d'avertissement
                  ::prtr::avertiUser err_file_select $value
               }
               return "$parametre=$nom_court$extension"
            } else {
               #--   cas du fichier de type different
               return [::prtr::avertiUser err_file_type $parametre]
            }
         } else {
           #--   l'image vient d'un autre repertoire
            #--   verifie si elle existe
            if {![file exists $value]} {
               return [::prtr::avertiUser err_no_file $value]
            }

            #--   verifie les dimensions des images
            lassign [::prtr::analyseFitsHeader $value] naxis naxis3 naxis1 naxis2
            #--   test non valable pour POL2REC
            if {[lindex $private(profil) 1] ne "${naxis1} X ${naxis2}" && $private(function) ne "POL2REC"} {
              return [::prtr::avertiUser err_file_dim $value]
            }

            if {$naxis eq "2"} {
               set type "M"
            } elseif {$naxis eq "3" && $naxis eq "3"} {
               set type "C"
            }

            switch $private(function) {
               OPT      {  #--   verifie que l'image est de meme nature que l'image d'entree
                           if {$type ne "[lindex $private(profil) 0]"} {
                              return [::prtr::avertiUser err_file_type $parametre]
                           }
                        }
               MAITRE   {  #--   verifie que l'image n'est pas une image RGB
                           if {$naxis eq "3" && $naxis3 eq "3"} {
                              return [::prtr::avertiUser err_par_file $parametre]
                           }
                        }
               CENTER   {  #--   verifie que l'image n'est pas une image RGB
                           if {$naxis eq "3" && $naxis3 eq "3"} {
                              return [::prtr::avertiUser err_par_file $parametre]
                           }
                        }
            }

            return "\"$parametre=$value\""
         }
      } elseif {$test eq "liste"} {
         #--   il doit y avoir exactement 6 parametres
         if {[llength $value] ne 6 } {
            return [::prtr::avertiUser err_par_def $parametre]
         }
         #--   tous les parametres doivent etre numeriques
         blt::vector create temp -watchunset 1
         if {[catch {temp append $value}]} {
            blt::vector destroy temp
            return [::prtr::avertiUser err_par_def $parametre]
         }
         #--   teste les valeurs
         if {[expr {$temp(1)*$temp(3)-$temp(0)*$temp(4)}] == "0"} {
            blt::vector destroy temp
            return [::prtr::avertiUser err_list_val $parametre]
         }
         blt::vector destroy temp
         return "\"paramresample=$value\""
      }
   }

   #--------------------------------------------------------------------------
   #  ::prtr::getInfoFile file
   #  Retourne le directory, le nom court et l'extension suivie ou non de .gz
   #--------------------------------------------------------------------------
   proc getInfoFile {file} {

      set dir [file dirname $file]
      if {$dir eq "."} {append dir /}
      set nom_avec_extensions "[file tail $file]"
      #--   extrait l'extension
      set extensions ""
      regexp {(\.[a-zA-Z]{3,4}|\.[a-zA-Z]{3,4}.gz)} $nom_avec_extensions extensions
      #--   ote toutes les extensions du nom
      regsub "$extensions" $nom_avec_extensions "" nom_court
      return [list $dir $nom_court $extensions]
   }

   #--------------------------------------------------------------------------
   #  ::prtr::cmdExec data options
   #  Exemple ::prtr::cmdExec [ list "IMA/SERIES" "$liste_generique_avec_index" "$nom_sortie" "ADD" "bitpix=16" ]
   #  Procedure lancee par le bouton Appliquer
   #--------------------------------------------------------------------------
   proc cmdExec { data options } {
      global conf

      set dir  $::audace(rep_images)
      cd $dir
      foreach {select imgList dirOut nameOut extIn function} $data {break}

      #--   fonctions necessitant une indexation de parametres en .fit ou .txt
      set filtre_file [list ADD SUB DIV PROD OPT]
      set filtre_txt [list "PROFILE direction=x" "PROFILE direction=y" MATRIX]
      set filtres [concat $filtre_file $filtre_txt]
      set nb_img [llength $imgList]

      #--   sauvegarde des parametres utilisateur
      if {$function eq "BACK"} {
         foreach var {back_kernel back_threshold} {
            set result [lsearch -regexp -inline $options "${var}"]
            regsub "${var}=" $result "" conf(prtr,back,$var)
         }
      } elseif {$function eq "RESAMPLE"} {
         set result [lsearch -regexp -inline $options "paramresample"]
         regsub "paramresample=" $result "" conf(prtr,resample,paramresample)
      } elseif {$function eq "SK"} {
         set result [lsearch -regexp -inline $options "kappa"]
         regsub "kappa=" $result "" conf(prtr,sk,kappa)
      }

      #--   identifie le type d'images
      set type [::prtr::getImgType $imgList]

      #--   si compression
      if {$::conf(fichier,compres) eq "0"} {
         set ext $extIn
      } else {
         set to_compress ""
         regsub ".gz" $extIn "" ext
         #--   decompresse les fichiers .gz
         foreach img $imgList {
            gunzip $img$extIn
            #--   prepare la liste des compressions
            lappend to_compress [file join $dir $img$ext]
         }
      }

      #--   examine chaque fichier et
      #--   constitue la liste des nom en entree et en sortie
      if {$type eq "C"} {
         foreach file $imgList {
           ::prtr::decompRGB $file
            #--   liste les fichiers a traiter
            foreach k {r g b} {
               lappend list_$k ${file}$k
               lappend to_destroy ${file}$k
            }
         }
         set list_in [list "$list_r" "$list_g" "$list_b"]
         set list_out [list ${nameOut}r ${nameOut}g ${nameOut}b]
      } else {
         set gray "$imgList"
         set list_in [list $gray]
         set list_out [list $nameOut]
      }

      #--   gere le repertoire de sortie
      set rep $dirOut
      if {$dirOut eq "."} {set rep "$::audace(rep_images)"}

      #--   gere les indices de sortie
      set indiceOut "."
      #--   si plusieurs images de sortie
      if {$select eq "IMA/SERIES" && $nb_img ne "1"} {set indiceOut "1"}

      #--   RGB2R+G+B des images RGB passees en parametres
      if {$select eq "IMA/SERIES" && $function in {ADD SUB DIV PROD REGISTERFINE} && $type == "C"} {
         set data [::prtr::traiteImg $options file]
         set options [lindex $data 0]
         set img [lindex $data 1]
         ::prtr::decompRGB $img
          #--   ajoute l'image si elle a ete copiee
         if {[file dirname [lindex $data 2]] ne "$::audace(rep_images)" && [file dirname [lindex $data 2]] ne "."} {
            lappend to_destroy $img
         }
         #--   ajoute les plans couleurs issus de la conversion
         lappend to_destroy ${img}r ${img}g ${img}b
      }

      #--   fixe le generique de sortie sans indice ni plan couleur ni extension
      set racine [file join $rep $nameOut]
      if {[string index $options 0] eq " "} {
         set options [string range $options 1 end]
      }

      set catchError [catch {

         foreach file_type $list_in file_out $list_out {

            if {$type eq "C"} {set color [string index [lindex $file_type 0] end]}

            if {($type eq "C") && ($select eq "IMA/SERIES") && ($function in $filtres)} {
               regsub -all "$ext" $options "${color}$ext" options
               regsub -all ".txt" $options "${color}.txt" options
            }

            if {$function ni [list "REGISTER translate=never" "REGISTER translate=before"]} {

               set script "$select . \"$file_type\" * * $ext \"$rep\" $file_out $indiceOut $ext $function $options"
               ::prtr::editScript $script
               ttscript2 $script

            } else {

               set n [llength "$file_type"]
               set index [lsearch -regexp $options "normaflux"]
               incr index
               set options1 "[lrange $options $index end]"

               set objefile "dummy"
               set script1 "IMA/SERIES . \"$file_type\" * * $ext . \"$objefile\" 1 $ext STAT objefile $options1"
               set script2 "IMA/SERIES . \"$objefile\" 1 $n $ext . $file_out 1 $ext $function $options"
               set script3 "IMA/SERIES . \"$objefile\" 1 $n $ext . . . . DELETE"
               foreach script {script1 script2 script3} {
                  ::prtr::editScript [set $script]
                  ttscript2 [set $script]
               }
               file delete com.lst dif.lst eq.lst in.lst ref.lst xy.lst
            }

            if {($type eq "C") && ($select eq "IMA/SERIES") && ($function in $filtres)} {
               regsub -all "(r|g|b)$ext" $options "$ext" options
               regsub -all "(r|g|b)\.txt" $options ".txt" options
            }

            if {$type eq "C" && $indiceOut eq "1"} {
               for {set i 1} {$i <= $nb_img} {incr i} {
                  #--   intervertit le nom du plan et l'indice
                  file rename -force "$racine$color$i$ext" "$racine$i$color$ext"
               }
            }
         }

         #--   convertir en RGB
         if {$indiceOut eq "."} {
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
   #  ::prtr::traiteImg options p
   #  Copie l'image operande et modifie le parametre file en consequence
   #  Retourne una liste raccourcie des options et le nom generique du fichier
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
      set ext [file extension $file]
      set generique [file rootname [file tail $file]]
      #--   recopie le fichier dans rep_images
      if {[file dirname $file] ni [list "$::audace(rep_images)" "."]} {
         file copy -force $file $::audace(rep_images)
      }
      #--   remplace le parametre dans options
      set options [lreplace $options $k $k "$pattern$generique$ext"]
      return [list $options $generique $file]
   }

   #--------------------------------------------------------------------------
   #  ::prtr::decompRGB file
   #  Decompose l'image couleur en plans couleurs
   #--------------------------------------------------------------------------
   proc decompRGB {file} {

      set ext $::prtr::ext
      set nom_sans_extension [file join $::audace(rep_images) $file]
      ::conv2::Do_rgb2r+g+b $nom_sans_extension$ext $nom_sans_extension
   }

   #--------------------------------------------------------------------------
   #  ::prtr::convertitRGB nameOut
   #  Reconstitue l'image couleur et efface les plans couleurs
   #  Parametre : nom de sortie (avec ou sans indice) de l'image
   #--------------------------------------------------------------------------
   proc convertitRGB {nameOut} {

      set file [file rootname $nameOut]
      set ext [file extension $nameOut]
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
   proc getImgType { files } {
      variable private
      variable bd

      #--   accelere pour le cas particulier d'une image isolee
      if {[llength $files] eq "1"} {
         set w "$private(tbl)"
         set k [lsearch [$w getcolumns 1] $files]
         return "[$w cellcget $k,2 -text]"
      }

      blt::vector create Vnaxis Vnaxis3 -watchunset 1
      foreach file $files {
         foreach {naxis naxis3} [lindex [array get bd $file] 1] {break}
         Vnaxis append $naxis
         Vnaxis3 append $naxis3
      }
      switch [Vnaxis3 length] 0 {set type "M"} [Vnaxis length] {set type "C"} default {set type "error"}
      blt::vector destroy Vnaxis Vnaxis3
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
   #  ::prtr::clipMinMax data options
   #  Ex-tournement de multi-ecreter
   #--------------------------------------------------------------------------
   proc clipMinMax { data options } {

      lassign $data imgList dirOut nameOut extOut
      set l [llength $imgList]

      if {$dirOut eq "."} {set dirOut $::audace(rep_images)}

      #---  extrait les valeurs numeriques
      foreach type {mini maxi bitpix} {
        lassign [::prtr::extractData $options "$type"] options $type
      }
      set bitpix [::prtr::convertBitPix2BitPix $bitpix]

      #--   sauvegarde les reglages utilisateurs
      set ::conf(prtr,clip,clip_mini) $mini
      set ::conf(prtr,clip,clip_maxi) $maxi

      set catchError [catch {

         set buf_clip [::buf::create]
         buf$buf_clip extension $extOut
         if {$bitpix ne ""} {buf$buf_clip bitpix $bitpix}
         set l [llength $imgList]

         buf$buf_clip load  [file join $dirOut [lindex $imgList 0]$extOut]
         #--   identifie le type d'images
         foreach kwd {NAXIS NAXIS3} {
            set [string tolower $kwd] [lindex [buf$buf_clip getkwd $kwd] 1]
         }

         set type M
         if {$naxis eq "3" && $naxis eq "3"} {set type C}

         foreach in $imgList {
            set index [lsearch $imgList $imgList]
            #--   decompose l'image RGB
            if {$type eq "C"} {
               ::prtr::decompRGB $in
               foreach color {r g b} {
                  buf$buf_clip load [file join $dirOut $imgList$color$extOut]
                  buf$buf_clip clipmin $mini
                  buf$buf_clip clipmax $maxi
                  if {$l == "1"} {
                     set nameOut [file join $dirOut $nameOut]
                  } else {
                     set nameOut [file join $dirOut $nameOut$index]
                  }
                  buf$buf_clip save $nameOut$color$extOut
               }
               #--   convertit en RGB
               ::prtr::convertitRGB $nameOut$extOut
               #--   efface les plans couleurs intermediaires
               file delete [file join $dirOut ${imgList}r$extOut] [file join $dirOut ${imgList}g$extOut] \
                  [file join $dirOut ${imgList}b$extOut]
            }  else {
               buf$buf_clip load [file join $dirOut $imgList$extOut]
               buf$buf_clip clipmin $mini
               buf$buf_clip clipmax $maxi
               if {$l == "1"} {
                  set nameOut [file join $dirOut $nameOut]
               } else {
                  set nameOut [file join $dirOut $nameOut$index]
               }
               buf$buf_clip save $nameOut$extOut
            }
         }
         ::buf::delete $buf_clip
      } ErrInfo]
      if {$catchError eq "1"} {::prtr::Error "$ErrInfo"}
      return $catchError
   }

   #--------------------------------------------------------------------------
   #  ::prtr::cmdRot data options
   #  Procedure lancee par le bouton Appliquer
   #--------------------------------------------------------------------------
   proc cmdRot { data options } {

      set dir $::audace(rep_images)
      cd $dir
      foreach {imgList dirOut nameOut extIn function} $data {break}
      set nb_img [llength $imgList]

      #--   si compression
      if {$::conf(fichier,compres) eq "0"} {
         set ext $extIn
      } else {
         set to_compress ""
         regsub ".gz" $extIn "" ext
         #--   decompresse les fichiers .gz
         foreach img $imgList {
            gunzip $img$extIn
            #--   prepare la liste des compressions
            lappend to_compress [file join $dir $img$ext]
         }
      }

      #--   examine chaque fichier et
      #--   constitue la liste des nom en entree et en sortie
      #--   identifie le type d'images
      set b [::buf::create]
      buf$b load [lindex $imgList 0]$extIn
      foreach kwd {NAXIS NAXIS3} {
         set [string tolower $kwd] [lindex [buf$b getkwd $kwd] 1]
      }
      ::buf::delete $b

      set type M
      if {$naxis eq "3" && $naxis eq "3"} {set type C}
      if {$type eq "C"} {
         foreach file $imgList {
            ::prtr::decompRGB $file
            #--   liste les fichiers a traiter
            foreach k {r g b} {
               lappend list_$k ${file}$k
               lappend to_destroy ${file}$k
            }
         }
         set list_in [list "$list_r" "$list_g" "$list_b"]
         set list_out [list ${nameOut}r ${nameOut}g ${nameOut}b]
      } else {
         set gray "$imgList"
         set list_in [list $gray]
         set list_out [list $nameOut]
      }

      #--   gere le repertoire de sortie
      set rep $dirOut
      if {$dirOut eq "."} {set rep "$::audace(rep_images)"}

      #--   gere les indices de sortie
      if {$nb_img eq "1"} {
         set indiceOut "."
         set indFinal "."
      } else {
         set indiceOut "1"
         set indFinal $nb_img
      }

      #--   fixe le generique de sortie sans indice ni plan couleur ni extension
      set racine [file join $rep $nameOut]

      set catchError [catch {

         foreach file_type $list_in file_out $list_out {

            if {$type eq "C"} {set color [string index [lindex $file_type 0] end]}

            switch -exact $function {
               "ROT+90" {  set script1 "IMA/SERIES . \"$file_type\" * * $ext . temp $indiceOut $ext INVERT xy $options"
                           set script2 "IMA/SERIES . temp $indiceOut $indFinal $ext \"$rep\" $file_out $indiceOut $ext INVERT flip $options"
                        }
               "ROT180" {  set script1 "IMA/SERIES . \"$file_type\" * * $ext . temp $indiceOut $ext INVERT mirror $options"
                           set script2 "IMA/SERIES . temp $indiceOut $indFinal $ext \"$rep\" $file_out $indiceOut $ext INVERT flip $options"
                        }
               "ROT-90" {  set script1 "IMA/SERIES . \"$file_type\" * * $ext . temp $indiceOut $ext INVERT flip $options"
                           set script2 "IMA/SERIES . temp $indiceOut $indFinal $ext \"$rep\" $file_out $indiceOut $ext INVERT xy $options"
                        }
            }

            if {$nb_img eq "1"} {
               lappend to_destroy temp
            } else {
               for {set i 1} {$i <= $nb_img} {incr i} {
                  lappend to_destroy temp$i
               }
            }

            ::prtr::editScript $script1
            ttscript2 $script1
            ::prtr::editScript $script2
            ttscript2 $script2

            if {$type eq "C" && $indiceOut eq "1"} {
               for {set i 1} {$i <= $nb_img} {incr i} {
                  #--   intervertit le nom du plan et l'indice
                  file rename -force "$racine$color$i$ext" "$racine$i$color$ext"
               }
            }
         }

         #--   convertir en RGB
         if {$indiceOut eq "."} {
            if {$type eq "C"} {::prtr::convertitRGB $racine$ext}
         } else {
            for {set i 1} {$i <= $nb_img} {incr i} {
               if {$type eq "C"} {::prtr::convertitRGB $racine$i$ext}
            }
         }

         #--   recompresse les fichiers d'entree
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
   #  ::prtr::cmdMasqueFlou data options
   #  Procedure lancee par le bouton Appliquer
   #--------------------------------------------------------------------------
   proc cmdMasqueFlou { data options } {
      global conf

      set dir  $::audace(rep_images)
      cd $dir
      foreach {imgList dirOut nameOut extOut} $data {break}
      set nb_img [llength $imgList]

      set b [::buf::create]
      buf$b load [lindex $imgList 0]
      foreach kwd {NAXIS NAXIS3} {
         set [string tolower $kwd] [lindex [buf$b getkwd $kwd] 1]
      }
      set type M
      if {$naxis eq "3" && $naxis eq "3"} {set type C}
      ::buf::delete $b

      #--   si compression
      if {$::conf(fichier,compres) eq "0"} {
         set ext $extOut
      } else {
         set to_compress ""
         regsub ".gz" $extOut "" ext
         #--   decompresse les fichiers .gz
         foreach img $imgList {
            gunzip $img$extOut
            #--   prepare la liste des compressions
            lappend to_compress [file join $dir $img$ext]
         }
      }

      #--   examine chaque fichier et
      #--   constitue la liste des nom en entree et en sortie
      if {$type eq "C"} {
         foreach file $imgList {
            ::prtr::decompRGB $file
            #--   liste les fichiers a traiter
            foreach k {r g b} {
               lappend list_$k ${file}$k
               lappend to_destroy ${file}$k
            }
         }
         set list_in [list "$list_r" "$list_g" "$list_b"]
         set list_out [list ${nameOut}r ${nameOut}g ${nameOut}b]
      } else {
        set gray "$imgList"
         set list_in [list $gray]
         set list_out [list $nameOut]
      }

      #--   gere le repertoire de sortie
      set rep $dirOut
      if {$dirOut eq "."} {set rep "$::audace(rep_images)"}

      #--   gere les indices de sortie
      set indiceOut "."
      #--   si plusieurs images de sortie
      if {$nb_img eq "1"} {
         set indiceOut "."
         set indFinal "."
      } else {
         set indiceOut "1"
         set indFinal $nb_img
      }

      #--   fixe le generique de sortie sans indice ni plan couleur ni extension
      set racine [file join $rep $nameOut]

      #--   extrait la valeur de sigma
      lassign [::prtr::extractData $options sigma] options sigma

      #--   extrait la valeur de la constante multiplicative
      lassign [::prtr::extractData $options constant] options constant

      #--   sauvegarde les reglages utilisateurs
      set conf(prtr,flou,sigma) $sigma
      set conf(prtr,flou,constant) $constant

      #--   il ne reste dans options que les options TT classiques (bitpix, skylevel, nullpixel)

      set catchError [catch {

         foreach file_type $list_in file_out $list_out {

            if {$type eq "C"} {set color [string index [lindex $file_type 0] end]}
            set script1 "IMA/SERIES . \"$file_type\" * * $ext . $file_out $indiceOut $ext CONV kernel_type=gaussian sigma=$sigma $options"
            set script2 "IMA/SERIES . \"$file_type\" * * $ext . $file_out $indiceOut $ext SUB \"file=./$file_out\" $options"
            set script3 "IMA/SERIES . \"$file_out\" $indiceOut $indFinal $ext . $file_out $indiceOut $ext MULT constant=$constant $options"
            set script4 "IMA/SERIES . \"$file_type\" * * $ext . $file_out $indiceOut $ext ADD \"file=./$file_out\" $options"

            ::prtr::editScript $script1
            ttscript2 $script1
            ::prtr::editScript $script2
            ttscript2 $script3
            ::prtr::editScript $script3
            ttscript2 $script3
            ::prtr::editScript $script4
            ttscript2 $script4

            if {$type eq "C" && $indiceOut eq "1"} {
               for {set i 1} {$i <= $nb_img} {incr i} {
                  #--   intervertit le nom du plan et l'indice
                  file rename -force "$racine$color$i$ext" "$racine$i$color$ext"
               }
            }
         }

         #--   convertir en RGB
         if {$indiceOut eq "."} {
            if {$type eq "C"} {::prtr::convertitRGB $racine$ext}
         } else {
            for {set i 1} {$i <= $nb_img} {incr i} {
               if {$type eq "C"} {::prtr::convertitRGB $racine$i$ext}
            }
         }

         #--   recompresse les fichiers d'entree
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

   #----------------------fonctions du pretraitement--------------------------

   #--------------------------------------------------------------------------
   #  ::prtr::faireOffset data options
   #  Fait la mediane des images d'offset
   #  Parmetres : donnees du script, options TT sous forme de listes
   #--------------------------------------------------------------------------
   proc faireOffset { data options } {

      cd $::audace(rep_images)
      set extOut $::conf(extension,defaut)
      lassign $data imgList dirOut nameOut extIn

      set script "IMA/STACK . \"$imgList\" * * $extIn \"$dirOut\" \"$nameOut\" .  $extOut MED"
      if {$options ne ""} {append script " " $options}
      ::prtr::editScript $script
      set catchError [catch {ttscript2 $script} ErrInfo]
      if {$catchError eq "1"} {::prtr::Error "$ErrInfo"}
      return $catchError
   }

   #--------------------------------------------------------------------------
   #  ::prtr::faireDark data options
   #  Applique la methode choisie apres soustraction de l'offset s'il existe
   #  Parmetres : donnees du script, options T sous forme de listes
   #--------------------------------------------------------------------------
   proc faireDark { data options } {

      cd $::audace(rep_images)
      set extOut $::conf(extension,defaut)
      lassign $data imgList dirOut nameOut extIn methode
      set l [llength $imgList]

      #--   cherche le nom de l'offset
      lassign [::prtr::extractData $options "bias"] options bias

      if {$bias eq ""} {::prtr::informeUser "faire_dark" "faire_offset"}

      set catchError [catch {
         if {$bias ne ""} {

            #--   soustrait l'offset des images
            set script "IMA/SERIES . \"$imgList\" * * $extIn . temp 1 $extOut SUB \"file=$bias\" "
            ::prtr::editScript $script
            ttscript2 "$script"

            #--   met a jour la liste des images a traiter
            set imgList [::prtr::buildNewList temp $l]

            #--   change l'extension des fichiers entrants
            set extIn $::conf(extension,defaut)
         }

         set script "IMA/STACK . \"$imgList\" * * $extIn \"$dirOut\" \"$nameOut\" . $extOut $methode"
         if {$options ne ""} {append script " " $options}
         ::prtr::editScript $script
         ttscript2 $script

         #--   detruit les fichiers temporaires
         if {[lsearch -regexp $imgList temp] >= "0"} {
            ttscript2 "IMA/SERIES . \"$imgList\" * * $extOut . . . . DELETE"
         }

      }  ErrInfo]
      if {$catchError eq "1"} {::prtr::Error "$ErrInfo"}
      return $catchError
   }

   #--------------------------------------------------------------------------
   #  ::prtr::faireFlat data options
   #--------------------------------------------------------------------------
   proc faireFlat { data options } {

      cd $::audace(rep_images)
      set extOut $::conf(extension,defaut)
      lassign $data imgList dirOut nameOut extIn
      set l [llength $imgList]

      #--   isole le nom complet de l'image d'offset et de dark
      foreach type {bias dark} {
        lassign [::prtr::extractData $options "$type"] options $type
      }

      if {$bias eq ""} {::prtr::informeUser "faire_flat_field" "faire_offset"}
      if {$dark eq ""} {::prtr::informeUser "faire_flat_field" "faire_dark"}

      #--   cree l'image Offset+Dark si l'offset et/ou le dark existe
      if {$dark ne "" || $bias ne ""} {
         if {[::prtr::createOffset+Dark $dark $bias] ne "0"} {return 1}

         set file Offset+Dark$extOut

         if {[file exists $file]} {
            if {[::prtr::subsOffset+Dark $data $file] ne "0"} {return 1}

            #--   met a jour la liste des images a traiter
            set imgList [::prtr::buildNewList temp $l]

            #--   extrait la valeur de normalisation de l'offset
            lassign [::prtr::extractData $options "normoffset_value"] options opt

            #--   normalise l'offset
            set script "IMA/SERIES . \"$imgList\" * * $extOut . temp 1 $extOut NORMOFFSET normoffset_value=$opt"
            ::prtr::editScript $script
            ttscript2 "$script"
            set extIn $extOut
         }
      }

      set catchError [catch {

         set script "IMA/STACK . \"$imgList\" * * $extOut \"$dirOut\" $nameOut . $extOut MED "
         if {$options ne ""} {append script "$options"}
         ::prtr::editScript $script
         ttscript2 "$script"

         #--   supprime les fichiers intermediaires
         if {[lsearch -regexp $imgList temp] >= "0"} {
            ttscript2 "IMA/SERIES . \"$imgList\" * * $extOut . . . . DELETE"
         }
      }  ErrInfo]
      if {$catchError eq "1"} {::prtr::Error "$ErrInfo"}
      return $catchError
   }

   #--------------------------------------------------------------------------
   #  ::prtr::faireOptNoir data options
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
      lassign [::prtr::extractData $options "opt_black"] options opt

      #--   extrait le nom des fichiers operandes
      foreach type {bias dark flat} {
        lassign [::prtr::extractData $options "$type"] options $type
      }

      if {$flat eq ""} {::prtr::informeUser "pretraitee" "faire_flat_field"}

      set catchError [catch {
         #--   cree les images optimisees dans le repertoire de destination
         set script "IMA/SERIES . \"$imgList\" $indexIn $indexIn $extIn \"$dirOut\" $nameOut $indexOut $extOut OPT \"bias=$bias\" \"dark=$dark\" "
         ::prtr::editScript $script
         ttscript2 "$script"

         #--   divise les images par le flat s'il existe et multiplie par la constante
         if {$flat ne ""} {

            #--   met a jour la liste des images a traiter
            set imgList [::prtr::buildNewList $nameOut $l]

            #--   divise les images par le flat
            set script "IMA/SERIES \"$dirOut\" \"$imgList\" $indexIn $indexIn $extOut \"$dirOut\" $nameOut $extOut $extOut DIV \"file=$flat\" $options"
            ::prtr::editScript $script
            ttscript2 "$script"
         }
      }  ErrInfo]
      if {$catchError eq "1"} {::prtr::Error "$ErrInfo"}
      return $catchError
   }

   #--------------------------------------------------------------------------
   #  ::prtr::fairePretraitement data options
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
        lassign [::prtr::extractData $options "$type"] options $type
      }

      if {$bias eq ""} {::prtr::informeUser "pretraitee" "faire_offset"}
      if {$dark eq ""} {::prtr::informeUser "pretraitee" "faire_dark"}
      if {$flat eq ""} {::prtr::informeUser "pretraitee" "faire_flat_field"}

     if {$dark ne "" || $bias ne ""} {
         if {[::prtr::createOffset+Dark $dark $bias] ne "0"} {return 1}
         set file Offset+Dark$extOut
         if {[file exists $file]} {

            if {[::prtr::subsOffset+Dark $data $file] ne "0"} {return 1}

            #--   met a jour la liste des images a traiter
            set imgList [::prtr::buildNewList temp $l]
            set extIn $extOut
         }
      }

      set catchError [catch {
         if {$flat ne ""} {
            #--   divise les images par le flat et multiplie par la constante
            set script "IMA/SERIES . \"$imgList\" $indexIn $indexIn $extIn \"$dirOut\" $nameOut $indexOut $extOut DIV \"file=$flat\" $options"
            ::prtr::editScript $script
            ttscript2 "$script"

            #--   detruit les fichiers temporaires
            if {[lsearch -regexp $imgList temp] >= "0"} {
               set script "IMA/SERIES . \"$imgList\" $indexIn $indexIn $extIn . . . . DELETE"
               ::prtr::editScript $script
               ttscript2 "$script"
            }
         } else {
            #--   renomme les fichiers temp en l'absence de flat
            foreach file $imgList {
               regsub "temp" $file "$nameOut" newName
               file rename -force [file join $dirOut $file$extOut] [file join $dirOut $newName$extOut]
            }
         }
       }  ErrInfo]

      if {$catchError eq "1"} {::prtr::Error "$ErrInfo"}
      return $catchError
   }

   #--------------------------------------------------------------------------
   #  ::prtr::createOffset+Dark file1 file2
   #  Cree l'image Offset+Dark (non zippee) dans le repertoire audace(rep-images)
   #  a partir d'une image d'offset et/ou de dark (zippes ou non)
   #  Le dark et l'offset peuvent etre dans un repertoire different de audace(rep_images)
   #--------------------------------------------------------------------------
   proc createOffset+Dark { file1 file2 } {

      set catchError 0
      set nameOut "Offset+Dark"
      set extOut $::conf(extension,defaut)
      if {$file1 eq ""} {
         file copy -force $file2 $nameOut$extOut
      } elseif  {$file2 eq ""} {
         file copy -force $file1 $nameOut$extOut
      } else {
         #--   cas de deux fichiers
         set catchError [catch {
            set dir [file dirname $file1]
            set nameIn [file tail $file1]
            set script "IMA/SERIES \"$dir\" $nameIn . . . . $nameOut . $extOut ADD \"file=$file2\" "
            ::prtr::editScript $script
            ttscript2 "$script"
         }  ErrInfo]
      }
      if {$catchError eq "1"} {::prtr::Error "$ErrInfo"}
      return $catchError
   }

   #--------------------------------------------------------------------------
   #  ::prtr::subsOffset+Dark data file
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
         ::prtr::editScript $script
         ttscript2 "$script"
         #--   efface le fichier provisoire
         file delete $file
      }  ErrInfo]

      if {$catchError eq "1"} {::prtr::Error "$ErrInfo"}
      return $catchError
   }

   #--------------------------------------------------------------------------
   #  ::prtr::editScript script
   #  Edit le script sur la console
   #--------------------------------------------------------------------------
   proc editScript { script } {

      if {[info exists ::prtr::script] && $::prtr::script eq "1"} {
         ::console::affiche_resultat "$script\n"
      }
   }

   #--------------------------------------------------------------------------
   #  ::prtr::extractData options what
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
   #  ::prtr::buildNewList newName l
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

   #--------------------------------------------------------------------------
   #  ::prtr::informeUser v1 v2
   #  Affiche une info sur la console sur l'absence d'une image maître
   #--------------------------------------------------------------------------
   proc informeUser { v1 v2 } {
      global caption

      ::console::affiche_resultat "[format $caption(prtr,sans) \
         $caption(audace,menu,$v1) $caption(audace,menu,$v2)]\n"
   }

   #--------------------------------------------------------------------------
   #  ::prtr::cmdAligner data options
   #  Aligne une ou plusieurs images sur une image de reference et les fenetre
   #--------------------------------------------------------------------------
   proc cmdAligner { data options } {

      cd $::audace(rep_images)
      set extOut $::conf(extension,defaut)
      lassign $data imgList dirOut nameOut extIn
      set nbImg [llength $imgList]
      set b [::buf::create]
      set toResize ""
      set toDestroy ""

      #--   extrait le nom du plan principal
      lassign [::prtr::extractData $options "plan"] options plan_ref

      #--   extrait le nom de l'image de reference
      lassign [::prtr::extractData $options "image_ref"] options imgRef

      #--   travaille sur une copie de l'image de refrence
      file copy -force $imgRef reference$extOut
      set toDestroy [concat $toDestroy reference]

      #--   saisit le nom de sortie de l'image de correlation croisee
      set dest crosscorrelation$extOut

      #--   cree deux vecteurs
      blt::vector create Vx Vy -watchunset 1

      #--   si compression
      if {$::conf(fichier,compres) eq "0"} {
         set ext $extOut
      } else {
         set toCompress ""
         regsub ".gz" $extIn "" ext
         #--   decompresse les fichiers .gz
         foreach img $imgList {
            gunzip $img$extIn
            #--   prepare la liste des compressions
            lappend toCompress [file join $dir $img$ext]
         }
      }

      #--   identifie le type d'images
      buf$b load $imgRef reference$extOut
      foreach kwd {NAXIS NAXIS1 NAXIS2 NAXIS3} {
         set [string tolower $kwd] [lindex [buf$b getkwd $kwd] 1]
      }

      set type M
      if {$naxis eq "3" && $naxis eq "3"} {set type C}
      set box [list 1 1 $naxis1 $naxis2]

      if {$type ne "C"} {
         set ref "reference$extOut"
      } else {
         #--   decompose toutes les images en plans couleurs
         foreach file "$imgList reference" {
            ::prtr::decompRGB $file
            set toDestroy [concat $toDestroy ${file}r ${file}g ${file}b]
         }
         #--   indique le plan vert de l'image de reference
         set ref "reference${plan_ref}$extOut"
      }

      #--   gere le repertoire de sortie
      set rep $dirOut
      if {$dirOut eq "."} {set rep "$::audace(rep_images)"}

      #--   cherche la correlation
      foreach img $imgList {

         set plan $img
         if {$type eq "C"} {
            set plan ${img}${plan_ref}
         }

         set catchError [catch {icorr2d $ref ${plan}$extIn $dest} ErrInfo]

         if {$catchError eq "1"} {
            ::prtr::Error "$ErrInfo"
            return $catchError
         }

         #--   charge l'image d'intercorrelation
         buf$b load $dest

         #--cherche les coordonnees du maximum
         set result [::prtr::searchMax $box $b]
         if {$result ne "1"} {

            #--   cherche les coordonnees du point avec l'intensite maximale
            lassign $result x y

            #--   calcule la translation a effectuer
            set dx [expr {$x-1-$naxis1/2}]
            set dy [expr {$y-1-$naxis2/2}]

            #--   memorise les resultat pour le fenetrage
            Vx append $dx
            Vy append $dy

            if {$type ne "C"} {
               set todo $img
               lassign [list . . .] indiceDeb  indiceFin  indiceOut
            } else {
               set todo [list ${img}r ${img}g ${img}b]
               lassign [list * * 1] indiceDeb  indiceFin  indiceOut
            }

            #--   translate chaque image ou les 3 plans couleurs
            #--   ca marche aussi si dx=0 et/ou dy=0
            set catchError [catch {
               set script "IMA/SERIES . \"$todo\" $indiceDeb $indiceFin $extIn . temp$img $indiceOut $extOut TRANS trans_x=$dx trans_y=$dy $options"
               ::prtr::editScript $script
               ttscript2 "$script"

               #--   memorise la liste des fichiers
               if {$indiceOut ne "1"} {
                  lappend toResize temp$img
                  set toDestroy [concat $toDestroy temp$img]
               } else {
                  foreach i {1 2 3} p {r g b} {
                     file rename -force "temp$img$i$extOut" "temp$img$p$extOut"
                     lappend toResize temp$img$p
                     set toDestroy [concat $toDestroy temp$img$p]
                  }
               }
            } ErrInfo]

            if {$catchError eq "1"} {
               ::prtr::Error "$ErrInfo"
               return $catchError
            }

            file delete $dest
         }
      }

      #--   supprime le buffer provisoire
      ::buf::delete $b

      #--   calcule les limites du fenetrage
      foreach {vector var} [list Vx x Vy y] {

        if {$var eq "x"} {
            set naxis $naxis1
         } else {
            set naxis $naxis2
         }
         lassign [list 1 $naxis] ${var}1 ${var}2

         $vector sort
         set min [$vector range 0 0]
        set max [$vector range end end]

         if {$min > "0"} {
            set ${var}1 [expr {int($max+1)}]
         } elseif {$max < "0"} {
            set ${var}2 [expr {int($naxis+$min)}]
         } else {
            set ${var}1 [expr {int($max+1)}]
            set ${var}2 [expr {int($naxis+$min)}]
        }
      }
      blt::vector destroy Vx Vy

      #--   liste les fichiers a fenetrer
      if {$type ne "C"} {
         set toResize [concat reference $toResize]
      } else {
         set toResize [concat referencer referenceg referenceb $toResize]
      }

      #--   ote l'option nullpixel si elle existe
      regsub "[lsearch -regexp -inline $options "nullpixel=*"]" $options "" options

      #--   ca marche aussi si x1=1, y1=1, x2=naxis1 ou y2=naxis2
      set script "IMA/SERIES \"$dirOut\" \"$toResize\" * * $extOut \"$dirOut\" temp 1 $extOut WINDOW x1=$x1 x2=$x2 y1=$y1 y2=$y2 $options"

      ::prtr::editScript $script
      set catchError [catch {ttscript2 $script} ErrInfo]
      if {$catchError eq "1"} {
         ::prtr::Error "$ErrInfo"
          return $catchError
      }

      #--   convertit en RGB
      if {$type eq "C"} {
         set limite [llength $toResize]
         set k "0"
         for {set i 1} {$i <= $limite} {incr i 3} {
            incr k
            foreach p [list $i [expr {$i+1}] [expr {$i+2}]] c {r g b } {
               file rename -force temp$p$extOut ${nameOut}$k$c$extOut
               set toDestroy [concat $toDestroy temp$p ${nameOut}$k$c]
            }
           ::prtr::convertitRGB ${nameOut}$k$extOut
         }
      } else {
         set limite [llength $toResize]
         for {set i 1} {$i <= $limite} {incr i} {
            file rename -force temp$i$extOut ${nameOut}$i$extOut
            set toDestroy [concat $toDestroy temp$i]
         }
      }

      #--   recompresse les fichiers d'entree et les fichiers de sortie
      if {$::conf(fichier,compres) eq "1"} {
         foreach file $toCompress {gzip $file}
         set ext "$ext.gz"
      }

      #--   detruit les fichiers provisoires
      ttscript2 "IMA/SERIES . \"$toDestroy\" * * $extOut . . . . DELETE"
      return $catchError
   }

   #--------------------------------------------------------------------------
   #  ::prtr::searchMax box buf
   #  Retourne les coordonnees x y du maximum dans l'image affichee dans la fenetre
   #--------------------------------------------------------------------------
   proc searchMax { box buf } {

      lassign $box x1 y1 x2 y2
      set c [::buf::create]
      set d [::buf::create]
      buf$buf copyto $c
      buf$buf copyto $d

      #--   additionne les lignes et les colonnes
      set catchError [catch {
         buf$c imaseries "SORTY percent=100 y1=$y1 y2=$y2 height=1"
         buf$c imaseries "PROFILE direction=x offset=1 \"filename=sortli.txt\" "
         buf$d imaseries "SORTX percent=100 x1=$x1 x2=$x2 width=1"
         buf$d imaseries "PROFILE direction=y offset=1 \"filename=sortcol.txt\" "
      }  ErrInfo]

      ::buf::delete $c
      ::buf::delete $d

      if {$catchError eq "1"} {
         ::prtr::Error "$ErrInfo"
         return $catchError
      }

      foreach file {sortli.txt sortcol.txt} coord {x y} {
         set fd [open $file r+ ]
         set max "0"
         set $coord ""
         gets $fd value
         while {![eof $fd]} {
            gets $fd value
            lassign $value c v
            if {$v > $max} {
               set $coord $c
               set max $v
            } elseif {$v == $max} {
               lappend $coord $c
            }
         }
         close $fd
         file delete $file
      }

      #--   cherche la fraction de pixel
      set x [lindex $x end]
      set y [lindex $y end]
      set x1 [expr {int($x-5)}]
      set y1 [expr {int($y-5)}]
      set x2 [expr {int($x+5)}]
      set y2 [expr {int($y+5)}]

      set box [list $x1 $y1 $x2 $y2]
      lassign  [buf$buf centro $box] x y
      return [list $x $y]
   }

}

