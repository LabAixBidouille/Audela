#
# Fichier : sn_tarot_go.tcl
# Description : Outil pour la recherche de supernovae
# Auteur : Alain KLOTZ et Raymond ZACHANTKE
# Mise à jour $Id$
#

#============================================================
# Declaration du namespace sn_tarot
#    initialise le namespace
#============================================================
namespace eval ::sn_tarot {
   package provide sn_tarot 1.0
   
   #--- Chargement des captions pour recuperer le titre utilise par getPluginLabel
   source [ file join [file dirname [info script]] sn_tarot_go.cap ]
   source [ file join [file dirname [info script]] sn_tarot.cap ]
   source [ file join [file dirname [info script]] sn_tarot.tcl ]
   source [ file join [file dirname [info script]] sn_tarot_macros.tcl ]
   source [ file join [file dirname [info script]] sn_tarot_http.tcl ]
}

#------------------------------------------------------------
# getPluginTitle
#    retourne le titre du plugin dans la langue de l'utilisateur
#------------------------------------------------------------
proc ::sn_tarot::getPluginTitle { } {
   global caption

   return "$caption(sn_tarot_go,supernovae)"
}

#------------------------------------------------------------
# getPluginHelp
#    retourne le nom du fichier d'aide principal
#------------------------------------------------------------
proc ::sn_tarot::getPluginHelp { } {
   return "sn_tarot.htm"
}

#------------------------------------------------------------
# getPluginType
#    retourne le type de plugin
#------------------------------------------------------------
proc ::sn_tarot::getPluginType { } {
   return "tool"
}

#------------------------------------------------------------
# getPluginDirectory
#    retourne le type de plugin
#------------------------------------------------------------
proc ::sn_tarot::getPluginDirectory { } {
   return "sn_tarot"
}

#------------------------------------------------------------
# getPluginOS
#    retourne le ou les OS de fonctionnement du plugin
#------------------------------------------------------------
proc ::sn_tarot::getPluginOS { } {
   return [ list Windows Linux Darwin ]
}

#------------------------------------------------------------
# getPluginProperty
#    retourne la valeur de la propriete
#
# parametre :
#    propertyName : nom de la propriete
# return : valeur de la propriete ou "" si la propriete n'existe pas
#------------------------------------------------------------
proc ::sn_tarot::getPluginProperty { propertyName } {
   switch $propertyName {
      function     { return "analysis" }
      subfunction1 { return "display" }
      display      { return "panel" }
   }
}

#------------------------------------------------------------
# initPlugin
#    initialise le plugin
#------------------------------------------------------------
proc ::sn_tarot::initPlugin { tkbase } {

}

#------------------------------------------------------------
# createPluginInstance
#    cree une nouvelle instance de l'outil
#------------------------------------------------------------
proc ::sn_tarot::createPluginInstance { { in "" } { visuNo 1 } } {
   ::sn_tarot::createPanel $in.sn_tarot
}

#------------------------------------------------------------
# deletePluginInstance
#    suppprime l'instance du plugin
#------------------------------------------------------------
proc ::sn_tarot::deletePluginInstance { visuNo } {
   variable bdd_coord
   global audace

   if { [ winfo exists $audace(base).snvisu ] } {
      ::sn_tarot::snDelete
   }
}

#------------------------------------------------------------
# createPanel
#    prepare la creation de la fenetre de l'outil
#------------------------------------------------------------
proc ::sn_tarot::createPanel { this } {
   variable This
   global conf panneau rep audace

   package require http

   set dir "$conf(rep_archives)"
   set panneau(init_dir) [ file join $dir tarot ]
   set rep(archives) "[ file join $panneau(init_dir) archives ]" ; # chemin du repertoire des archives
   set rep(name1)    "[ file join $panneau(init_dir) night ]" ; # chemin du repertoire images de la nuit
   #set rep(name2)    "[ file join $panneau(init_dir) references ] " ; # chemin du repertoire images de reference galtarot
   #set rep(name3)    "[ file join $panneau(init_dir) dss ]" ; # chemin du repertoire images de reference dss

   set panneau(sn_tarot,Tarot_Calern,url)    "http://tarot6.obs-azur.fr/ros/supernovae/zip/"
   set panneau(sn_tarot,Tarot_Chili,url)     "http://tarotchili5.oamp.fr/ros/supernovae/zip/"
   set panneau(sn_tarot,Zadko_Australia,url) "http://121.200.43.11/ros/supernovae/zip/"
   set panneau(sn_tarot,ohp,url)             "http://cador.obs-hp.fr/tarot/"
   
   set audace(sn_tarot,ok_zadko) 0
   set hostname [lindex [hostaddress] end]
   if {$hostname=="astrostar"} {
      set audace(sn_tarot,ok_zadko) 1
   }
   
   ::sn_tarot::updateFiles
   vwait panneau(sn_tarot,init)

   #--- Initialisation du nom de la fenetre
   set This $this
   #--- Construction de l'interface
   ::sn_tarot::tarotBuildIF

   ::sn_tarot::selectSite
   ::sn_tarot::listArchives
}

#------------------------------------------------------------
# startTool
#    affiche la fenetre de l'outil
#------------------------------------------------------------
proc ::sn_tarot::startTool { visuNo } {
   variable This

   pack $This -side left -fill y
}

#------------------------------------------------------------
# stopTool
#    masque la fenetre de l'outil
#------------------------------------------------------------
proc ::sn_tarot::stopTool { visuNo } {
   variable This

   pack forget $This
}

#------------------------------------------------------------
# tarotBuildIF
#    cree la fenetre de l'outil
#------------------------------------------------------------
proc ::sn_tarot::tarotBuildIF { } {
   variable This
   global audace caption panneau
   
   frame $This -borderwidth 2 -relief groove

   #--- Frame du titre
   frame $This.fra1 -borderwidth 2 -relief groove

   #--- Bouton du titre
   Button $This.fra1.but -borderwidth 1 \
      -text "$caption(sn_tarot_go,help,titre1)\n$caption(sn_tarot_go,supernovae)" \
      -command "::sn_tarot::snHelp"
   pack $This.fra1.but -anchor center -expand 1 -fill both -side top -ipadx 5
   DynamicHelp::add $This.fra1.but -text "$caption(sn_tarot_go,help,titre)"

   pack $This.fra1 -side top -fill x

   #--- Frame de Recherche
   frame $This.fra2 -borderwidth 1 -relief groove

   #---
   set list_prefix [ list Tarot_Calern Tarot_Chili ]
   if {$audace(sn_tarot,ok_zadko)==1} {
      lappend list_prefix Zadko_Australia
   }
   set width [expr {int([::tkutil::lgEntryComboBox $list_prefix]*6/7)}]
   ComboBox $This.fra2.site -width $width -relief sunken -borderwidth 1 \
      -textvariable panneau(sn_tarot,prefix) \
      -values $list_prefix -editable 0 \
      -modifycmd "::sn_tarot::selectSite"
   pack $This.fra2.site -anchor center -fill none -pady 5
   $This.fra2.site setvalue @0

   #---
   ComboBox $This.fra2.file -width $width  -height 2 -relief sunken -borderwidth 1 \
      -textvariable panneau(sn_tarot,date) -editable 0 \
      -values $panneau(sn_tarot,$panneau(sn_tarot,prefix)) \
      -modifycmd "::sn_tarot::defineFileZip"
   pack $This.fra2.file -anchor center -fill none -pady 5
   $This.fra2.file setvalue @0

   #--- Bouton Rafraichir
   button $This.fra2.but0 -borderwidth 2 \
      -text "$caption(sn_tarot_go,refresh)" \
      -command "catch {unset panneau(sn_tarot,init)} ; ::sn_tarot::updateFiles ; vwait panneau(sn_tarot,init) ; ::sn_tarot::listArchives"
   pack $This.fra2.but0 -anchor center -fill none -pady 5 -ipadx 5 -ipady 5

   #--- Bouton Telecharger
   button $This.fra2.but1 -borderwidth 2 \
      -text "$caption(sn_tarot_go,telecharger)" \
      -command "::sn_tarot::confirmTelecharge"
   pack $This.fra2.but1 -anchor center -fill none -pady 5 -ipadx 5 -ipady 5

   #--- Bouton Recherche supernovae
   button $This.fra2.but2 -borderwidth 2 -text "$caption(sn_tarot_go,recherche_sn)" \
     -command "::sn_tarot::Explore"
   pack $This.fra2.but2 -anchor center -fill none -pady 5 -ipadx 5 -ipady 5

   #--- Bouton Status candidates
   button $This.fra2.but3 -borderwidth 2 -text "$caption(sn_tarot_go,status_candidates)" \
     -command "::sn_tarot::snAnalyzeCandidateId"
   pack $This.fra2.but3 -anchor center -fill none -pady 5 -ipadx 5 -ipady 5

   pack $This.fra2 -side top -fill x

   #--   pour definir le fichier courant
   ::sn_tarot::defineFileZip

   #--- Mise a jour dynamique des couleurs
   ::confColor::applyColor $This
}

#-----------------------------------------------------
#  snHelp
#     Commande du bouton 'Aide'
#     Parametre optionnel  : le nom de l'item dans la page htm
#  Liee a updateFiles et tarotBuildIF
#-----------------------------------------------------
proc ::sn_tarot::snHelp { { item "" } } {

  ::audace::showHelpPlugin [ ::audace::getPluginTypeDirectory [ ::sn_tarot::getPluginType ] ] \
      [ ::sn_tarot::getPluginDirectory ] [ ::sn_tarot::getPluginHelp ] $item
}

#------------------------------------------------------------
# selectSite
#     Definit les parametres du site actif
#     Rafraichit la liste des dates affichees
#  Commande associee a la combobox de selection du site
#------------------------------------------------------------
proc ::sn_tarot::selectSite { } {
   variable This
   global panneau

   set prefix $panneau(sn_tarot,prefix)
   $This.fra2.file configure -values $panneau(sn_tarot,$prefix)

   #--   met a jour l'url correspondant a la selction
   set panneau(sn_tarot,url0) "$panneau(sn_tarot,${prefix},url)"

   #--   pointe le premier de la liste
   set panneau(sn_tarot,date) [ lindex $panneau(sn_tarot,$prefix) 0 ]

   ::sn_tarot::defineFileZip
}

#------------------------------------------------------------
# defineFileZip
#     Definit le nom du fichier a telecharger
# Commande de tarotBuildIF et liee a selectSite
#------------------------------------------------------------
proc ::sn_tarot::defineFileZip { } {
   global panneau snconfvisu

   #-- positionne la combobox sur le fichier
   set snconfvisu(night) "${panneau(sn_tarot,prefix)}_${panneau(sn_tarot,date)}"
   set panneau(sn_tarot,file_zip) "$snconfvisu(night).zip"
}

#------------------------------------------------------------
# confirmTelecharge
#    Confirme le telechargement
# Commande du bouton 'Telecharger'
#------------------------------------------------------------
proc ::sn_tarot::confirmTelecharge { } {
   variable This
   global audace caption panneau rep

   #--   si l'utilisateur n'a pas fait de selection
   if { ![ info exists panneau(sn_tarot,url0) ] || ![ info exists panneau(sn_tarot,file_zip) ] } {
      ::sn_tarot::selectSite
   }

   #--   raccourci
   set file_zip $panneau(sn_tarot,file_zip)

   if { [ tk_dialog .q "$caption(sn_tarot_go,telecharger)" \
      [ format $caption(sn_tarot_go,telecharge) $file_zip ] questhead 0 \
      $caption(sn_tarot_go,yes) $caption(sn_tarot_go,no) ] == 1 } {
      return
   }

   #--   inhibe les selecteurs et les boutons 'Telecharger' 'Recherche Supernovae'
   foreach child [ list site file but0 but1 but2 but3 ] {
      $This.fra2.$child configure -state disabled
   }
   $This.fra2.but1 configure -text "$caption(sn_tarot_go,telechargement)"
   update

   if { [ ::sn_tarot::downloadFile $panneau(sn_tarot,url0) $file_zip [ file join $rep(archives) $file_zip ] ] } {
      ::sn_tarot::listArchives
   }

   #--   desinhibe
   $This.fra2.but1 configure -text "$caption(sn_tarot_go,telecharger)"
   foreach child [ list site file but0 but1 but2 but3 ] {
      $This.fra2.$child configure -state normal
   }
   update
}

#------------------------------------------------------------
# Explore
# Commande du bouton 'Recherche supernovae'
#------------------------------------------------------------
proc ::sn_tarot::Explore { } {
   global audace caption rep

   if { $rep(list_archives) ne "" } {
      ::sn_tarot::confTarotVisu
   } else {
      tk_messageBox -title $caption(sn_tarot_go,attention) -icon error \
         -type ok -message $caption(sn_tarot_go,nozip_error)
   }
}

#------------------------------------------------------------
# listArchives
#    Liste les fichiers du dossier archives, en excluant refgaltarot
# Liee lancee a createPanel et confirmTelecharge
#------------------------------------------------------------
proc ::sn_tarot::listArchives { } {
   global audace panneau rep snconfvisu

   #--   liste le contenu du dossier archives ; masque l'extension .zip
   regsub -all ".zip" [ glob -nocomplain -type f -tails -dir $rep(archives) *.zip ] "" list_archives
   #--   masque refgaltarot et dss
   regsub "refgalzadko" $list_archives "" list_archives
   regsub "refgaltarot" $list_archives "" list_archives
   regsub "dss" $list_archives "" list_archives

   #--   trie les dates par ordre decroissant
   set rep(list_archives) [ lsort -decreasing $list_archives ]

   #--   met à jour la liste de 'Rechercher Supernovae'
   if { [ winfo exists $audace(base).snvisu.fr5.select ] == 1 } {
      #--   met à jour la liste de 'Rechercher Supernovae'
      $audace(base).snvisu.fr5.select configure -values $rep(list_archives)
      #-- positionne la combobox sur le fichier
      regsub -all ".zip" $panneau(sn_tarot,file_zip) "" snconfvisu(night)
   }
}

#------  Mise a jour et verification des donnees -------------------------------

#-----------------------------------------------------
#  updateFiles
#     widget de mise a jour, lance par createPanel
#-----------------------------------------------------
proc ::sn_tarot::updateFiles { } {
   global audace caption conf panneau
   
   #--   raccourci
   set fram $audace(base).sn_tarot0

   if { [ winfo exists $fram ] } {
      destroy $fram
   }

   #--- Create the toplevel window .sn_tarot0
   #--- Cree la fenetre .snvisu_3 de niveau le plus haut
   toplevel $fram -class Toplevel
   wm title $fram $caption(sn_tarot_go,init)
   wm geometry $fram "+20+150"
   wm resizable $fram 0 0
   wm transient $fram $audace(base)
   wm protocol $fram WM_DELETE_WINDOW "destroy $fram"

   #--- Cree l'etiquette et les radiobuttons
   frame $fram.dat -borderwidth 2 -relief raised
   pack $fram.dat

   set i 0
   label $fram.dat.wait -text $caption(sn_tarot_go,wait)
   grid $fram.dat.wait -row $i -column 0 -padx 10 -sticky w
   incr i

   set dir "$panneau(init_dir)"
   set subdir [ file join $dir references ]
   set dssdir [ file join $dir dss ]
   set subdir_zadko [ file join $dir references_zadko ]
   set dssdir_zadko [ file join $dir dss_zadko ]
   #
   set list_of_data [ list folder folder "$dir" calern available "Tarot_Calern" \
      chili available "Tarot_Chili" ref ref refgaltarot.zip \
      refunzip refunzip "$subdir" dss dss dss.zip dssunzip dssunzip "$dssdir" ]
   #
   set list_of_data ""   
   lappend list_of_data folder 
   lappend list_of_data folder 
   lappend list_of_data "$dir"
   lappend list_of_data calern
   lappend list_of_data available
   lappend list_of_data "Tarot_Calern"
   lappend list_of_data chili
   lappend list_of_data available
   lappend list_of_data "Tarot_Chili"
   lappend list_of_data ref
   lappend list_of_data ref
   lappend list_of_data refgaltarot.zip
   lappend list_of_data refunzip
   lappend list_of_data refunzip
   lappend list_of_data "$subdir"
   lappend list_of_data dss
   lappend list_of_data dss
   lappend list_of_data dss.zip
   lappend list_of_data dssunzip
   lappend list_of_data dssunzip
   lappend list_of_data "$dssdir"
   if {$audace(sn_tarot,ok_zadko)==1} {
      lappend list_of_data zadko
      lappend list_of_data available
      lappend list_of_data "Zadko_Australia"
      lappend list_of_data refzadko
      lappend list_of_data ref
      lappend list_of_data refgalzadko.zip
      lappend list_of_data refzadkounzip
      lappend list_of_data refunzip
      lappend list_of_data "$subdir_zadko"
      lappend list_of_data dsszadko
      lappend list_of_data dss
      lappend list_of_data dss_zadko.zip
      lappend list_of_data dsszadkounzip
      lappend list_of_data dssunzip
      lappend list_of_data "$dssdir_zadko"
   }
   #
      
   foreach { child lab val } $list_of_data {
      checkbutton $fram.dat.$child -text [ format $caption(sn_tarot_go,$lab) $val ] \
         -indicatoron 1 -onvalue 1 -offvalue 0 -state disabled \
         -variable panneau(sn_tarot,ini_$child)
      grid $fram.dat.$child -row $i -column 0 -padx 10 -sticky w
      incr i
   }

   frame $fram.cmd -borderwidth 2 -relief raised
   pack $fram.cmd -fill x

   #--- Create the button 'GO', 'Cancel' and 'Help'
   #--- Cree le bouton 'GO', 'Annuler' and 'Aide'
   foreach { lab cmd } [ list go "::sn_tarot::sn_tarotStart" \
      cancel "destroy $audace(base).sn_tarot0" hlp "::sn_tarot::snHelp" ] {
      button $fram.cmd.but_$lab -text $caption(sn_tarot_go,$lab) \
        -borderwidth 2 -width 8 -command $cmd
      pack $fram.cmd.but_$lab -anchor w -padx 5 -pady 5 -side right
   }
   pack configure $fram.cmd.but_go -side left

   #--- La fenetre est active
   focus $fram.cmd.but_cancel

   #--- Mise a jour dynamique des couleurs
   ::confColor::applyColor $fram
}

#-----------------------------------------------------
#  sn_tarotStart
#     Execute les operations d'initialisation/mise a jour
#  Commande du bouton 'Go' de la fenetre 'Mise a jour'
#-----------------------------------------------------
proc ::sn_tarot::sn_tarotStart { } {
   global audace conf panneau rep

   ::sn_tarot::changeUpdateState disabled

   #--   cree les repertoires s'ils n'existent pas
   set dir $panneau(init_dir)
   set ls [ list archives night dss ]
   if {$audace(sn_tarot,ok_zadko)==1} {
      lappend ls references_zadko
      lappend ls dss_zadko
   }
   foreach sub_path $ls {
      set rep($sub_path) [ file join $dir $sub_path ]
      if { ![ file exists $rep($sub_path) ] } {
         file mkdir $rep($sub_path)
      }
   }

   set panneau(sn_tarot,ini_folder) 1
   update

   #--
   set ls ""
   lappend ls "Tarot_Calern"    ; lappend ls "$panneau(sn_tarot,Tarot_Calern,url)" ; lappend ls calern
   lappend ls "Tarot_Chili"     ; lappend ls "$panneau(sn_tarot,Tarot_Chili,url)" ; lappend ls chili
   if {$audace(sn_tarot,ok_zadko)==1} {
      lappend ls "Zadko_Australia" ; lappend ls "$panneau(sn_tarot,Zadko_Australia,url)" ; lappend ls zadko
   }
   foreach { prefix url var } $ls {
      ::sn_tarot::inventaire $prefix $url
      set panneau(sn_tarot,ini_$var) 1
      update
   }

   #--   si necessaire, telecharge refgaltarot.zip dans archives
   set file [ file join $rep(archives) refgaltarot.zip ]
   if { ![ file exists $file ] } {
      ::sn_tarot::downloadFile $panneau(sn_tarot,ohp,url) refgaltarot.zip $file
   }
   set panneau(sn_tarot,ini_ref) 1
   update

   #--   si necessaire, dezippe refgaltarot.zip
   set panneau(sn_tarot,references) [ file join $dir references ]

   set nb [ llength [ glob -nocomplain -type f -tails -dir $panneau(sn_tarot,references) *$conf(extension,defaut) ] ]
   if { $nb == 0 } {
      #--   chemin de unzip.exe
      if { $::tcl_platform(os) == "Linux" } {
         set tarot_unzip unzip
      } else {
         set tarot_unzip [ file join $audace(rep_plugin) tool sn_tarot unzip.exe ]
      }
      #--   dezippe refgaltarot.zip
      catch { exec $tarot_unzip -u -d $dir $file } ErrInfo

      #--   change le nom du repertoire en reference
      if {![file exists $panneau(sn_tarot,references)] && [ file exists [ file join $dir refgaltarot ] ] } {
         file rename -force [ file join $dir refgaltarot ] $panneau(sn_tarot,references)
      }
   }
   set panneau(sn_tarot,ini_refunzip) 1
   update

   #--   si necessaire, telecharge dss.zip dans archives
   set file [ file join $rep(archives) dss.zip ]
   if { ![ file exists $file ] } {
      ::sn_tarot::downloadFile $panneau(sn_tarot,ohp,url) dss.zip $file
   }
   set panneau(sn_tarot,ini_ref) 1
   update

   #--   si necessaire, dezippe dss.zip
   set panneau(sn_tarot,dss) [ file join $dir .. dss ]

   set nb [ llength [ glob -nocomplain -type f -tails -dir $panneau(sn_tarot,dss) *$conf(extension,defaut) ] ]
   if { $nb == 0 } {
      #--   chemin de unzip.exe
      if { $::tcl_platform(os) == "Linux" } {
         set tarot_unzip unzip
      } else {
         set tarot_unzip [ file join $audace(rep_plugin) tool sn_tarot unzip.exe ]
      }
      #--   dezippe dss.zip
      catch { exec $tarot_unzip -u -d $dir $file } ErrInfo

   }
   #set panneau(sn_tarot,ini_refunzip) 1
   update
   
   if {$audace(sn_tarot,ok_zadko)==1} {

      #--   si necessaire, telecharge refgalzadko.zip dans archives
      set file [ file join $rep(archives) refgalzadko.zip ]
      if { ![ file exists $file ] } {
         ::sn_tarot::downloadFile $panneau(sn_tarot,ohp,url) refgalzadko.zip $file
      }
      set panneau(sn_tarot,ini_ref) 1
      update

      #--   si necessaire, dezippe refgaltarot.zip
      set panneau(sn_tarot,references_zadko) [ file join $dir references_zadko ]

      set nb [ llength [ glob -nocomplain -type f -tails -dir $panneau(sn_tarot,references_zadko) *$conf(extension,defaut) ] ]
      if { $nb == 0 } {
         #--   chemin de unzip.exe
         if { $::tcl_platform(os) == "Linux" } {
            set tarot_unzip unzip
         } else {
            set tarot_unzip [ file join $audace(rep_plugin) tool sn_tarot unzip.exe ]
         }
         #--   dezippe refgaltarot.zip
         catch { exec $tarot_unzip -u -d $dir $file } ErrInfo

         #--   change le nom du repertoire en reference
         if {![file exists $panneau(sn_tarot,references_zadko)] && [ file exists [ file join $dir refgalzadko ] ] } {
            file rename -force [ file join $dir refgalzadko ] $panneau(sn_tarot,references_zadko)
         }
      }
      set panneau(sn_tarot,ini_refunzip) 1
      update

      #--   si necessaire, telecharge dss_zadko.zip dans archives
      set file [ file join $rep(archives) dss_zadko.zip ]
      if { ![ file exists $file ] } {
         ::sn_tarot::downloadFile $panneau(sn_tarot,ohp,url) dss_zadko.zip $file
      }
      set panneau(sn_tarot,ini_ref) 1
      update

      #--   si necessaire, dezippe dss_zadko.zip
      set panneau(sn_tarot,dss_zadko) [ file join $dir .. dss ]

      set nb [ llength [ glob -nocomplain -type f -tails -dir $panneau(sn_tarot,dss_zadko) *$conf(extension,defaut) ] ]
      if { $nb == 0 } {
         #--   chemin de unzip.exe
         if { $::tcl_platform(os) == "Linux" } {
            set tarot_unzip unzip
         } else {
            set tarot_unzip [ file join $audace(rep_plugin) tool sn_tarot unzip.exe ]
         }
         #--   dezippe dss.zip
         catch { exec $tarot_unzip -u -d $dir $file } ErrInfo

      }
      update
      
   }

   ::sn_tarot::changeUpdateState normal

   #--   ferme la fenetre
   destroy $audace(base).sn_tarot0

   #--   detruit les variables liees a $audace(base).sn_tarot0
   unset panneau(sn_tarot,ini_folder) panneau(sn_tarot,ini_calern) \
      panneau(sn_tarot,ini_chili) panneau(sn_tarot,ini_ref) \
      panneau(sn_tarot,ini_refunzip)

   set panneau(sn_tarot,init) 1
}

#------------------------------------------------------------
# changeUpdateState
#     Inhibe/Desinhibe les widgets du panneau de 'Mise a jour'
# Liee a updateFiles
#------------------------------------------------------------
proc ::sn_tarot::changeUpdateState { state } {
   global audace

   #--   raccourci
   set fram $audace(base).sn_tarot0

   #--   inhibition des widgets
   regsub "$fram.dat.wait" [ winfo children $fram.dat ] "" children
   set children [ concat $children [ winfo children $fram.cmd ] ]
   foreach child $children {
       $child configure -state $state
   }
   update
}

#------------------------------------------------------------
# inventaire
#     Liste les 100 fichiers zip les plus recents
# exemple ::sn_tarot::inventaire Tarot_Chili "http://tarotchili5.oamp.fr/ros/supernovae/zip"
#------------------------------------------------------------
proc ::sn_tarot::inventaire { prefix url } {
   global panneau caption rep

   #--   cree la liste des dates specifique a chaque telescope
   lassign [ ::sn_tarot::httpcopy $prefix $url ] error list_zip
   
   set typetel [lindex [split $prefix _] 0]

   if { $error eq "0" } {

      #--   si connexion reussie
      switch -exact $prefix {
         Tarot_Calern {set home {GPS 6.92353 E 43.75203 1320} }
         Tarot_Chili  {set home {GPS 70.7326 W -29.259917 2398} }
         Zadko_Australia {set home {GPS 115.7140 E -31.3567 50} }
      }

      #--   recherche la date courante et le creneau horaire
      lassign [ ::sn_tarot::prevnight $home ] date day_night

      #--   si la premiere date est la date courante et day_night == Night
      set old [ lindex $list_zip 0 ]_old
      if { [ lindex $list_zip 0 ] > $date && $day_night eq "Night" } {
         #--   propose $date_old.zip au chargement
         set list_zip [ lreplace $list_zip 0 0 $old ]
      } elseif { [ lindex $list_zip 0 ] > $date && $day_night ne "Night" } {
         set file [ file join $rep(archives) $old ]
         if { [ file exists $file ] == 1 } {
            #--   efface le fichier _old dans le fichier archives
            file delete $file
         }
      }

   } else {

      #--   si echec de connexion au site, liste le contenu du dossier archives
      #--   masque refgaltarot
      set repref refgaltarot
      if {$typetel=="Zadko"} {
         set repref refgalzadko
      }
      regsub -all "$repref" [ glob -nocomplain -type f -dir $rep(archives) -tails *.zip ] "" list_archives
      foreach archive $list_archives {
         regexp "${prefix}_(\[0-9\]\{8\})\.zip" $archive match date
         if { [ info exists date ] } {
            lappend list_zip $date
            unset date
         }
      }
      #--   trie la liste par ordre decroissant et garde les 100 premiers
      set list_zip [ lrange [ lsort -decreasing $list_zip ] 0 99 ]

  }

  set panneau(sn_tarot,$prefix) $list_zip
}

