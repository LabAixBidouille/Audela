#
# Fichier : visio2.tcl
# Description : Outil de visialisation des images
# Auteur : Michel PUJOL
# Date de mise a jour : 03 juin 2006
#

package provide visio2 1.0

namespace eval ::Visio2 {
   global audace
   global caption

   #--- Chargement des captions
   source [ file join $audace(rep_plugin) tool visio2 visio2.cap ]

   #--- Chargement des autres sources (en attendant de les charger depuis aud.tcl)
   source [ file join $audace(rep_audela) audace movie.tcl ]
   source [ file join $audace(rep_audela) audace ftpclient.tcl ]
   source [ file join $audace(rep_audela) audace image.tcl ]
   source [ file join $audace(rep_audela) audace fullscreen.tcl ]

   array set private {
      This           ""
      ftptbl         ""
      parentFolder   ""
      folder         ""
      fileImage      ""
      fileMovie      ""
      file           ""
      ftpconnection  "0"
      animation      "0"
   }

   proc init { { in "" } } {
      variable private
      global audace
      global caption

      #--- je verifie que le package Tablelist est present
      set result [catch { package require Tablelist } msg]
      if { $result == 1} {
         console::affiche_erreur "[file join $audace(rep_plugin) tool visio2.tcl] - Error : Package Tablelist not found.\n"
         return
      }

      #--- je verifie que le package Img est present
      set result [ catch { package require Img } msg ]
      if { $result == 1} {
         console::affiche_erreur "[file join $audace(rep_plugin) tool visio2.tcl] - Error : Package Img not found.\n"
         return
      }

      #--- je verifie que les variables de cet outil existent dans $conf(...)
      initConf

      #--- Types des objets affiches
      #---   bidouille !!! je met un espace au debut de private(parentFolder) et private(folder) 
      #---   pour que les repertoires apparaissent en premier par ordre alphabetique
      set private(parentFolder)        " $caption(visio2,parent_folder)"
      set private(folder)              " $caption(visio2,folder)"
      set private(fileImage)           "$caption(visio2,image)"
      set private(fileMovie)           "$caption(visio2,movie)"
      set private(file)                "$caption(visio2,file)"
      set private(volume)              "disque"

      #--- j'affiche le panneau
      createPanel $in.visio2
   }

   #------------------------------------------------------------
   # initConf{ }
   #   initialise les parametres dans le tableau conf()
   #------------------------------------------------------------
   proc initConf { } {
      global conf

      #--- indicateurs d'affichage des colonnes
      if {![info exists conf(Visio2,show_column_type)]}     { set conf(Visio2,show_column_type) "1" }
      if {![info exists conf(Visio2,show_column_series)]}   { set conf(Visio2,show_column_series) "0" }
      if {![info exists conf(Visio2,show_column_date)]}     { set conf(Visio2,show_column_date) "0" }
      if {![info exists conf(Visio2,show_column_size)]}     { set conf(Visio2,show_column_size) "0" }

      #--- largeur des colonnes en nombre de caracteres (valeur positive) ou en nombre de pixel (valeur negative)
      if {![info exists conf(Visio2,width_column_name)]}    { set conf(Visio2,width_column_name)   "-90" }
      if {![info exists conf(Visio2,width_column_type)]}    { set conf(Visio2,width_column_type)   "-70" }
      if {![info exists conf(Visio2,width_column_series)]}  { set conf(Visio2,width_column_series) "-60" }
      if {![info exists conf(Visio2,width_column_date)]}    { set conf(Visio2,width_column_date)   "-104" }
      if {![info exists conf(Visio2,width_column_size)]}    { set conf(Visio2,width_column_size)   "-70" }

      #--- extensions des fichiers par defaut
      if {![info exists conf(Visio2,enableExtension)]} {
         #--- par defaut je traite les fichiers fit et gif
         array set enableExtension {
            fit      "1"
            gif      "1"
            bmp      "1"
            jpg      "1"
            png      "1"
            ps       "1"
            tif      "1"
            xbm      "1"
            raw      "1"
            avi      "1"
         }    
         set conf(Visio2,enableExtension)   [array get enableExtension]
      }
      if {![info exists conf(Visio2,show_all_files)]} { set conf(Visio2,show_all_files)   "0" }

   }

   #==============================================================
   # Fonctions generiques de gestion de panneau
   #   createPanel
   #   startTool
   #   stopTool
   #==============================================================

   proc createPanel { this } {
      variable private
      global caption
      global panneau
      global audace

      # j'initialise les variable private
      set private(This) $this
      
      #---

      # j'affiche le panneau
      set panneau(menu_name,Visio2) $caption(visio2,title)
      Visio2BuildIF $private(This)
   }

   proc startTool { visuNo } {
      variable private
      global audace

      pack $private(This) -side left -fill y

      #--- je refraichis la liste des fichiers 
      localTable::init $private(This) $audace(rep_images)
   }

   proc stopTool { visuNo } {
      variable private
      global conf
      global audace

      #--- j'arrete le diaporama
      localTable::stopSlideShow
      #--- j'arrete l'animation
      localTable::stopAnimation
      #--- je supprime le canvas des films
      ::Movie::close $audace(hCanvas)
      #--- copie la largeur des colonnes dans conf()
      localTable::saveColumnWidth
      #--- je ferme la connexion ftp
      ftpclient::close

      pack forget $private(This)
   }

   #------------------------------------------------------------------------------
   # configure
   #   affiche la fenetre de configuration (cf namespace ::Visio2::config)
   #------------------------------------------------------------------------------
   proc configure { } {
      variable private
      global audace

      #--- j'affiche la fenetre de configuration
      ::confGenerique::run "$audace(base).confvisio2" "::Visio2::config"

      #--- je refraichis les tables pour prendre en compte la nouvelle config
      localTable::refresh
      ftpTable::refresh
   }

   #------------------------------------------------------------------------------
   # getFileList
   #   retourne la liste des fichiers et des sous-repertoires presents
   #   dans le repertoire donne en parametre
   #   retourne une liste de 4 attributs pour chaque fichier [isdir shortname date size]
   #------------------------------------------------------------------------------
    proc getFileList { directory } {
      variable private

      set files ""
      foreach fullname [glob -nocomplain -dir $directory *] {
         set isdir [file isdir $fullname]
         set shortname [file tail $fullname]
         set date [file mtime $fullname]
         if { $isdir == 1 } {
            set size "" 
         } else {
            set size [file size $fullname]
         }
         lappend files [list "$isdir" "$shortname" "$date" "$size" ]
      }
      return $files
   }

   #------------------------------------------------------------------------------
   # fillTable
   #   affiche les noms des fichiers dans la table
   #------------------------------------------------------------------------------
    proc fillTable { tbl files } {
      variable private
      global conf

      #--- je recupere les extensions autorisees dans un tableau
      array set enableExtension $conf(Visio2,enableExtension)

      #--- raz de la liste
      $tbl delete 0 end
      $tbl resetsortinfo

      #--- je cree une ligne correspondant au repertoire parent
      lappend item " .." $private(parentFolder) "" ""
      #--- j'insere la ligne dans la table
      $tbl insert end $item
      #--- j'ajoute l'icone
      $tbl cellconfigure end,0 -image $private(folderIcon)

      #--- j'ajoute les lignes correspondant aux fichiers et sous-repertoires
      foreach i [lsort -dictionary $files] {
         set isdir   "[lindex $i 0 ]"
         set name    "[lindex $i 1 ]"
         set date    "[lindex $i 2 ]"
         set size    "[lindex $i 3 ]"

         if { $isdir == 1 } {
            # cas d'un repertoire : affiche le nom du repertoire et l'icone private(folderIcon)
            set item {}
            #--- colonne name
            #--- bidouille !!! : j'ajoute un espace au debut du nom du repertoire 
            #--- pour que le tri automatique mette les repertoires en premier par ordre alphabetique
            set name " $name"
            #--- colonne type
            set type "$private(folder)"
            #--- colonne date
            if { "$date" != "" && [string is integer $date ] } {
               set date  "[clock format $date -format "%Y/%m/%d %H:%M:%S" ]"
            }
            #--- colonne serie (toujours vide our un repertoire)
            set serie ""
            #--- colonne size (toujours vide our un repertoire)
            set size ""
            
            lappend item  "$name" "$type" "$serie" "$date" "$size"
            #--- j'insere la ligne dans la table
            $tbl insert end $item
            #--- j'ajoute l'icone
            $tbl cellconfigure end,0 -image $private(folderIcon)

         } elseif {  [regexp ($conf(extension,defaut)|$conf(extension,defaut).gz)$  [string tolower $name]] && $enableExtension(fit)==1 
                  || [regexp (.fit)$                [string tolower $name]] && $enableExtension(fit)==1
                  || [regexp (.fit.gz)$             [string tolower $name]] && $enableExtension(fit)==1
                  || [regexp (.fits)$               [string tolower $name]] && $enableExtension(fit)==1
                  || [regexp (.fits.gz)$            [string tolower $name]] && $enableExtension(fit)==1
                  || [regexp (.fts)$                [string tolower $name]] && $enableExtension(fit)==1
                  || [regexp (.fts.gz)$             [string tolower $name]] && $enableExtension(fit)==1
                  || [regexp (.bmp)$                [string tolower $name]] && $enableExtension(bmp)==1
                  || [regexp (.gif)$                [string tolower $name]] && $enableExtension(gif)==1
                  || [regexp (.jpg|.jpeg)$          [string tolower $name]] && $enableExtension(jpg)==1
                  || [regexp (.tif|.tiff)$          [string tolower $name]] && $enableExtension(tif)==1
                  || [regexp (.png)$                [string tolower $name]] && $enableExtension(png)==1
                  || [regexp (.ps|.eps)$            [string tolower $name]] && $enableExtension(ps)==1
                  || [regexp (.xbm|.xmp)$           [string tolower $name]] && $enableExtension(xbm)==1
                  || [regexp (.crw|.nef|.cr2|.dng)$ [string tolower $name]] && $enableExtension(raw)==1
                  } {
            #--- cas d'une image : ajoute une ligne dans la table avec le nom, type, serie et date du fichier
            #--- colonne name
            set name $name
            #--- colonne type
            set type "$private(fileImage)"
            #--- colonne date
            if { "$date" != "" && [string is integer $date ] } {
               set date  "[clock format $date -format "%Y/%m/%d %H:%M:%S" ]" 
            }

            #--- colonne serie
            #------ 1)je prepare les variables
            set serie ""
            set serialName ""
            set serialInd ""
            set rootname [file rootname $name]
            #------ 2)je supprime les extensions avec un boucle car il peut y avoir plusieurs extensions
            while { [string first "." "$rootname" ] != -1 } {
               set rootname [file rootname $rootname]
            }       
            #------ 3)je cherche un numero a la fin de rootname => serialind
            set result [regexp {([^0-9]*)([0-9]+$)} $rootname match serialName serialInd ]
            if { $result == 1  } {
               if { $serialInd != "" } {
                  #--- si serialInd n'est pas vide, ce fichier fait partie d'un serie
                  set serialName [string range $rootname 0 [expr [string last $serialInd $rootname ] -1 ]]
                  #--- je supprime les zeros a gauche pour que serialInd ne soit pas interprete comme une valeur en octal
                  if { $serialInd != "0" } {
                     set serialInd [string trimleft $serialInd "0" ]
                  }
                  if { [string is integer $serialInd] && "$serialInd" != ""} {
                     set serie [format "%s % 5d" $serialName $serialInd]
                  } else {
                     console::affiche_erreur "fillTable error serialInd=$serialInd name=$name \n"
                  }
               }
            } else {
               #--- pas de chiffre trouve a la fin du nom du fichier
               set serie " "
            }
            #--- colonne size
            if { [string is integer $size ] } { 
               set size [format "%12d" $size]
            } 

            #--- je cree la ligne
            set item {}
            lappend item "$name" "$type" "$serie" "$date" "$size"
            #--- j'ajoute une ligne dans la table
            $tbl insert end $item

         } elseif { [regexp (.avi|.mpeg)$ [string tolower $name]] && $enableExtension(avi)==1 } {
            #--- cas d'un film : ajoute une ligne avec le nom, type, serie et date du fichier
            set item {}
            #--- colonne name
            set name $name
            #--- colonne type
            set type "$private(fileMovie)"
            #--- colonne date
            if { [string is integer $date ] } {
               set date  "[clock format $date -format "%Y/%m/%d %H:%M:%S" ]"
            }
            #--- colonne serie
            set serie ""
            #--- colonne size
            if { [string is integer $size ] } {
               set size [format "%12d" $size]
            } 
            #--- je cree la ligne
            lappend item "$name" "$type" "$serie" "$date" "$size"
            #--- j'ajoute une ligne dans la table
            $tbl insert end $item            
         } elseif  { $conf(Visio2,show_all_files)==1 } {
            #--- cas d'un fichier quelconque
            set item {}
            #--- colonne name
            set name $name
            #--- colonne type
            set type "$private(file)"
            #--- colonne date
            set date  "[clock format $date -format "%Y/%m/%d %H:%M:%S" ]"
            #--- colonne serie
            set serie ""
            #--- colonne size
            if { [string is integer $size ] } {
               set size [format "%12d" $size]
            } 
            #--- je cree la ligne
            lappend item "$name" "$type" "$serie" "$date" "$size"
            #--- j'ajoute une ligne dans la table
            $tbl insert end $item
         }
      }

      #--- je trie par ordre alphabetique de la premiere colonne
      tablelist::sortByColumn $tbl 0
   }

   #------------------------------------------------------------------------------
   # fillVolumeTable
   #   affiche la liste des disques dans la table
   #------------------------------------------------------------------------------
    proc fillVolumeTable { tbl } {
      variable private
      global conf

      #--- raz de la liste
      $tbl delete 0 end
      $tbl resetsortinfo

      #--- j'ajoute les lignes correspondant aux fichiers et sous-repertoires
      foreach i [file volumes] {

         #--- colonne name
         set name [file nativename "$i"]
         #--- colonne type
         set type "$private(volume)"
         #--- colonne date
         set date ""
         #--- colonne serie (toujours vide pour un disque)
         set serie ""
         #--- colonne size (toujours vide pour un disque)
         set size ""

         set item {}
         lappend item  "$name" "$type" "$serie" "$date" "$size"
         #--- j'insere la ligne dans la table
         $tbl insert end $item
         #--- j'ajoute l'icone
         $tbl cellconfigure end,0 -image $private(folderIcon)

      }
      
      #--- je trie par ordre alphabetique de la premiere colonne 
      tablelist::sortByColumn $tbl 0
   }

   #------------------------------------------------------------------------------
   # cmdSortColumn
   #   trie les lignes par ordre alphabetique de la colonne
   #   (est appele quand on clique sur le titre de la colonne)
   #------------------------------------------------------------------------------
   proc cmdSortColumn { tbl col } {
      tablelist::sortByColumn $tbl $col
   }

   #------------------------------------------------------------------------------
   # showColumn
   #   affiche ou masque une colonne
   #   et adapte la largeur de la table en fonction des colonnes restant affichees
   #------------------------------------------------------------------------------
   proc showColumn { tbl columnIndex show } {
      variable private

      if { $show == 1 } {
         $tbl columnconfigure $columnIndex -hide 0
      } else {
         $tbl columnconfigure $columnIndex -hide 1
      }
      
      #--- je recalcule la largeur de la liste
      set width 0
      for {set i 0} {$i < [$tbl columncount] } {incr i } {
         if { [$tbl columncget $i -hide] == 0 } {
            incr width [$tbl columncget $i -width]
         }
         #console::disp "width $i=[$tbl columncget $i -width] \n"
      }
      $tbl configure -width $width      

      #--- je fais pareil pour la table ftpTable si elle est affichee
      if { [info exists ::Visio2::ftpTable::private(tbl)] } {
      if { "$::Visio2::ftpTable::private(tbl)" != "" } {
         set tbl $::Visio2::ftpTable::private(tbl)
         if { $show == 1 } {
            $tbl columnconfigure $columnIndex -hide 0
         } else {
            $tbl columnconfigure $columnIndex -hide 1
         }

         #--- je recalcule la largeur de la liste
         set width 0
         for {set i 0} {$i < [$tbl columncount] } {incr i } {
            if { [$tbl columncget $i -hide] == 0 } {
               incr width [$tbl columncget $i -width]
            }
         }
         $tbl configure -width $width
      }
      }
   }

   #------------------------------------------------------------------------------
   # cmdFtpConnection
   #   etablit une connexion ftp
   #   et affiche le contenu du repertoire distant dans la table ftpTable
   #------------------------------------------------------------------------------
   proc cmdFtpConnection { } {
      variable private
      global caption

      if { $private(ftpconnection) == 1 } {   
         set result [ftpTable::init "$private(This)" ]
         if {  $result == 0 } {
             #--- si la connexion est annulee , je decoche le checkbutton
             set private(ftpconnection) 0
         }
      } else { 
         #--- je ferme la connexion FTP et supprime la liste FTP
         set result [ftpTable::close]
         if { $result == "0" } {
            #--- si la fermeture est annulee, je recoche le checkbutton
            set private(ftpconnection) 1
         }
      }
   }

   #--- icone directory
   set private(folderIcon) [image create photo folderopen16 -data {
       R0lGODlhEAAQAIYAAPwCBAQCBExKTBQWFOzi1Ozq7ERCRCwqLPz+/PT29Ozu
       7OTm5FRSVHRydIR+fISCfMTCvAQ6XARqnJSKfIx6XPz6/MzKxJTa9Mzq9JzO
       5PTy7OzizJSOhIyCdOTi5Dy65FTC7HS2zMzm7OTSvNTCnIRyVNza3Dw+PASq
       5BSGrFyqzMyyjMzOzAR+zBRejBxqnBx+rHRmTPTy9IyqvDRylFxaXNze3DRu
       jAQ2VLSyrDQ2NNTW1NTS1AQ6VJyenGxqbMTGxLy6vGRiZKyurKyqrKSmpDw6
       PDw6NAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA
       AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA
       AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA
       AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAACH5BAEAAAAA
       LAAAAAAQABAAAAfCgACCAAECg4eIAAMEBQYCB4mHAQgJCgsLDAEGDQGIkw4P
       BQkJBYwQnRESEREIoRMUE6IVChYGERcYGaoRGhsbHBQdHgu2HyAhGSK6qxsj
       JCUmJwARKCkpKsjKqislLNIRLS4vLykw2MkRMRAGhDIJMzTiLzDXETUQ0gAG
       CgU2HjM35N3AkYMdAB0EbCjcwcPCDBguevjIR0jHDwgWLACBECRIBB8GJekQ
       MiRIjhxEIlBMFOBADR9FIhiJ5OnAEQB+AgEAIf5oQ3JlYXRlZCBieSBCTVBU
       b0dJRiBQcm8gdmVyc2lvbiAyLjUNCqkgRGV2ZWxDb3IgMTk5NywxOTk4LiBB
       bGwgcmlnaHRzIHJlc2VydmVkLg0KaHR0cDovL3d3dy5kZXZlbGNvci5jb20A
       Ow==
    }]
   
}

#------------------------------------------------------------------------------
# Visio2BuildIF
#   affiche l'outil Visio2
#------------------------------------------------------------------------------
proc Visio2BuildIF { This } {
   global audace
   global caption
   global conf

   frame $This -borderwidth 2 -relief groove

      #--- Frame du titre
      frame $This.titre -borderwidth 2 -relief groove

      #--- Label du titre
      Button $This.titre.but -borderwidth 1 -text $caption(visio2,title) \
         -command { 
            ::audace::showHelpPlugin "tool" "visio2" "visio2.htm"
         }
      DynamicHelp::add $This.titre.but -text $caption(visio2,help,titre)
      pack $This.titre.but -in $This.titre -anchor center -expand 1 -fill x -side top -ipadx 5

      pack $This.titre -in $This -fill x

      #--- Frame de la liste locale
      frame $This.locallist -borderwidth 1 -relief groove
      ::Visio2::localTable::createTbl $This.locallist
      pack $This.locallist -fill both -expand 1 -anchor n -side top

      #--- Frame SlideShow
      frame $This.slideShow -borderwidth 1 -relief groove

      checkbutton $This.slideShow.check -pady 0 -text "$caption(visio2,slideshow)" \
               -variable ::Visio2::localTable::private(slideShowState) \
               -command {
                   if { $::Visio2::localTable::private(slideShowState) == 1} {
                       ::Visio2::localTable::startSlideShow
                   } else {
                       ::Visio2::localTable::stopSlideShow
                   }
                }
      pack $This.slideShow.check -in $This.slideShow -anchor center -expand 0 -fill none -side left

      set list_combobox [ list "0.5" "1" "2" "3" "5" "10" ]
      ComboBox $This.slideShow.delay \
         -width 3          \
         -height [llength $list_combobox] \
         -relief sunken    \
         -borderwidth 1    \
         -editable 1       \
         -takefocus 1      \
         -textvariable ::Visio2::localTable::private(slideShowDelay) \
         -values $list_combobox
      $This.slideShow.delay setvalue @1
      pack $This.slideShow.delay -in $This.slideShow -anchor center -expand 0 -fill none -side left

      label $This.slideShow.labdelay -borderwidth 1 -text "s."
      pack $This.slideShow.labdelay -in $This.slideShow -anchor center -expand 0 -fill none -side left
      pack $This.slideShow -fill x -anchor n

      #--- frame ftp
      frame $This.ftp -borderwidth 1 -relief groove

      checkbutton $This.ftp.check -pady 0 -text $caption(visio2,ftp_connection_title) \
               -variable ::Visio2::private(ftpconnection) \
               -command "::Visio2::cmdFtpConnection"
      pack $This.ftp.check -in $This.ftp -anchor center -expand 0 -fill none -side left
      pack $This.ftp -in $This -fill x -anchor n 

      #--- Frame de la liste ftp
      frame $This.ftplist -borderwidth 1 -relief groove
      ::Visio2::ftpTable::createTbl $This.ftplist 
      
      #--- la table sera "packe" plus tard quand on demandera a l'afficher
      #pack $This.ftplist -after $This.ftp -fill both -expand 1 -anchor n -side bottom
      ::confColor::applyColor $This

}

################################################################
# namespace ::Visio2::config
#    fenetre de configuration de l'outil Visio2
################################################################

namespace eval ::Visio2::config {

    array set fileExtension [array get ::Visio2::fileExtension]

   #==============================================================
   # Fonctions de configuration generiques appelees par ::confGenerique::run
   #
   # getLabel        retourne le titre de la fenetre de config
   # confToWidget    copie les parametres du tableau conf() dans les variables des widgets
   # widgetToConf    copie les variable des widgets dans le tableau conf()
   # fillConfigPage  affiche la fenetre de config
   #==============================================================

   #------------------------------------------------------------
   # ::Visio2::config::getLabel
   #   retourne le nom de la fenetre de configuration
   #------------------------------------------------------------
   proc getLabel { } {
      global caption

      return "$caption(visio2,title)"
   }

   #------------------------------------------------------------
   # ::Visio2::config::showHelp
   #   affiche l'aide de cet outil
   #------------------------------------------------------------
   proc showHelp { } {
      ::audace::showHelpPlugin "tool" "visio2" "visio2.htm" "config"
   }
   
   #------------------------------------------------------------
   # ::Visio2::config::confToWidget { }
   #   copie les parametres du tableau conf() dans les variables des widgets
   #------------------------------------------------------------
   proc confToWidget { } {
      variable private  
      variable widget  
      variable widgetEnableExtension
      global conf

      #--- je met les extensions dans un array (de-serialisation)
      array set widgetEnableExtension $conf(Visio2,enableExtension)

      #j'initialise les variable utilisees par le widgets      
      set widget(show_all_files)         $conf(Visio2,show_all_files)
   }

   #------------------------------------------------------------
   # ::Visio2::config::widgetToConf { }
   #   copie les variable des widgets dans le tableau conf()
   #------------------------------------------------------------
   proc widgetToConf { } {
      variable private
      variable widget 
      variable widgetEnableExtension
      global conf

      set conf(Visio2,enableExtension) [array get widgetEnableExtension]
      set conf(Visio2,show_all_files)    $widget(show_all_files)
   }

   #------------------------------------------------------------
   # ::Visio2::config::fillConfigPage { }
   #   fenetre de configuration du panneau
   #   return rien
   #------------------------------------------------------------
   proc fillConfigPage { frm visuNo } {
      variable widget 
      variable widgetEnableExtension
      global caption
      global audace
      global conf

      #je memorise la reference de la frame 
      set widget(frm) $frm

      #--- j'initialise les varaibles des widgets
      confToWidget

      frame $frm.extension -borderwidth 1 -relief ridge
      pack $frm.extension -side top -fill both -expand 1 
      
      label $frm.extension.knownfiles -text "$caption(visio2,known_files)"  \
         -justify left
      pack $frm.extension.knownfiles -anchor w -side top -padx 5 -pady 0

      #--- fichiers extension par defaut
      if { ( $conf(extension,defaut) == ".gif" ) || ( $conf(extension,defaut) == ".bmp" ) || \
         ( $conf(extension,defaut) == ".jpg" ) || ( $conf(extension,defaut) == ".jpeg" ) || \
         ( $conf(extension,defaut) == ".png" ) || ( $conf(extension,defaut) == ".ps" ) || \
         ( $conf(extension,defaut) == ".eps" ) || ( $conf(extension,defaut) == ".tif" ) || \
         ( $conf(extension,defaut) == ".tiff" ) || ( $conf(extension,defaut) == ".xbm" ) || \
         ( $conf(extension,defaut) == ".xpm" ) || ( $conf(extension,defaut) == ".avi" ) || \
         ( $conf(extension,defaut) == ".crw" ) || ( $conf(extension,defaut) == ".nef" ) || \
         ( $conf(extension,defaut) == ".cr2" ) || ( $conf(extension,defaut) == ".dng" ) || \
         ( $conf(extension,defaut) == ".mpeg" ) } {
         checkbutton $frm.extension.extdefaut -text "$conf(extension,defaut)" \
             -highlightthickness 0 -variable ::Visio2::config::widgetEnableExtension(defautext)
         pack $frm.extension.extdefaut -anchor w -side top -padx 5 -pady 0
      } else {
         checkbutton $frm.extension.extdefaut -text "$conf(extension,defaut) $conf(extension,defaut).gz" \
             -highlightthickness 0 -variable ::Visio2::config::widgetEnableExtension(defautext)
         pack $frm.extension.extdefaut -anchor w -side top -padx 5 -pady 0
      }

      #--- fichiers fit
      if { $conf(extension,defaut) == ".fit" } {
         checkbutton $frm.extension.extfit -text ".fts .fts.gz .fits .fits.gz" \
             -highlightthickness 0 -variable ::Visio2::config::widgetEnableExtension(fit)
         pack $frm.extension.extfit -anchor w -side top -padx 5 -pady 0
      } elseif { $conf(extension,defaut) == ".fts" } {
         checkbutton $frm.extension.extfit -text ".fit .fit.gz .fits .fits.gz" \
             -highlightthickness 0 -variable ::Visio2::config::widgetEnableExtension(fit)
         pack $frm.extension.extfit -anchor w -side top -padx 5 -pady 0
      } elseif { $conf(extension,defaut) == ".fits" } {
         checkbutton $frm.extension.extfit -text ".fit .fit.gz .fts .fts.gz" \
             -highlightthickness 0 -variable ::Visio2::config::widgetEnableExtension(fit)
         pack $frm.extension.extfit -anchor w -side top -padx 5 -pady 0
      } else {
         checkbutton $frm.extension.extfit -text ".fit .fit.gz .fts .fts.gz .fits .fits.gz" \
             -highlightthickness 0 -variable ::Visio2::config::widgetEnableExtension(fit)
         pack $frm.extension.extfit -anchor w -side top -padx 5 -pady 0
      }

      #--- fichiers gif
      if { $conf(extension,defaut) != ".gif" } {
         checkbutton $frm.extension.gif -text ".gif" \
             -highlightthickness 0 -variable ::Visio2::config::widgetEnableExtension(gif)
         pack $frm.extension.gif -anchor w -side top -padx 5 -pady 0
      }

      #--- fichiers bmp
      if { $conf(extension,defaut) != ".bmp" } {
         checkbutton $frm.extension.bmp -text ".bmp" \
             -highlightthickness 0 -variable ::Visio2::config::widgetEnableExtension(bmp)
         pack $frm.extension.bmp -anchor w -side top -padx 5 -pady 0
      }

      #--- fichiers jpg
      if { ( $conf(extension,defaut) != ".jpg" ) && ( $conf(extension,defaut) != ".jpeg" ) } {
         checkbutton $frm.extension.jpg -text ".jpg .jpeg" \
             -highlightthickness 0 -variable ::Visio2::config::widgetEnableExtension(jpg)
         pack $frm.extension.jpg -anchor w -side top -padx 5 -pady 0
      } elseif { $conf(extension,defaut) == ".jpg" } {
         checkbutton $frm.extension.jpg -text ".jpeg" \
             -highlightthickness 0 -variable ::Visio2::config::widgetEnableExtension(jpg)
         pack $frm.extension.jpg -anchor w -side top -padx 5 -pady 0
      } elseif { $conf(extension,defaut) == ".jpeg" } {
         checkbutton $frm.extension.jpg -text ".jpg" \
             -highlightthickness 0 -variable ::Visio2::config::widgetEnableExtension(jpg)
         pack $frm.extension.jpg -anchor w -side top -padx 5 -pady 0
      }

      #--- fichiers png
      if { $conf(extension,defaut) != ".png" } {
         checkbutton $frm.extension.png -text ".png" \
             -highlightthickness 0 -variable ::Visio2::config::widgetEnableExtension(png)
         pack $frm.extension.png -anchor w -side top -padx 5 -pady 0
      }

      #--- fichiers ps
      if { ( $conf(extension,defaut) != ".ps" ) && ( $conf(extension,defaut) != ".eps" ) } {
         checkbutton $frm.extension.ps -text ".ps .eps" \
             -highlightthickness 0 -variable ::Visio2::config::widgetEnableExtension(ps)
         pack $frm.extension.ps -anchor w -side top -padx 5 -pady 0
      } elseif { $conf(extension,defaut) == ".ps" } {
         checkbutton $frm.extension.ps -text ".eps" \
             -highlightthickness 0 -variable ::Visio2::config::widgetEnableExtension(ps)
         pack $frm.extension.ps -anchor w -side top -padx 5 -pady 0
      } elseif { $conf(extension,defaut) == ".eps" } {
         checkbutton $frm.extension.ps -text ".ps" \
             -highlightthickness 0 -variable ::Visio2::config::widgetEnableExtension(ps)
         pack $frm.extension.ps -anchor w -side top -padx 5 -pady 0
      }

      #--- fichiers tif
      if { ( $conf(extension,defaut) != ".tif" ) && ( $conf(extension,defaut) != ".tiff" ) } {
         checkbutton $frm.extension.tif -text ".tif .tiff" \
             -highlightthickness 0 -variable ::Visio2::config::widgetEnableExtension(tif)
         pack $frm.extension.tif -anchor w -side top -padx 5 -pady 0
      } elseif { $conf(extension,defaut) == ".tif" } {
         checkbutton $frm.extension.tif -text ".tiff" \
             -highlightthickness 0 -variable ::Visio2::config::widgetEnableExtension(tif)
         pack $frm.extension.tif -anchor w -side top -padx 5 -pady 0
      } elseif { $conf(extension,defaut) == ".tiff" } {
         checkbutton $frm.extension.tif -text ".tif" \
             -highlightthickness 0 -variable ::Visio2::config::widgetEnableExtension(tif)
         pack $frm.extension.tif -anchor w -side top -padx 5 -pady 0
      }

      #--- fichiers xbm
      if { ( $conf(extension,defaut) != ".xbm" ) && ( $conf(extension,defaut) != ".xpm" ) } {
         checkbutton $frm.extension.xbm -text ".xbm .xpm" \
             -highlightthickness 0 -variable ::Visio2::config::widgetEnableExtension(xbm)
         pack $frm.extension.xbm -anchor w -side top -padx 5 -pady 0
      } elseif { $conf(extension,defaut) == ".xbm" } {
         checkbutton $frm.extension.xbm -text ".xpm" \
             -highlightthickness 0 -variable ::Visio2::config::widgetEnableExtension(xbm)
         pack $frm.extension.xbm -anchor w -side top -padx 5 -pady 0
      } elseif { $conf(extension,defaut) == ".xpm" } {
         checkbutton $frm.extension.xbm -text ".xbm" \
             -highlightthickness 0 -variable ::Visio2::config::widgetEnableExtension(xbm)
         pack $frm.extension.xbm -anchor w -side top -padx 5 -pady 0
      }

      #--- fichiers raw
      if { ( $conf(extension,defaut) != ".crw" ) && ( $conf(extension,defaut) != ".nef" ) && \
         ( $conf(extension,defaut) != ".cr2" ) && ( $conf(extension,defaut) != ".dng" ) } {
         checkbutton $frm.extension.raw -text ".crw .nef" \
             -highlightthickness 0 -variable ::Visio2::config::widgetEnableExtension(raw)
         pack $frm.extension.raw -anchor w -side top -padx 5 -pady 0
      } elseif { $conf(extension,defaut) == ".crw" } {
         checkbutton $frm.extension.raw -text ".crw" \
             -highlightthickness 0 -variable ::Visio2::config::widgetEnableExtension(raw)
         pack $frm.extension.xbm -anchor w -side top -padx 5 -pady 0
      } elseif { $conf(extension,defaut) == ".nef" } {
         checkbutton $frm.extension.raw -text ".nef" \
             -highlightthickness 0 -variable ::Visio2::config::widgetEnableExtension(raw)
         pack $frm.extension.xbm -anchor w -side top -padx 5 -pady 0
      } elseif { $conf(extension,defaut) == ".cr2" } {
         checkbutton $frm.extension.raw -text ".cr2" \
             -highlightthickness 0 -variable ::Visio2::config::widgetEnableExtension(raw)
         pack $frm.extension.xbm -anchor w -side top -padx 5 -pady 0
      } elseif { $conf(extension,defaut) == ".dng" } {
         checkbutton $frm.extension.raw -text ".dng" \
             -highlightthickness 0 -variable ::Visio2::config::widgetEnableExtension(raw)
         pack $frm.extension.xbm -anchor w -side top -padx 5 -pady 0
      }

      #--- fichiers avi
      if { ( $conf(extension,defaut) != ".avi" ) && ( $conf(extension,defaut) != ".mpeg" ) } {
         checkbutton $frm.extension.avi -text ".avi .mpeg" \
             -highlightthickness 0 -variable ::Visio2::config::widgetEnableExtension(avi)
         pack $frm.extension.avi -anchor w -side top -padx 5 -pady 0
      } elseif { $conf(extension,defaut) == ".avi" } {
         checkbutton $frm.extension.avi -text ".mpeg" \
             -highlightthickness 0 -variable ::Visio2::config::widgetEnableExtension(avi)
         pack $frm.extension.avi -anchor w -side top -padx 5 -pady 0
      } elseif { $conf(extension,defaut) == ".mpeg" } {
         checkbutton $frm.extension.avi -text ".avi" \
             -highlightthickness 0 -variable ::Visio2::config::widgetEnableExtension(avi)
         pack $frm.extension.avi -anchor w -side top -padx 5 -pady 0
      }

      if { [package versions Img ]== "" } { 
         #--- je decoche les checkbox
         set ::Visio2::config::widgetEnableExtension(bmp) 0
         set ::Visio2::config::widgetEnableExtension(jpg) 0
         set ::Visio2::config::widgetEnableExtension(png) 0
         set ::Visio2::config::widgetEnableExtension(ps)  0
         set ::Visio2::config::widgetEnableExtension(tif) 0
         set ::Visio2::config::widgetEnableExtension(xbm) 0

         #--- je desactive les checkbox pour qu'on ne puisse pas les cocher
         $frm.extension.bmp configure -state disabled
         $frm.extension.jpg configure -state disabled 
         $frm.extension.png configure -state disabled 
         $frm.extension.ps  configure -state disabled 
         $frm.extension.tif configure -state disabled 
         $frm.extension.xbm configure -state disabled
      }

      #--- pas de film si on est sous Linux ou si le package tmci n'est pas present
      if { $::tcl_platform(os) == "Linux" &&  [package versions tmci ]== "" } { 
         #--- je decoche la checkbox
         set ::Visio2::config::widgetEnableExtension(avi) 0
         #--- je desactive la checkbox pour qu'on ne puisse pas la cocher
         $frm.extension.avi configure -state disabled
      }

      #--- remarque 
      label $frm.extension.remark -text "$caption(visio2,remark)"  \
         -justify left
      pack $frm.extension.remark -anchor w -side top -padx 5 -pady 0

      #--- frame des options
      frame $frm.display -borderwidth 1  -relief ridge
      pack $frm.display -side top -fill both -expand 1 
      
      #--- afficher tous les fichiers
      checkbutton $frm.display.show_all_afiles -text $caption(visio2,show_all_files) \
          -highlightthickness 0 -variable ::Visio2::config::widget(show_all_files)
      pack $frm.display.show_all_afiles -anchor w -side top -padx 5 -pady 0
   }
}

################################################################
# namespace localTable
#    gere la table des fichiers du disque local
################################################################
namespace eval ::Visio2::localTable {
   
   array set private { 
      localtbl             ""
      directory            ""
      previousType         ""
      previousFileNameType ""
      currentItemIndex     0
      slideShowState       "0"
      slideShowAfterId     ""
      slideShowDelay       "1"
      animation            0

   }

   #------------------------------------------------------------------------------
   # localTable::init
   #   affiche les fichiers dans la table
   #------------------------------------------------------------------------------
   proc init { mainframe directory } {
      variable private

      set private(parentFolder)        $::Visio2::private(parentFolder)
      set private(folder)              $::Visio2::private(folder)
      set private(fileImage)           $::Visio2::private(fileImage)
      set private(fileMovie)           $::Visio2::private(fileMovie)
      set private(file)                $::Visio2::private(file)
      set private(volume)              $::Visio2::private(volume)

      set private(directory) "$directory"
      fillTable
   }

   #------------------------------------------------------------------------------
   # localTable::getDirectory
   #   retourne le reperoire courant
   #------------------------------------------------------------------------------
   proc getDirectory { } {
      global caption
      global audace
      variable private

      return "$private(directory)"
   }

   #------------------------------------------------------------------------------
   # localTable::fillTable
   #   affiche les fichiers et sous repertoires dans la table
   #   et affiche le nom du repertoire courant dans le titre de la fenetre principale
   #------------------------------------------------------------------------------
   proc fillTable { } {
      global caption
      global audace
      variable private

      #--- j'affiche les fichiers dans la table
      ::Visio2::fillTable $private(tbl) [::Visio2::getFileList $private(directory)]
      #--- j'affiche le nom du repertoire courant
      configureLabelDirectory $private(labelDirectory)
      #--- je place le focus sur le contenu de la table pour permettre les deplacements
      #--- avec les touches de direction du clavier
      focus  [$private(tbl) bodypath]
   }

   #------------------------------------------------------------------------------
   # localTable::cmdButton1Click
   #   charge l'item selectionne (appelle loadItem)
   #------------------------------------------------------------------------------
   proc cmdButton1Click tbl {
      variable private
      global audace
      global caption

      set selection [$tbl curselection]
      #--- retourne immediatemment si aucun item selectionne
      if { "$selection" == "" } {
         return
      }
      if { $private(slideShowState) == 1 } {
         #--- j'arrete le slideshow 
         set private(slideShowState) 0
      }

      #--- je charge l'item selectionne
      loadItem [lindex $selection 0 ]
      
   }

   #------------------------------------------------------------------------------
   # localTable::cmdButton1DoubleClick
   #
   #------------------------------------------------------------------------------
   proc cmdButton1DoubleClick tbl {
      variable private
      global audace
      global caption

      set selection [$tbl curselection]
      #--- retourne immediatemment si aucun item selectionne
      if { "$selection" == "" } {
         return
      }

      if { $private(slideShowState) == 1 } {
         #--- j'arrete le slideshow
         set private(slideShowState) 0
      }

      #--- je charge l'item selectionne (avec option double-clic)
      loadItem [lindex $selection 0 ] 1

   }

   #------------------------------------------------------------------------------
   # localTable::loadItem
   #   si simple click :
   #    si image : affiche l'image
   #    si film  : charge le film et affiche la premiere image
   #    si sous-repertoire : efface l'image affichee precedemment
   #   sinon double click :
   #    si image : affiche l'image
   #    si film  : charge le film et affiche la premiere image
   #    si sous-repertoire : va dans le repertoire et affiche le contenu (appelle fillTable)
   #------------------------------------------------------------------------------
   proc loadItem { index { doubleClick 0 } } {
      variable private
      global audace
      global caption
      global conf

      set tbl $private(tbl)

      if { $private(animation) == 1 } {
         #--- j'arrete l'animation
         stopAnimation
      }

      set name [string trimleft [$tbl cellcget $index,0 -text]]
      set type [$tbl cellcget $index,1 -text] 
      set filename [file join "$private(directory)" "$name"]

      if { [string first "$private(fileImage)" "$type" ] != -1 } {
         #--- j'affiche l'image
         loadima $filename
         if { [::Image::isAnimatedGIF "$filename"] == 1 } {
            set ::confVisu::private(gif_anime) "1"
            setAnimationState "1"
            if { $doubleClick == 1 } {
               startAnimation
            }
         } else {
            set ::confVisu::private(gif_anime) "0"
            setAnimationState "0"
         }
      } elseif { "$type" == "$private(fileMovie)" } {
         #--- j'affiche la premiere image du film
         ::Image::loadmovie $filename
         setAnimationState "1"
         if { $doubleClick == 1 } {
            startAnimation
         }
      }  elseif { "$type" == "$private(folder)" || "$type" == "$private(volume)"} {
         if { $doubleClick == 1 } {
            #--- j'affiche le contenu du sous repertoire
            set private(directory) [ file join "$private(directory)" "$name" ]
            fillTable
         }
         setAnimationState "0"
         set name ""

      }  elseif { "$type" == "$private(parentFolder)"} {
         if { $doubleClick == 1 } {
            #--- j'affiche le contenu du repertoire parent
            if { "[file tail $private(directory)]" != "" } {
               #--- si on n'est pas à la racine du disque, on monte d'un repertoire
               set private(directory) [ file dirname "$private(directory)"  ]
               fillTable
            } else {
               #--- si on est a la racine d'un disque, j'affiche la liste des disques
               ::Visio2::fillVolumeTable $private(tbl)
            }
         }
         setAnimationState "0"
         #---  je masque le nom pour que ".." n'apparaisse pas dans la barre de titre
         set name ""
      }

      #--- j'affiche le widget dans le canvas
      set private(previousType)     "$type"
      set private(previousFileName) "$filename"

      set private(currentItemIndex) $index

   }

   #------------------------------------------------------------------------------
   # localTable::refresh
   #   recharge la liste des fichiers dans la table
   #   et affiche une image si le parametre filename est renseigne
   #------------------------------------------------------------------------------
   proc refresh { { fileName "" } } {
      variable private
      
      #--- je refraichis la liste des fichiers dans la table
      fillTable

      #--- j'affiche l'image 
      set tbl $private(tbl)
      if { "$fileName" != "" } {
         #--- je recupere les noms des fichiers presents
         set files [$tbl getcolumns 0]
         #--- je recherche l'index du fichier 
         set index [lsearch -exact $files "$fileName"]
         if { $index != -1 } {
            #--- j'efface la selection courante
            $tbl selection clear 0 end
            #--- je selectione le fichier 
            $tbl selection set [list $index]
            #--- je scrolle la table pour voir la ligne selectionnee
            $tbl see $index
            #--- je charge l'item
            loadItem $index
         }
      }
   }

   #------------------------------------------------------------------------------
   # localTable::selectAll
   #   selectionne tous les fichiers dans la table
   #------------------------------------------------------------------------------
   proc selectAll { } {
      variable private

      $private(tbl) selection set 0 end
   }

   #------------------------------------------------------------------------------
   # localTable::saveFile
   #   recharge la liste
   #   et affiche une image si le parametre filename n'est pas vide
   #------------------------------------------------------------------------------
   proc saveFile { } {
      variable private

      #TODO

   }

   #------------------------------------------------------------------------------
   # localTable::deleteFile
   #   supprime le(s) fichier(s) selectionne(s)
   #------------------------------------------------------------------------------
   proc deleteFile { } {
      variable private
      global caption
      global audace

      #--- j'arrete le diaporama
      stopSlideShow
      #--- j'arrete l'animation
      stopAnimation
      #--- je ferme le film
      ::Movie::close $audace(hCanvas)

      set tbl $private(tbl)
      set selection [$tbl curselection]
      #--- je retourne immediatemment si aucun item n'est selectionne
      if { "$selection" == "" } {
         set message "$caption(visio2,delete_file_error)"
         tk_messageBox -title "$caption(visio2,dialog_title)" -type ok -message "$message" -icon error
         return
      }

      #--- par defaut, je demande une confirmation avant de supprimer chaque fichier
      set confirm 1

      foreach index $selection { 
         set name [string trimleft [$tbl cellcget $index,0 -text]]
         set type [$tbl cellcget $index,1 -text]

         if { $type == "$private(folder)" } {
            set dir [ file join "$private(directory)" "$name" ]
            set message "$caption(visio2,delete_dir_confirm) \n $dir" 
            set choice [tk_messageBox -title "$caption(visio2,dialog_title)" -type okcancel -message "$message" -icon question]

            if { $choice == "ok" } {
               #--- je supprime le repertoire
               file delete -force "$dir"
            }

         } elseif { "$type" == "$private(fileImage)" || "$type" == "$private(fileMovie)" || "$type" == "$private(file)"} {
            set filename [file join "$private(directory)" "$name"]

            if { $confirm == 1 } {
               set choice [tk_dialog .deletefile \
                  "$caption(visio2,dialog_title)" \
                  "$caption(visio2,delete_file_confirm) $name" \
                  {} 3 $caption(visio2,delete_button0) $caption(visio2,delete_button1) $caption(visio2,delete_button2) $caption(visio2,delete_button3)]
            } else {
               set choice 0
            }

            if { $choice == 0 || $choice == 1} {
               #--- je ferme le fichier
               if { "$type" == "$private(fileMovie)" } {
                  ::Movie::close $audace(hCanvas)
               }
               #--- je supprime le fichier 
               file delete "$filename"
               if { $choice == 1 } {
                  #--- OK pour tous => je ne demanderai plus de confirmation pour supprimer chaque fichier
                  set confirm 0
               }
            } elseif { $choice == 2 } {
               #--- non => je ne supprime pas le fichier
            } elseif { $choice == 3 } {
               #--- abandonner
               break 
            }
         }
      }

      #--- je refraichis la table
      refresh
   }

   #------------------------------------------------------------------------------
   # localTable::changeZoom
   #   change la valeur du zoom
   #   et affiche l'image ou le film avec le nouveau facteur de zoom
   #------------------------------------------------------------------------------
   proc changeZoom { zoom } {
      variable private
      global audace
      global conf

      set conf(visu_zoom) "$zoom"
      visu$audace(visuNo) zoom $conf(visu_zoom)

      #--- je rafraichis l'affichage du canvas
      cmdButton1Click $private(tbl)

      #--- je rafraichis l'affichage du reticule
      ::confVisu::redrawCrosshair $audace(visuNo)
   }

   #------------------------------------------------------------------------------
   # localTable::toggleFullScreen
   #   bascule l'affichages des images normal<=>plein ecran
   #------------------------------------------------------------------------------
   proc toggleFullScreen { } {
      variable private
      global audace

      if { $audace(fullscreen) == "1" } {
         #--- je ferme les films
         ::Movie::close $audace(hCanvas)

         #--- je recupere la selection courante
         set tbl $private(tbl)
         set selection [$tbl curselection ]

         if { "$selection" == "" } {
            #--- je selectionne tout
            $tbl selection set   0 end
            set selection [$tbl curselection ]
            #--- raz de la selection
            $tbl selection clear 0 end
         }

         #--- je copie le nom et le type des fichiers
         set files ""
         foreach index $selection {
            set name [string trimleft [$tbl cellcget $index,0 -text]]
            set type [$tbl cellcget $index,1 -text] 
            if { $type == $private(fileImage) || $type =="$private(fileMovie)" } {
               lappend files [list "$name" "$type"]
            }
         }
         #--- j'ouvre la fenetre plein ecran
         ::FullScreen::showFiles $audace(visuNo) $::confVisu::private($audace(visuNo),hCanvas) $private(directory) $files
      } else { 
         ::FullScreen::close $audace(visuNo)
         #-- je re-affiche l'image ou le film
         cmdButton1Click $private(tbl)
      }
   }

   #------------------------------------------------------------------------------
   # localTable::setAnimationState
   #   active/desactive les boutons de commande de l'animation
   #------------------------------------------------------------------------------
   proc setAnimationState { state } {
      variable private
      global caption

      set menu $private(popupmenu)
      #--- je configure le popup menu
      if { $state == 1 } {
         #--- j'active les commandes d'animation
         $menu entryconfigure $caption(visio2,play_movie) -state normal
      } else {
         #--- je desactive les commandes d'animation
         $menu entryconfigure $caption(visio2,play_movie) -state disabled
      }
   }

   #------------------------------------------------------------------------------
   # localTable::toggleAnimation
   # 
   #------------------------------------------------------------------------------
   proc toggleAnimation { } {
      variable private
      
      if { $private(animation) == 1 } {
         startAnimation
      } else {
         stopAnimation
      }
   }

   #------------------------------------------------------------------------------
   # localTable::startAnimation
   #   Lance une animation (film ou GIF anime)
   #------------------------------------------------------------------------------
   proc startAnimation { } {
      variable private
      global conf
      global audace

      #--- je recupere le nom du fichier selectionne
      set selection [$private(tbl) curselection ]
      set index [lindex $selection 0 ]
      set name [string trimleft  [$private(tbl) cellcget $index,0 -text]]
      set filename [file join "$private(directory)" "$name"]
      if { "$private(previousType)" == "$private(fileImage)" } {
         ::Image::startGifAnimation image$audace(imageNo) $conf(visu_zoom) $filename
      } elseif { "$private(previousType)" == "$private(fileMovie)" } {
         ::Movie::start
      }
      set private(animation) 1
      update
   }

   #------------------------------------------------------------------------------
   # localTable::stopAnimation
   #   arrete une animation (film ou GIF anime)
   #------------------------------------------------------------------------------
   proc stopAnimation { } {
      variable private

      if { "$private(previousType)" == "$private(fileImage)" } {
         ::Image::stopGifAnimation 
      } elseif { "$private(previousType)" == "$private(fileMovie)" } {
         ::Movie::stop
      }
      set private(animation) 0
      update
   }

   #------------------------------------------------------------------------------
   # localTable::startSlideShow
   #   lance le diaporama
   #------------------------------------------------------------------------------
   proc startSlideShow { } {
      variable private
      global caption

      #--- je recupere le nombre d'images selectionnees
      set selection [$private(tbl) curselection ]
      #--- je verifie que le nombre d'images selectionnées est suffisant (>=2)
      if { [llength $selection] < 2 } {
         #--- erreur , il n'y a moins de 2 images selectionnees
         ###tk_messageBox -title "$caption(visio2,dialog_title)" -type ok -message "$caption(visio2,slideshow_error)" -icon error
         tk_dialog .tempdialog \
            "$caption(visio2,dialog_title)" \
            "$caption(visio2,slideshow_error)" \
            {} \
            0  \
            "OK"
         #--- j'abandonnne le SlideShow
         set private(slideShowState) "0"
         return
      } else {
         #--- je lance le SlideShow
         set private(slideShowListe) $selection
         set private(slideShowAfterId) [after 10 ::Visio2::localTable::showNextSlide ]
      }
   }

   #------------------------------------------------------------------------------
   # localTable::showNextSlide
   #   affiche l'image suivante du diaporama
   #------------------------------------------------------------------------------
   proc showNextSlide { { currentitem "0" } } {
      variable private
      global caption
      global audace

      #--- si une demande d'arret a deja ete faite, je ne fais plus rien
      if { $private(slideShowState) == 0 } {
         return
      }

      #--- je recupere les informations de l'item suivante
      set index [lindex $private(slideShowListe) $currentitem ]

      loadItem $index 1

      #--- j'incremente currentitem
      if { $currentitem < [expr [llength $private(slideShowListe)] -1 ] } {
         incr currentitem
      } else {
         set currentitem "0"
      }

      #--- je lance l'iteration suivante
      if { $private(slideShowState) == 1 } {
         set result [ catch { set delay [expr round($private(slideShowDelay) * 1000) ] } ]
         if { $result != 0 } {
            #--- remplace le delai incorrect
            set delay "1000"
         }
         set private(slideShowAfterId) [after $delay ::Visio2::localTable::showNextSlide $currentitem ]
      }
   }

   #------------------------------------------------------------------------------
   # localTable::stopSlideShow
   #   arrete le diaporama
   #------------------------------------------------------------------------------
   proc stopSlideShow { } {
      variable private

      set private(slideShowState) "0"
      if { "$private(slideShowAfterId)" != "" } {
         #--- je tue l'iteration en attente
         after cancel $private(slideShowAfterId)
         set private(slideShowAfterId) ""
      }
   }

   #------------------------------------------------------------------------------
   # localTable::saveColumnWidth
   #   sauve la largeur des colonnes dans conf()
   #------------------------------------------------------------------------------
   proc saveColumnWidth { } {
      variable private
      global conf

      #--- save columns width
      set conf(Visio2,width_column_name)   [$private(tbl) columncget 0 -width] 
      set conf(Visio2,width_column_type)   [$private(tbl) columncget 1 -width] 
      set conf(Visio2,width_column_series) [$private(tbl) columncget 2 -width] 
      set conf(Visio2,width_column_date)   [$private(tbl) columncget 3 -width] 
      set conf(Visio2,width_column_size)   [$private(tbl) columncget 4 -width] 
   }

   #------------------------------------------------------------------------------
   # localTable::createTbl
   #   affiche la table avec ses scrollbar dans une frame
   #   et cree le menu pop-up associe
   #------------------------------------------------------------------------------
   proc createTbl { frame } {
      global caption
      global conf
      global audace
      variable private

      #--- quelques raccourcis utiles
      set tbl $frame.tbl
      set private(tbl) "$tbl"
      set private(labelDirectory) "$frame.directory"
      set menu $frame.menu
      set private(popupmenu) "$menu"

      #--- repertoire
      label $frame.directory -anchor w -relief raised -bd 1 
      #--- pour intercepter les mises a jour du label ( equivalent a l'option -textvariable)
      bind $frame.directory <Configure> "::Visio2::localTable::configureLabelDirectory $frame.directory "

      #--- table des fichiers
      tablelist::tablelist $tbl \
         -columns [ list \
            12 $caption(visio2,column_name)   left  \
            10 $caption(visio2,column_type)   left  \
            10 $caption(visio2,column_series) left  \
            17 $caption(visio2,column_date)   left  \
            10 $caption(visio2,column_size)   right \
            ] \
         -labelcommand ::Visio2::cmdSortColumn  \
         -xscrollcommand [list $frame.hsb set] -yscrollcommand [list $frame.vsb set] \
         -selectmode extended \
         -activestyle none

      #--- je fixe la largeur des colonnes
      $tbl columnconfigure 0 -width $conf(Visio2,width_column_name) 
      $tbl columnconfigure 1 -width $conf(Visio2,width_column_type) 
      $tbl columnconfigure 2 -width $conf(Visio2,width_column_series)
      $tbl columnconfigure 3 -width $conf(Visio2,width_column_date) 
      $tbl columnconfigure 4 -width $conf(Visio2,width_column_size) 

      #--- j'affiche ou masque les colonnes (la premiere colonne est toujours visible)
      $tbl columnconfigure 0 -hide 0   
      $tbl columnconfigure 1 -hide [expr !$conf(Visio2,show_column_type) ]
      $tbl columnconfigure 2 -hide [expr !$conf(Visio2,show_column_series) ]
      $tbl columnconfigure 3 -hide [expr !$conf(Visio2,show_column_date) ]
      $tbl columnconfigure 4 -hide [expr !$conf(Visio2,show_column_size) ]

      #--- choix de l'ordre aphabetique en fonction de l'OS ( pour ne pas depayser les habitues)
      if { $::tcl_platform(os) == "Linux" } {
         #--- je classe les fichiers par ordre alphabetique , en tenant compte des majuscule/minuscule
         $tbl columnconfigure 0 -sortmode ascii
      } else {
         #--- je classe les fichiers par ordre alphabetique , sans tenir compte des majuscule/minuscule
         $tbl columnconfigure 0 -sortmode dictionary
      }

      #--- j'adapte la largeur de la liste en fonction des colonnes affichees
      ::Visio2::showColumn $tbl 0 1

      #--- scrollbar verticale et horizontale
      scrollbar $frame.vsb -orient vertical   -command [list $tbl yview]
      scrollbar $frame.hsb -orient horizontal -command [list $tbl xview]

      #--- je place la liste et les scrollbar dans une grille 
      grid $frame.directory -row 0 -column 0 -columnspan 2 -sticky ew
      grid $tbl -row 1 -column 0 -sticky ns
      grid $frame.vsb -row 1 -column 1 -sticky ns
      grid $frame.hsb -row 2 -column 0 -sticky ew
      grid rowconfigure    $frame 1 -weight 1
      grid columnconfigure $frame 0 -weight 1

      #--- pop-up menu associe a la table
      menu $menu -tearoff no
      $menu add command -label $caption(visio2,refresh) \
         -command "::Visio2::localTable::refresh"
      $menu add command -label $caption(visio2,select_all) \
         -command "::Visio2::localTable::selectAll"
      $menu add command -label $caption(visio2,save_file) -state disabled \
         -command "::Visio2::localTable::saveFile"
      $menu add command -label $caption(visio2,delete_file) \
         -command "::Visio2::localTable::deleteFile"

      $menu add separator
      $menu add checkbutton -label $caption(visio2,column_type)   \
         -variable conf(Visio2,show_column_type)       \
         -command "::Visio2::showColumn $::Visio2::localTable::private(tbl) 1 $conf(Visio2,show_column_type)"
      $menu add checkbutton -label $caption(visio2,column_series) \
         -variable conf(Visio2,show_column_series)     \
         -command "::Visio2::showColumn $::Visio2::localTable::private(tbl) 2 $conf(Visio2,show_column_series)"
      $menu add checkbutton -label $caption(visio2,column_date)   \
         -variable conf(Visio2,show_column_date)       \
         -command "::Visio2::showColumn $::Visio2::localTable::private(tbl) 3 $conf(Visio2,show_column_date)"
      $menu add checkbutton -label $caption(visio2,column_size)   \
         -variable conf(Visio2,show_column_size)       \
         -command "::Visio2::showColumn $::Visio2::localTable::private(tbl) 4 $conf(Visio2,show_column_size)"

      $menu add separator
      $menu add cascade -label $caption(visio2,zoom) -menu $menu.zoom
      menu $menu.zoom -tearoff no

      $menu.zoom add radiobutton -label "$caption(visio2,zoom_0.125)" \
         -indicatoron "1" \
         -value "0.125" \
         -variable conf(visu_zoom) \
         -command "::Visio2::localTable::changeZoom 0.125"
      $menu.zoom add radiobutton -label "$caption(visio2,zoom_0.25)" \
         -indicatoron "1" \
         -value "0.25" \
         -variable conf(visu_zoom) \
         -command "::Visio2::localTable::changeZoom 0.25"
      $menu.zoom add radiobutton -label "$caption(visio2,zoom_0.5)" \
         -indicatoron "1" \
         -value "0.5" \
         -variable conf(visu_zoom) \
         -command "::Visio2::localTable::changeZoom 0.5"
      $menu.zoom add radiobutton -label "$caption(visio2,zoom_1)" \
         -indicatoron "1" \
         -value "1" \
         -variable conf(visu_zoom) \
         -command "::Visio2::localTable::changeZoom 1"
      $menu.zoom add radiobutton -label "$caption(visio2,zoom_2)" \
         -indicatoron "1" \
         -value "2" \
         -variable conf(visu_zoom) \
         -command "::Visio2::localTable::changeZoom 2"
      $menu.zoom add radiobutton -label "$caption(visio2,zoom_4)" \
         -indicatoron "1" \
         -value "4" \
         -variable conf(visu_zoom) \
         -command "::Visio2::localTable::changeZoom 4"

      $menu add checkbutton -label $caption(visio2,full_screen) \
         -variable audace(fullscreen) \
         -command "::Visio2::localTable::toggleFullScreen"

      $menu add command -label $caption(visio2,config) -command "::Visio2::configure"
      $menu add command -label $caption(visio2,help)  \
         -command {
            ::audace::showHelpPlugin "tool" "visio2" "visio2.htm"
         }

      $menu add separator  
      $menu add checkbutton -label $caption(visio2,play_movie) \
         -variable ::Visio2::localTable::private(animation) \
         -command "::Visio2::localTable::toggleAnimation"

      bind [$tbl bodypath] <<Button3>> [list tk_popup $menu %X %Y]

      bind $tbl <<ListboxSelect>>      [list ::Visio2::localTable::cmdButton1Click $tbl]
      bind [$tbl bodypath] <Double-1>  [list ::Visio2::localTable::cmdButton1DoubleClick $tbl]
      bind [$tbl bodypath] <Return>    [list ::Visio2::localTable::cmdButton1DoubleClick $tbl]

   }

   #------------------------------------------------------------------------------
   # localTable::configureLabelDirectory  
   #   affiche private(directory) dans le label
   #     si le label a une taille suffisante, affiche private(directory) en entier
   #     si le label a une taille insuffisante, affiche la fin de private(directory)
   #------------------------------------------------------------------------------
   proc configureLabelDirectory { label } {
      variable private     

      set tt "$private(directory)"
      set labelwidth [expr [winfo width $label]-5]
      if { [font measure [$label cget -font] $tt] <= $labelwidth } {
         #--- affiche private(directory) en entier
         $label configure -text $tt
      } else {
         while { [string length $tt] > 3 } {
            set tt [string range $tt 1 end]
            if { [font measure [$label cget -font] ...$tt] <= $labelwidth } {
               break
            }
         }
         #--- affiche "..." suivi de la fin de private(directory)
         $label configure -text .$tt
      }
   }

}

################################################################
#   namespace ::Visio2::ftpTable
#    gere la table des fichiers du serveur FTP
################################################################
namespace eval ::Visio2::ftpTable {
   variable private 
      set private(parentFolder)        $::Visio2::private(parentFolder)
      set private(folder)              $::Visio2::private(folder)
      set private(fileImage)           $::Visio2::private(fileImage)
      set private(fileMovie)           $::Visio2::private(fileMovie) 
      set private(file)                $::Visio2::private(file) 
      set private(tbl)                 ""
      set private(directory)           "/"
      set private(frame)               ""



   #------------------------------------------------------------------------------
   # ftpTable::init
   #   affiche les fichiers dans la table
   #   retourne 1 si la connexion a reussi, sinon retourne 0
   #------------------------------------------------------------------------------
   proc init { mainframe } {
      variable private
      global audace
      global caption

      set private(frame) "$mainframe.ftplist"

         #--- j'affiche la fenetre de selection d'un connexion ftp
         set result [::ftpclient::selectConnection]

         if { $result == 1 } {
            set private(directory) "[::ftpclient::getDirectory]"
            #--- si la connection a reussi, j'affiche la liste des fichiers
            if { [ fillTable "$private(directory)" ] != 1 } {
                  set message "$caption(visio2,show_directory) $private(directory)"
                  console::affiche_erreur "$message \n"
                  tk_messageBox -title "$caption(visio2,ftp_connection_title)" -type ok -message "$message" -icon error
                  set result 0
            } else {
               #--- j'affiche la table
               pack $mainframe.ftplist  -fill both -expand 1 -anchor n -side bottom
               update
               configureLabelDirectory $private(labelDirectory) "$private(directory)"
               set result 1
            }
         } elseif { $result == 0 } {
            #--- si la connexion a echoue, j'affiche un message d'erreur
            #set message "$caption(visio2,ftp_connection_error) [::ftpclient::getUrl]"
            #console::affiche_erreur "$message \n"    
            #tk_messageBox -title "$caption(visio2,ftp_connection_title)" -type ok -message "$message" -icon error
            set result 0
         } else {
            #--- je decoche le checkbutton
            set result 0
         }         
      return $result
   }

   #------------------------------------------------------------------------------
   # ftpTable::close
   #   ferme la connexion ftp
   #   et supprime la table de l'affichage
   #   retourne 1 si la fermeture est faite , sinon retourne 0
   #------------------------------------------------------------------------------
   proc close { } {
      variable private
      global caption

      #--- ferme la connexion et supprime la table ftpTable
      if { "[::ftpclient::isOpened]" == "0" } {
         # s'il n'y a pas de connexion en cours
         # il suffit de masquer la table ftp
         pack forget $private(frame)
         set result 1
      } else {
         # si une connexion est en cours 
         # je demande d'abord la confirmation de la fermeture
         set message "$caption(visio2,ftp_connection_close) [::ftpclient::getUrl]"
         set choice [tk_messageBox -title "$caption(visio2,ftp_connection_title)" -type okcancel -message "$message" -icon question ]
         if { $choice == "ok" } {
            #--- je ferme la connexion FTP en cours
            ::ftpclient::close
            #--- je masque la table ftp
            pack forget $private(frame)
            set result 1
         } else {
            # refus de l'utilisateur
            set result 0
         }
      }
      return $result 
   }

   #------------------------------------------------------------------------------
   # ftpTable::fillTable
   #   affiche les fichiers dans la table
   #------------------------------------------------------------------------------
   proc fillTable { directory } {
      global caption
      global conf
      global audace
      variable private

      set result 0
      #--- je recupere la liste des fichiers du serveur distant
      set files  [::ftpclient::getFileList "$directory" ]

      if { $files != "" } {
         set private(directory) "$directory"
         #--- j'affiche les noms des fichiers dans la table
         ::Visio2::fillTable $private(tbl) $files
         #--- je place le focus sur le contenu de la table pour permettre les deplacements avec les touches de direction du clavier
         focus  [$private(tbl) bodypath]
         set result 1
      }
      return $result 
   }

   #------------------------------------------------------------------------------
   # localTable::refresh
   #   recharge la liste des fichiers dans la table
   #   et affiche une image si le parametre filename est renseigne
   #------------------------------------------------------------------------------
   proc refresh { { fileName "" } } {
      variable private

      set tbl $private(tbl)
      if { "$private(frame)" == "" } {
         #--- rien a faire si la table n'est pas affichee
         return
      }

      if { [winfo manager $private(frame)] == "" } {
         #--- rien a faire si la table n'est pas affichee
         return
      }
      #--- je refraichis la liste des fichiers dans la table
      fillTable "$private(directory)"     

      #--- j'affiche l'image 
      if { "$fileName" != "" } {
         #--- je recupere les noms des fichiers presents
         set files [$tbl getcolumns 0]
         #--- je recherche l'index du fichier 
         set index [lsearch -exact $files "$fileName"]
         if { $index != -1 } {
            #--- j'efface la selection courante
            $tbl selection clear 0 end
            #--- je selection le fichier 
            $tbl selection set [list $index]
            #--- je scrolle la table pour voir la ligne selectionnee
            $tbl see $index
            #--- j'affiche le fichier
            cmdButton1Click
         }
      }
   }

   #------------------------------------------------------------------------------
   # ftpTable::cmdButton1Click
   #   simple click sur le bouton 1
   #     n'est pas utilise pour l'instant
   #------------------------------------------------------------------------------
   proc cmdButton1Click { } {
      variable private
      global audace
      global caption

      return
   }

   #------------------------------------------------------------------------------
   # ftpTable::cmdButton1DoubleClick
   #   Double click sur le bouton 1
   #     si image : copie l'image dans le repertoire local courant (appelle ::ftpclient::get)
   #     si film  : copie le film dans le repertoire local courant (appelle ::ftpclient::get)
   #     si sous-repertoire : va dans le repertoire et affiche le contenu (appelle fillTable)
   #------------------------------------------------------------------------------
   proc cmdButton1DoubleClick { } {
      variable private
      global audace
      global caption

      set tbl $private(tbl)
      set selection [$tbl curselection]      
      if { "$selection" == "" } {
         return
      }

      #--- j'extrait l'index, le nom et le type contenus dans la ligne selectionnee
      set index [lindex $selection 0 ]
      set name [string trimleft  [$tbl cellcget $index,0 -text]]
      set type [$tbl cellcget $index,1 -text]
      set size [$tbl cellcget $index,4 -text]

      if { $type == "$private(parentFolder)" } {
         #--- j'affiche le contenu du repertoire parent
         set directory [ file dirname "$private(directory)" ]
         if { [ fillTable "$directory" ] != 1 } {
            set message "$caption(visio2,show_directory) $directory"
            console::affiche_erreur "$message \n"
            tk_messageBox -title "$caption(visio2,ftp_connection_title)" -type ok -message "$message" -icon error
         }

      } elseif { $type == "$private(folder)" }  {
         #--- j'affiche le contenu du sous-repertoire
         set directory [ file join "$private(directory)" "$name" ]
         if { [ fillTable "$directory" ] != 1 } {
            set message "$caption(visio2,show_directory) $directory"
            console::affiche_erreur "$message \n"
            tk_messageBox -title "$caption(visio2,ftp_connection_title)" -type ok -message "$message" -icon error
         }

      }  elseif { "$type" == "$private(fileImage)" || "$type" == "$private(fileMovie)" ||  "$type" == "$private(file)" } {
         #--- copie le fichier du serveur distant vers le repertoire local et affiche l'image
         set targetDir "[::Visio2::localTable::getDirectory]"
         if { [ file exists [file join "$targetDir" "$name"] ] } {
            #--- demande de confirmation d'ecrasement du fichier existant
            set choice [tk_messageBox -message "$caption(visio2,file_exist)" -title "$caption(visio2,dialog_title)" -icon question -type yesno]
            if {$choice=="no"} {
               return
            }
         }

         #--- je copie le fichier 
         set filename [file join "$private(directory)" "$name"] 
         ::ftpclient::get "$filename" "$targetDir" "$size"

         #--- je refraichis l'affichage de la table locale et affiche l'image
         ::Visio2::localTable::refresh "$name"
      }
   }

   #------------------------------------------------------------------------------
   # ftpTable::createTbl
   #   cree la table et les scrollbar dans une frame
   #------------------------------------------------------------------------------
   proc createTbl { frame } {
      global caption
      global conf
      global audace
      variable private

      #--- quelques raccourcis utiles
      set tbl $frame.tbl
      set private(tbl) "$tbl"
      set private(labelDirectory) "$frame.directory"

      #--- repertoire
      label $frame.directory -anchor w -relief raised -bd 1
      #--- pour intercepter les mises a jour du label ( equivalent a l'option -textvariable)
      bind $frame.directory <Configure> "::Visio2::ftpTable::configureLabelDirectory $private(labelDirectory) $private(directory) "

      #--- table des fichiers
      tablelist::tablelist $tbl \
         -columns [ list \
            12 $caption(visio2,column_name)   left \
            10 $caption(visio2,column_type)   left \
            10 $caption(visio2,column_series) left \
            17 $caption(visio2,column_date)   left \
            10 $caption(visio2,column_size)   right \
            ] \
         -labelcommand ::Visio2::cmdSortColumn \
         -xscrollcommand [list $frame.hsb set] -yscrollcommand [list $frame.vsb set] \
         -selectmode extended \
         -activestyle none \

      #--- je fixe la largeur des colonnes
      $tbl columnconfigure 0 -width $conf(Visio2,width_column_name) 
      $tbl columnconfigure 1 -width $conf(Visio2,width_column_type) 
      $tbl columnconfigure 2 -width $conf(Visio2,width_column_series) 
      $tbl columnconfigure 3 -width $conf(Visio2,width_column_date) 
      $tbl columnconfigure 4 -width $conf(Visio2,width_column_size) 

      #--- j'affiche ou masque les colonnes (la premiere colonne est toujours visible)
      $tbl columnconfigure 0 -hide 0   
      $tbl columnconfigure 1 -hide [expr !$conf(Visio2,show_column_type) ]
      $tbl columnconfigure 2 -hide [expr !$conf(Visio2,show_column_series) ]
      $tbl columnconfigure 3 -hide [expr !$conf(Visio2,show_column_date) ]
      $tbl columnconfigure 4 -hide [expr !$conf(Visio2,show_column_size) ]

      #--- j'adapte la largeur de la liste en fonction des colonnes affichees
      ::Visio2::showColumn $tbl 0 1

      #--- choix de l'ordre aphabetique en fonction de l'OS pour ne pas depayser les habitues 
      if { $::tcl_platform(os) == "Linux" } {
         #--- je classe les fichiers par ordre alphabetique , en tenant compte des majuscule/minuscule
         $tbl columnconfigure 0 -sortmode ascii 
      } else {
         #--- je classe les fichiers par ordre alphabetique , sans tenir compte des majuscule/minuscule
         $tbl columnconfigure 0 -sortmode dictionary 
      }         

      #--- scrollbar verticale et horizontale
      scrollbar $frame.vsb -orient vertical   -command [list $tbl yview]
      scrollbar $frame.hsb -orient horizontal -command [list $tbl xview]

      #--- je place la liste et les scrollbar dans une grille 
      grid $frame.directory -row 0 -column 0 -columnspan 2 -sticky ew
      grid $tbl -row 1 -column 0 -sticky ns
      grid $frame.vsb -row 1 -column 1 -sticky ns
      grid $frame.hsb -row 2 -column 0 -sticky ew
      grid rowconfigure    $frame 1 -weight 1
      grid columnconfigure $frame 0 -weight 1

      #--- pop-up menu for the tablelist  
      set menu $frame.menu
       menu $menu -tearoff no
      $menu add command -label $caption(visio2,get_file) \
         -command "::Visio2::ftpTable::cmdButton1DoubleClick"

      bind [$tbl bodypath] <<Button3>> [list tk_popup $menu %X %Y]

      bind $tbl <<ListboxSelect>>      [list ::Visio2::ftpTable::cmdButton1Click ]
      bind [$tbl bodypath] <Double-1>  [list ::Visio2::ftpTable::cmdButton1DoubleClick ]
      bind [$tbl bodypath] <Return>    [list ::Visio2::ftpTable::cmdButton1DoubleClick ]
   }

   #------------------------------------------------------------------------------
   # localTable::configureLabelDirectory
   #   affiche private(directory) dans le label
   #   si le label a une taille suffisante, affiche private(directory) en entier
   #   si le label a une taille insuffisante, affiche la fin de private(directory)
   #------------------------------------------------------------------------------
   proc configureLabelDirectory { label directory} {
      variable private 

      set tt "$directory" 
      set labelwidth [expr [winfo width $label]-5]
      if { [font measure [$label cget -font] $tt] <= $labelwidth } {
         #--- affiche en entier
         $label configure -text $tt
      } else {
         while { [string length $tt] > 3 } {
            set tt [string range $tt 1 end]
            if { [font measure [$label cget -font] ...$tt] <= $labelwidth } {
               break
            }
         }
         #--- affiche "..." suivi de la fin de directory
         $label configure -text ...$tt
      }
   }

}

::Visio2::init $audace(base)


#ftpserver::start

