#
# Fichier : updateaudela.tcl
# Description : outil de fabrication des fichier Kit et de deploiement des plugin
# Auteurs : Michel Pujol
# Mise a jour $Id: updateaudela.tcl,v 1.3 2007-04-14 08:35:25 robertdelmas Exp $
#

namespace eval ::updateaudela {
   package provide updateaudela 1.0

   #--- Chargement des captions pour recuperer le titre utilise par getPluginLabel
   source [ file join [file dirname [info script]] updateaudela.cap ]
}

#------------------------------------------------------------
#  ::updateaudela::getPluginProperty
#     retourne la valeur de la propriete
#
# parametre :
#    propertyName : nom de la propriete
# return : valeur de la propriete , ou "" si la propriete n'existe pas
#------------------------------------------------------------
proc ::updateaudela::getPluginProperty { propertyName } {
   switch $propertyName {
      function     { return "setup" }
      display      { return "window" }
   }
}

#------------------------------------------------------------
# ::updateaudela::initPlugin
#    initialise le plugin
#------------------------------------------------------------
proc ::updateaudela::initPlugin { tkbase } {

}

#------------------------------------------------------------
#  ::updateaudela::getPluginTitle
#     retourne le titre du plugin dans la langue de l'utilisateur
#------------------------------------------------------------
proc ::updateaudela::getPluginTitle { } {
   global caption

   return "$caption(updateaudela,title)"
}

#------------------------------------------------------------
#  ::updateaudela::getPluginType
#     retourne le type de plugin
#------------------------------------------------------------
proc ::updateaudela::getPluginType { } {
   return "tool"
}

#------------------------------------------------------------
#  deletePluginInstance
#     suppprime l'instance du plugin
#------------------------------------------------------------
proc ::updateaudela::deletePluginInstance { visuNo } {

}

#------------------------------------------------------------
# ::updateaudela::createPluginInstance
#    cree une instance l'outil
#
#------------------------------------------------------------
proc ::updateaudela::createPluginInstance { {in ""} { visuNo 1 } } {
   global conf
   global audace
   global caption
   variable private

   package require BWidget
   package require Tablelist

   package require starkit
   starkit::startup

   #--- Creation des variables si elles n'existaient pas
   if { ! [ info exists conf(updateaudela,position) ] }             { set conf(updateaudela,position)     "+250+75" }
   if { ! [ info exists conf(updateaudela,private(kitDirectory) ] } { set conf(updateaudela,kitDirectory) "$::audace(rep_install)" }

   set private(base)            $in
   set private(kitDirectory)    "$::audace(rep_install)"
   set private(pluginDirectory) "$::audace(rep_plugin)"
}

#------------------------------------------------------------
# ::updateaudela::startTool
#    affiche la fenetre de l'outil
#
#------------------------------------------------------------
proc ::updateaudela::startTool { visuNo } {
   variable private

   set this "$private(base).updateaudela"
   if { [winfo exists $this ] == 0 } {
      #--- j'affiche la fenetre
      ::confGenerique::run $this [namespace current] $visuNo nomodal
      #--- je remplie la fenetre
      ::updateaudela::fillKitTable
      ::updateaudela::fillPluginTree
   } else {
      focus $this
   }
}

#------------------------------------------------------------
# ::updateaudela::stopTool
#    masque la fenetre de l'outil
#
#------------------------------------------------------------
proc ::updateaudela::stopTool { visuNo } {
   variable private

   #--- rien à faire
}

#------------------------------------------------------------
#  ::updateaudela::confToWidget { }
#     copie les parametres du tableau conf() dans les variables des widgets
#------------------------------------------------------------
proc ::updateaudela::confToWidget { visuNo } {
   variable private
   global conf

   set private(position) "$conf(updateaudela,position)"
}

#------------------------------------------------------------
#  ::testaudela::deleteKit
#  supprime un plugin
#  param : aucun
#------------------------------------------------------------
proc ::updateaudela::deleteKit { {kitFileName "" }} {
   variable private

   if { $kitFileName == "" } {
      set selectedRow [$private(kitTable) curselection]
      if { $selectedRow == "" } {
         tk_messageBox -message "Error : no file selected" -icon error
         return
      }
      set kitFileName [$private(kitTable) cellcget $selectedRow,0 -text]
   }
   set kitFileFullName [file join $private(kitDirectory) $kitFileName]

   set message [format $::caption(updateaudela,confirmDelete) $kitFileFullName]
   set answer [tk_messageBox -message $message -type okcancel -icon question -title $::caption(updateaudela,title)]
   if { $answer == "ok" } {
      file delete -force $kitFileFullName
      ::updateaudela::fillKitTable
   }
}

#------------------------------------------------------------
#  ::testaudela::deletePlugin
#  supprime un plugin
#  param : aucun
#------------------------------------------------------------
proc ::updateaudela::deletePlugin { {pluginName "" } } {
   variable private

   if { $pluginName == "" } {
      #--- je recupere le nom du plugin selectionne
      set pluginName [$private(tree) selection get]
   }
   #--- je recupere le nom du fichier pkgIndex.tcl qui dans le champ data du noeud de l'arbre
   set pkgIndexFileName [$private(tree) itemcget $pluginName -data ]
   #--- j'extrais le repertoire du plugin
   set pluginDirectory [file dirname $pkgIndexFileName]
   if { [file exists ${pluginDirectory}] == "1" } {
      set message [format $::caption(updateaudela,confirmDelete) $pluginDirectory]
      set answer [tk_messageBox -message $message -type okcancel -icon question -title $::caption(updateaudela,title)]
      if { $answer == "ok" } {
         #--- j'efface le repertoire du plugin
         file delete -force $pluginDirectory
         #--- je met a jour la liste de plugins
         ::updateaudela::fillPluginTree
      }
   } else {
      set message [format $::caption(updateaudela,directoryNotExits) $pluginDirectory]
      :console::affiche_erreur "$message\n"
      tk_messageBox -message "$message. See console" -icon error
   }
}

#------------------------------------------------------------
#  ::updateaudela::getLabel
#  retourne le nom de la fenetre de configuration
#------------------------------------------------------------
proc ::updateaudela::getLabel { } {
   global caption

   return "$caption(updateaudela,title)"
}

#------------------------------------------------------------
#  ::updateaudela::fillConfigPage { }
#  fenetre de configuration
#------------------------------------------------------------
proc ::updateaudela::fillConfigPage { frm visuNo } {
   variable private
   global caption

   #--- Je memorise la reference de la frame
   set private(frm)      $frm
   set private(tree)     $frm.plugin.tree
   set private(kitTable) $frm.kit.table

   #--- J'initialise les variables des widgets
   confToWidget $visuNo

   #--- Je positione la fenetre
   wm resizable [ winfo toplevel $private(frm) ] 1 1
  ### wm geometry [ winfo toplevel $private(frm) ] $::conf(updateaudela,position)
   wm geometry [ winfo toplevel $private(frm) ] $private(position)

   #--- frame des kits
   TitleFrame $frm.kit -borderwidth 2 -text $caption(updateaudela,kitFrame)

      #--- table des fichiers kit
      tablelist::tablelist $frm.kit.table \
         -columns [ list \
            20 "Name" left  \
            ] \
         -xscrollcommand [list $frm.kit.xsb set] -yscrollcommand [list $frm.kit.ysb set] \
         -selectmode single \
         -stretch 0 \
         -activestyle none

      scrollbar $frm.kit.ysb -command "$frm.kit.table yview"
      scrollbar $frm.kit.xsb -command "$frm.kit.table xview" -orient horizontal

      #--- frame des boutons
      frame $frm.kit.buttons -borderwidth 0
      Button $frm.kit.buttons.refresh   -text "$caption(updateaudela,refresh)"  -command "::updateaudela::fillKitTable"
      Button $frm.kit.buttons.delete    -text "$caption(updateaudela,delete)"   -command "::updateaudela::deleteKit"
      Button $frm.kit.buttons.download  -text "$caption(updateaudela,download)"
      Button $frm.kit.buttons.show      -text "$caption(updateaudela,show)"     -command "::updateaudela::showKitContent"
      grid $frm.kit.buttons.refresh   -row 0 -column 0
      grid $frm.kit.buttons.show      -row 0 -column 1
      grid $frm.kit.buttons.delete    -row 0 -column 2
      #grid $frm.kit.buttons.download -row 0 -column 3

      grid $frm.kit.table         -in [$frm.kit getframe] -row 0 -column 0 -sticky nsew
      grid $frm.kit.ysb           -in [$frm.kit getframe] -row 0 -column 1 -sticky nsew
      grid $frm.kit.xsb           -in [$frm.kit getframe] -row 1 -column 0 -sticky ew
      grid $frm.kit.buttons       -in [$frm.kit getframe] -row 2 -column 0 -columnspan 2 -sticky ewns
      grid rowconfig    [$frm.kit getframe] 1 -weight 1
      grid columnconfig [$frm.kit getframe] 0 -weight 1

   #--- frame des plugins
   TitleFrame $frm.plugin -borderwidth 2 -text $caption(updateaudela,pluginFrame)
      #--- arbre des noms des fichiers
      Tree $frm.plugin.tree -xscrollcommand "$frm.plugin.xsb set" -yscrollcommand "$frm.plugin.ysb set"
      scrollbar $frm.plugin.ysb -command "$frm.plugin.tree yview"
      scrollbar $frm.plugin.xsb -command "$frm.plugin.tree xview" -orient horizontal

       #--- frame des boutons
      frame $frm.plugin.buttons -borderwidth 0
      Button $frm.plugin.buttons.refresh -text "$caption(updateaudela,refresh)" -command "::updateaudela::fillPluginTree"
      Button $frm.plugin.buttons.delete  -text "$caption(updateaudela,delete)"  -command "::updateaudela::deletePlugin"
      grid $frm.plugin.buttons.refresh  -row 0 -column 0
      grid $frm.plugin.buttons.delete   -row 0 -column 1

      grid $frm.plugin.tree      -in [$frm.plugin getframe] -row 0 -column 0 -sticky ewns
      grid $frm.plugin.ysb       -in [$frm.plugin getframe] -row 0 -column 1 -sticky nsew
      grid $frm.plugin.xsb       -in [$frm.plugin getframe] -row 1 -column 0 -sticky ew
      grid $frm.plugin.buttons   -in [$frm.plugin getframe] -row 2 -column 0 -columnspan 2 -sticky ewns
      grid rowconfig    [$frm.plugin getframe] 1 -weight 1
      grid columnconfig [$frm.plugin getframe] 0 -weight 1

   #--- frame de boutons
   frame $frm.button -borderwidth 2
      Button $frm.button.installPlugin -text "$caption(updateaudela,installPlugin) >>"  -command "::updateaudela::installPlugin"
      $frm.button.installPlugin configure -font "[$frm.button.installPlugin cget -font] bold"
      Button $frm.button.makeKit -text " << $caption(updateaudela,makeKit)"  -command "::updateaudela::makeKit"
      $frm.button.makeKit configure -font "[$frm.button.makeKit cget -font] bold"

      grid $frm.button.installPlugin  -row 0 -column 0   -padx 4 -pady 2
      grid $frm.button.makeKit        -row 1 -column 0   -padx 4 -pady 2

   grid $frm.kit         -row 0 -column 0 -sticky ewns
   grid $frm.plugin      -row 0 -column 1 -sticky ewns
   grid $frm.button      -row 1 -column 0 -columnspan 2 -sticky ewns

   grid rowconfig    $frm 0 -weight 1
   grid columnconfig $frm 0 -weight 1
   grid columnconfig $frm 1 -weight 1

}

#------------------------------------------------------------
#  ::testaudela::fillKitTable
#  affiche la liste des fichiers kit danas la table des kits
#  param : aucun
#------------------------------------------------------------
proc ::updateaudela::fillKitTable { } {
   variable private

   #--- je vide la table
   $private(kitTable) delete 0 end

   #--- je recupere la liste des fichiers kit presents
   set kitList [lsort -dictionary [glob -nocomplain -dir $private(kitDirectory) -type f "*.kit"]]
   #--- je remplis la table avec la liste des fichiers kit
   foreach kitFileFullName $kitList {
      set kitFileName [file tail $kitFileFullName]
      $private(kitTable) insert end [list "$kitFileName"  "" ""]
   }
}

#------------------------------------------------------------
#  ::testaudela::fillPluginTree
#  Recherche les plugin dans le repertoire private(pluginDirectory)
#  et ses sous repertoires .
#  Remplit l'arbre avec les sous-repertoires touves et insere les
#  plugins presents.
#
#  param : aucun
#------------------------------------------------------------
proc ::updateaudela::fillPluginTree { } {
   variable private

   #--- je vide l'arbre
   $private(tree) selection clear
   $private(tree) delete [$private(tree) nodes root]

   #--- je resupere la liste de types de plugin ( noms des sous-repertoires de private(pluginDirectory))
   set pluginTypeList [lsort -dictionary [glob -nocomplain -dir $private(pluginDirectory) -type d "*"]]
   #--- je remplis l'arbre avec les repertoires des plugin
   foreach typeDirectory $pluginTypeList {
      set pluginType [file tail $typeDirectory]
      set pluginTypeNode [$private(tree) insert end root "$pluginType" -text "$pluginType" -selectable 0]

      #--- je recherche la liste des plugins
      set pkgIndexList [lsort -dictionary [glob -nocomplain -dir $typeDirectory -join * pkgIndex.tcl ]]
      foreach pkgIndexFileName $pkgIndexList {
         if { [::audace::getPluginInfo $pkgIndexFileName pluginInfo ] == 0 } {
            set typeDirectory [getTypeDirectory $pluginInfo(type) ]
            $private(tree) insert end $typeDirectory $pluginInfo(name)  \
               -text "$pluginInfo(name) $pluginInfo(version)" \
               -data "$pkgIndexFileName"
         } else {
            ::console::affiche_erreur "Error reading $pkgIndexFileName :\n$::errorInfo\n\n"
         }
      }
   }
}

#------------------------------------------------------------
#  ::updateaudela::getTypeDirectory
#  retourne le repertoire du plugin en focntion de son type
#  Actuellement les types de plugin sont dans un repertoire dont le nom est
#  identique au type, sauf  le type "focuser" qui est dans le repertoire "equipement"
#------------------------------------------------------------
proc ::updateaudela::getTypeDirectory { pluginType} {
   global audace

   if { $pluginType  == "focuser" } {
      set typeDirectory "equipment"
   } else {
      set typeDirectory $pluginType
   }
   return $typeDirectory
}

#------------------------------------------------------------
#  ::updateaudela::showHelp
#  affiche l'aide de la fenêtre de configuration
#------------------------------------------------------------
proc ::updateaudela::showHelp { } {
   variable private

   ::audace::showHelpScript [ file join $private(pluginDirectory) tool updateaudela ] "updateaudela.htm"
}

#------------------------------------------------------------
#  ::updateaudela::apply
#  recupere la position de l'outil apres appui sur Appliquer
#------------------------------------------------------------
proc ::updateaudela::apply { { visuNo 1 } } {
::updateaudela::recupPosition}

#------------------------------------------------------------
#  ::updateaudela::close
#  recupere la position de l'outil apres appui sur Fermer
#------------------------------------------------------------
proc ::updateaudela::close { { visuNo 1 } } {
::updateaudela::recupPosition}

#------------------------------------------------------------
#  ::updateaudela::recupPosition
#  recupere la position de l'outil
#------------------------------------------------------------
proc ::updateaudela::recupPosition { } {
   variable private

   #--- Je mets la position actuelle de la fenetre dans conf()
   set geom [ winfo geometry [winfo toplevel $private(frm) ] ]
   set deb [ expr 1 + [ string first + $geom ] ]
   set fin [ string length $geom ]
   set ::conf(updateaudela,position) "+[ string range $geom $deb $fin ]"
}

#------------------------------------------------------------
#  ::testaudela::getPluginVersion
#  retourne la version du plugin
#  param :
#    pluginName : nom du plugin
#    pluginTyoe : type du plugin
#------------------------------------------------------------
proc ::updateaudela::getPluginVersion { pluginName pluginType } {
   variable private

   set pkgIndexFileName [file join $private(pluginDirectory) $pluginType $pluginName pkgIndex.tcl]

   set interpTemp [interp create -safe ]
   interp expose $interpTemp source
   interp expose $interpTemp file
   set catchResult [catch {
      $interpTemp eval "set audace(rep_plugin) $::audace(rep_plugin)"
      $interpTemp eval "source \"$pkgIndexFileName\""
      set pluginVersion [$interpTemp eval "package versions $pluginName "]
      set result "$pluginVersion"
   } ]
   if { $catchResult == 1  } {
      ::console::affiche_erreur "$::errorInfo\n"
      ##tk_messageBox -message "$::errorInfo. See console" -icon error
      set result ""
   }
   #--- je supprime l'interpreteur temporaire
   interp delete $interpTemp

   return $result

}

#------------------------------------------------------------
#  ::updateaudela::installPlugin { }
#   extrait le plugin du fichier kit
#------------------------------------------------------------
proc ::updateaudela::installPlugin { { kitFileName "" } } {
   variable private
   global conf

   if { $kitFileName == "" } {
      set selectedRow [$private(kitTable) curselection]
      if { $selectedRow == "" } {
         tk_messageBox -message "Error : no file selected" -icon error
         return
      }
      set kitFileName [$private(kitTable) cellcget $selectedRow,0 -text]
   }
   set kitFileFullName [file join $private(kitDirectory) $kitFileName]

   set vfsNo ""
   set interpTemp [interp create -safe ]
   interp expose $interpTemp source
   interp expose $interpTemp file
   set catchResult [catch {
      #--- j'ouvre le repertoire virtuel du kit
      set vfsName "$kitFileName.vfs"
      set vfsNo [vfs::mk4::Mount $kitFileFullName $vfsName -readonly ]
      set pkgIndexFileName [file join $vfsName pkgIndex.tcl]

      if { [::audace::getPluginInfo $pkgIndexFileName pluginInfo ] == 0 } {
         set typeDirectory [getTypeDirectory $pluginInfo(type) ]
         set pluginDirectory [file join $private(pluginDirectory) $typeDirectory $pluginInfo(name)]

         set message [format $::caption(updateaudela,directoryExists) $pluginDirectory]
         set answer [tk_messageBox -message $message -type okcancel -icon question -title $::caption(updateaudela,title)]
         if { $answer == "ok" } {
            #--- j'extrait le plugin
            set result [::updateaudela::sync [list -verbose 0 -auto 0 -noerror 0 $vfsName $pluginDirectory]]
            #--- je rafraichis l'affichage des plugins
            fillPluginTree
            #--- je sélectionne le plugin dans l'arbre
            $private(tree) opentree $typeDirectory
            $private(tree) selection set $pluginInfo(name)
            #--- j'affiche un message OK
            set message [format $::caption(updateaudela,installPluginOk) $kitFileName $pluginDirectory $result ]
            if { $result != 0 } {
               append message "\n$::caption(updateaudela,restart)"
            }
            tk_messageBox -message $message -type ok -icon info  -title $::caption(updateaudela,title)
         }
      } else {
        ::console::affiche_erreur "$::errorInfo\n"
        tk_messageBox -message "$::errorInfo. See console" -icon error
      }
   } catchMessage ]

   #--- Traitement des erreurs detectees par le catch
   if { $catchResult == "1" } {
     ::console::affiche_erreur "$::errorInfo\n"
     tk_messageBox -message "$catchMessage. See console" -icon error
   }

   #--- je supprime l'interpreteur temporaire
   interp delete $interpTemp

   #--- je ferme le repertoire virtuel si necessaire (dans le cas ou une erreur aurait intrrompu le traitement)
   if { $vfsNo != "" } {
      vfs::mk4::Unmount $vfsNo $vfsName
      ###mk4vfs::umount $vfsName
      set vfsNo ""
   }

}

#------------------------------------------------------------
#  ::updateaudela::makeKit { }
#  copie un plugin dans un fichier kit
#------------------------------------------------------------
proc ::updateaudela::makeKit { { pluginName "" } } {
   variable private

   if { $pluginName == "" } {
      #--- je recupere le nom du plugin selectionne
      set pluginName [$private(tree) selection get]
   }
   #--- je recupere le nom compet du fichier pkgIndex.tcl qui dasn le champ data du noeud
   set pkgIndexFileName [$private(tree) itemcget $pluginName -data ]
   if { [::audace::getPluginInfo $pkgIndexFileName pluginInfo ] == 0 } {
      set pluginDirectory [file dirname $pkgIndexFileName]
      set kitFileName  "$pluginInfo(name)$pluginInfo(version).kit"
      set kitFileFullName  [file join $private(kitDirectory) $kitFileName]
      if { [file exists $kitFileFullName] == 1 } {
         set message [format $::caption(updateaudela,fileExists) $kitFileFullName]
         set answer [tk_messageBox -message $message -type okcancel -icon question -title $::caption(updateaudela,title)]
         if { $answer == "cancel" } {
            return
         }
      }
      #--- je cree le fichier kit
      set vfsName "$pluginName.vfs"
      set vfsNo [vfs::mk4::Mount $kitFileFullName $vfsName ]
      #--- je copie le plugin dans le fichier kit
      ::updateaudela::sync [list -compress 1 -verbose 0 -ignore "CVS" -auto 0 -noerror 0 $pluginDirectory $vfsName]
      #--- je ferme le fichier kit
      vfs::mk4::Unmount $vfsNo $vfsName
      #--- j'actualise la liste de de kits
      fillKitTable
      #--- je sélectionne le nouveau kit dans la table
      set kitList [lindex [ $private(kitTable) getcolumns 0 0 ] 0]
      set kitIndex [lsearch $kitList $kitFileName]
      if { $kitIndex != -1 } {
         $private(kitTable) selection clear 0 end
         $private(kitTable) selection set $kitIndex $kitIndex
      }

      #--- j'affiche un message OK
      set message [format $::caption(updateaudela,makeKitOk) $kitFileName]
      tk_messageBox -message $message -type ok -icon info  -title $::caption(updateaudela,title)
   } else {
     tk_messageBox -message "$::errorInfo. See console" -icon error
   }
}

#------------------------------------------------------------
#  ::updateaudela::showKitContent { }
#   extrait le plugin du fichier kit
#------------------------------------------------------------
proc ::updateaudela::showKitContent { { kitFileName "" } } {
   variable private
   global conf

   if { $kitFileName == "" } {
      set selectedRow [$private(kitTable) curselection]
      if { $selectedRow == "" } {
         tk_messageBox -message "Error : no file selected" -icon error
         return
      }
      set kitFileName [$private(kitTable) cellcget $selectedRow,0 -text]
   }
   set kitFileFullName [file join $private(kitDirectory) $kitFileName]

   set vfsNo ""
   set interpTemp [interp create -safe ]
   interp expose $interpTemp source
   interp expose $interpTemp file
   set catchResult [catch {
      #--- j'ouvre le repertoire virtuel du kit
      set vfsName "$kitFileName.vfs"
      set vfsNo [vfs::mk4::Mount $kitFileFullName $vfsName -readonly ]
      set dirs [list "$vfsName" ]
      while {[llength $dirs] > 0} {
         set dir [lindex $dirs 0]
         set dirs [lrange $dirs 1 end]
         ::console::disp "\n$dir:\n"
         set entries [glob -nocomplain [file join $dir *]]
         foreach path [lsort $entries] {
            if {[file isdir $path]} {
              set len ""
              set tim "dir"
              set suf "/"
              lappend dirs $path
            } else {
              set len [format %10d [file size $path]]
              set tim [clock format [file mtime $path] -format {%Y/%m/%d %H:%M:%S}]
              set suf ""
            }
            ::console::disp "$len  $tim  [file tail $path]$suf\n"
         }
      }

   } catchMessage ]

   #--- Traitement des erreurs detectees par le catch
   if { $catchResult == "1" } {
     ::console::affiche_erreur "$::errorInfo\n"
     tk_messageBox -message "$catchMessage. See console" -icon error
   }

   #--- je supprime l'interpreteur temporaire
   interp delete $interpTemp

   #--- je ferme le repertoire virtuel si necessaire (dans le cas ou une erreur aurait intrrompu le traitement)
   if { $vfsNo != "" } {
      vfs::mk4::Unmount $vfsNo $vfsName
      set vfsNo ""
   }

}

proc ::updateaudela::s { } {
   set interpTemp [interp create -safe ]
   interp expose $interpTemp source
   interp expose $interpTemp file
   ###set v [$interpTemp eval { set ::auto_path "D:/audela-1.4.0/audela/gui/audace/plugin/equipment" }]
   set v [$interpTemp eval { set dira "D:/audela-1.4.0/audela/gui/audace/plugin/equipment" }]
   set v [$interpTemp eval { set fileName "$dira/focuserjmi/pkgIndex.tcl"  }]
   set v [$interpTemp eval { set dir [file dirname $fileName] }]
   set v [$interpTemp eval { source  "$fileName" }]
   set v [info script]
   set v [$interpTemp eval { set pp [package names ] }]
   set v [$interpTemp eval { set pluginName [lindex [package names ] 0] }]
   set v [$interpTemp eval { set pluginVersion [package versions $pluginName] } ]
   set v [$interpTemp eval { set mainFile [package ifneeded $pluginName $pluginVersion] } ]
   set v [$interpTemp eval { eval "$mainFile" }]
   set v [$interpTemp eval { ::$pluginName\::getPluginType } ]
   interp delete $interpTemp
}

#------------------------------------------------------------

################################################################################
# Synchronize two directory trees, VFS-aware
#
# Copyright (c) 1999 Matt Newman, Jean-Claude Wippler and Equi4 Software.

#
# Recursively sync two directory structures
#
proc ::updateaudela::rsync {arr src dest} {
    #tclLog "rsync $src $dest"
    upvar 1 $arr opts

    if {$opts(-auto)} {
        # Auto-mounter
        vfs::auto $src -readonly
        vfs::auto $dest
    }

    if {![file exists $src]} {
        return -code error "source \"$src\" does not exist"
    }
    if {[file isfile $src]} {
        #tclLog "copying file $src to $dest"
        return [rcopy opts $src $dest]
    }
    if {![file isdirectory $dest]} {
        #tclLog "copying non-file $src to $dest"
        return [rcopy opts $src $dest]
    }
    set contents {}
    eval lappend contents [glob -nocomplain -dir $src *]
    eval lappend contents [glob -nocomplain -dir $src .*]

    set count 0                ;# How many changes were needed
    foreach file $contents {
        #tclLog "Examining $file"
        set tail [file tail $file]
        if {$tail == "." || $tail == ".."} {
            continue
        }
        set target [file join $dest $tail]

        set seen($tail) 1

        if {[info exists opts(ignore,$file)] || \
            [info exists opts(ignore,$tail)]} {
            if {$opts(-verbose)} {
                tclLog "skipping $file (ignored)"
            }
            continue
        }
        if {[file isdirectory $file]} {
            incr count [rsync opts $file $target]
            continue
        }
        if {[file exists $target]} {
            #tclLog "target $target exists"
            # Verify
            file stat $file sb
            file stat $target nsb
            #tclLog "$file size=$sb(size)/$nsb(size), mtime=$sb(mtime)/$nsb(mtime)"
            if {$sb(size) == $nsb(size)} {
                # Copying across filesystems can yield a slight variance
                # in mtime's (typ 1 sec)
                if { ($sb(mtime) - $nsb(mtime)) < $opts(-mtime) } {
                    # Good
                    continue
                }
            }
            #tclLog "size=$sb(size)/$nsb(size), mtime=$sb(mtime)/$nsb(mtime)"
        }
        incr count [rcopy opts $file $target]
    }
    #
    # Handle stray files
    #
    if {$opts(-prune) == 0} {
        return $count
    }
    set contents {}
    eval lappend contents [glob -nocomplain -dir $dest *]
    eval lappend contents [glob -nocomplain -dir $dest .*]
    foreach file $contents {
        set tail [file tail $file]
        if {$tail == "." || $tail == ".."} {
            continue
        }
        if {[info exists seen($tail)]} {
            continue
        }
        rdelete opts $file
        incr count
    }
    return $count
}

proc ::updateaudela::_rsync {arr args} {
    upvar 1 $arr opts
    #tclLog "_rsync $args ([array get opts])"

    if {$opts(-show)} {
        # Just show me, don't do it.
        tclLog $args
        return
    }
    if {$opts(-verbose)} {
        tclLog $args
    }
    if {[catch {
        eval $args
    } err]} {
        if {$opts(-noerror)} {
            tclLog "Warning: $err"
        } else {
            return -code error -errorinfo ${::errorInfo} $err
        }
    }
}

# This procedure is better than just 'file copy' on Windows,
# MacOS, where the source files probably have native eol's,
# but the destination should have Tcl/unix native '\n' eols.
# We therefore need to handle text vs non-text files differently.
proc ::updateaudela::file_copy {src dest {textmode 0}} {
    set mtime [file mtime $src]
    if {!$textmode} {
      file copy $src $dest
    } else {
      switch -- [file extension $src] {
          ".tcl" -
          ".txt" -
          ".msg" -
          ".test" -
          ".itk" {
          }
          default {
              if {[file tail $src] != "tclIndex"} {
                  # Other files are copied as binary
                  #return [file copy $src $dest]
                  file copy $src $dest
                  file mtime $dest $mtime
                  return
              }
          }
      }
      # These are all text files; make sure we get
      # the translation right.  Automatic eol
      # translation should work fine.
      set fin [open $src r]
      set fout [open $dest w]
      fcopy $fin $fout
      close $fin
      close $fout
    }
    file mtime $dest $mtime
}

proc ::updateaudela::rcopy {arr path dest} {
    #tclLog "rcopy: $arr $path $dest"
    upvar 1 $arr opts
    # Recursive "file copy"

    set tail [file tail $dest]
    if {[info exists opts(ignore,$path)] || \
        [info exists opts(ignore,$tail)]} {
        if {$opts(-verbose)} {
            tclLog "skipping $path (ignored)"
        }
        return 0
    }
    if {![file isdirectory $path]} {
        if {[file exists $dest]} {
            _rsync opts file delete $dest
        }
        _rsync opts file_copy $path $dest $opts(-text)
        return 1
    }
    set count 0
    if {![file exists $dest]} {
        _rsync opts file mkdir $dest
        set count 1
    }
    set contents {}
    eval lappend contents [glob -nocomplain -dir $path *]
    eval lappend contents [glob -nocomplain -dir $path .*]
    #tclLog "copying entire directory $path, containing $contents"
    foreach file $contents {
        set tail [file tail $file]
        if {$tail == "." || $tail == ".."} {
            continue
        }
        set target [file join $dest $tail]
        incr count [rcopy opts $file $target]
    }
    return $count
}

proc ::updateaudela::rdelete {arr path} {
    upvar 1 $arr opts
    # Recursive "file delete"
    if {![file isdirectory $path]} {
        _rsync opts file delete $path
        return
    }
    set contents {}
    eval lappend contents [glob -nocomplain -dir $path *]
    eval lappend contents [glob -nocomplain -dir $path .*]
    foreach file $contents {
        set tail [file tail $file]
        if {$tail == "." || $tail == ".."} {
            continue
        }
        rdelete opts $file
    }
    _rsync opts file delete $path
}

proc ::updateaudela::rignore {arr args} {
    upvar 1 $arr opts

    foreach file $args {
        set opts(ignore,$file) 1
    }
}

proc ::updateaudela::rpreserve {arr args} {
    upvar 1 $arr opts

    foreach file $args {
        catch {unset opts(ignore,$file)}
    }
}

#------------------------------------------------------------
#  ::updateaudela::sync { }
#  parameters :
#
# return : number of created or udated files
#
#------------------------------------------------------------
proc ::updateaudela::sync {argv} {
   # 28-01-2003: changed -text default to 0, i.e. copy binary mode
   array set opts {
       -prune        0
       -verbose        1
       -show        0
       -ignore        ""
       -mtime        1
       -compress        1
       -auto        1
       -noerror        1
       -text        0
   }
   # 2005-08-30 only ignore the CVS subdir
   #rignore opts CVS RCS core a.out
   rignore opts CVS

   set USAGE "[file tail \$argv0] ?options? src dest

       Where options are:-

       -auto        0|1        Auto-mount starkits (default: $opts(-auto))
       -compress        0|1        Enable MetaKit compression (default: $opts(-compress))
       -mtime        n        Acceptable difference in mtimes (default: $opts(-mtime))
       -prune        0|1        Remove extra files in dest (default: $opts(-prune))
       -show        0|1        Show what would be done, but don't do it (default: $opts(-show))
       -verbose        0|1        Show each file being processed (default: $opts(-verbose))
       -noerror    0|1     Continue processing after errors (default: $opts(-noerror))
       -ignore     glob        Pattern of files to ignore (default: CVS RCS core a.out)
       -preserve        glob        Pattern of files not to ignore (i.e. to clear defaults)
       -text       0|1        Copy .txt/tcl/msg/test/itk files as text (default: $opts(-text))"

   if {[llength $argv] < 2} {
       error "sync : src desc parameters are missing"
       return
   }

   while {[llength $argv] > 0} {
       set arg [lindex $argv 0]

       if {![string match -* $arg]} {
           break
       }
       if {![info exists opts($arg)]} {
           puts stderr "invalid option \"$arg\"\n$USAGE"
           exit 1
       }
       if {$arg == "-ignore"} {
           rignore opts [lindex $argv 1]
       } elseif {$arg == "-preserve"} {
           rpreserve opts [lindex $argv 1]
       } else {
           set opts($arg) [lindex $argv 1]
       }
       set argv [lrange $argv 2 end]
   }

   ##package require vfs::mk4
   ###set vfs::mk4::compress $opts(-compress)

   set src [lindex $argv 0]
   set dest [lindex $argv 1]

   #
   # Perform actual sync
   #
   set n [rsync opts $src $dest]
   return "$n"
}

