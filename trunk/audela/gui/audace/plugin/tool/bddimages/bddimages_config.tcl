#--------------------------------------------------
# source audace/plugin/tool/bddimages/bddimages_config.tcl
#--------------------------------------------------
#
# Fichier        : bddimages_config.tcl
# Description    : Configuration des variables globales bddconf
#                  necessaires au service
# Auteur         : Frédéric Vachier
# Mise à jour $Id$
#
#--------------------------------------------------
#
# - namespace bddimages_config
#
#--------------------------------------------------
#
#   -- Fichiers source externe :
#
#  bddimages_config.cap
#
#--------------------------------------------------

namespace eval bddimages_config {
   
   package require bddimagesXML 1.0
   package require bddimagesAdmin 1.0

   global audace
   global bddconf

   # Tous les parametres de configuration
   set allparams { sauve_xml dbname login pass server dirbase dirinco dirfits dircata direrr dirlog dirtmp limit intellilists }

   #--- Chargement des captions
   uplevel #0 "source \"[ file join $audace(rep_plugin) tool bddimages bddimages_config.cap ]\""

   #--------------------------------------------------
   # run { this }
   #--------------------------------------------------
   #
   #    fonction  :
   #        Cree la fenetre de tests
   #
   #    procedure externe :
   #
   #    variables en entree :
   #        this = chemin de la fenetre
   #
   #    variables en sortie :
   #
   proc run { this } {
      variable This

      set This $this
      createDialog
   }

   #--------------------------------------------------
   # fermer { }
   #--------------------------------------------------
   #
   #    fonction  :
   #        Fonction appellee lors de l'appui
   #        sur le bouton 'Fermer'
   #
   #    procedure externe :
   #
   #    variables en entree :
   #
   #    variables en sortie :
   #
   #--------------------------------------------------
   proc fermer { } {
      variable This
      global audace
      global bddconf
      
      # Config courante
      if { ![info exists bddconf(default_config)] } {
         #--- Charge les config bddimages depuis le fichier XML
         set err [::bddimagesXML::load_xml_config]
         #--- et recupere la config par defaut
         set bddconf(current_config) $::bddimagesXML::current_config
      } else {
         # Charge la config par defaut
         set bddconf(current_config) [::bddimagesXML::get_config $bddconf(default_config)]
      }

      #--- Mise en forme du resultat
      set errconn [catch {::bddimages_sql::connect} connectstatus]
      if { $errconn } {
         ::console::affiche_erreur "Connexion echouee : $connectstatus\n"
      } else {
         ::console::affiche_resultat "Connexion reussie : $connectstatus\n"
      }

      if {[info exists bddconf(dirfits)]} {
         set  audace(rep_images)  $bddconf(dirfits)
      }
      if {[info exists bddconf(dirtmp)]} {
         set  audace(rep_travail)  $bddconf(dirtmp)
      }

      ::bddimages_config::recup_position
      destroy $This
   }

   #--------------------------------------------------
   #  save { }
   #--------------------------------------------------
   #
   #    fonction  :
   #       Fonction appellee lors de l'appui
   #       sur le bouton 'Sauver'
   #
   #    procedure externe :
   #
   #    variables en entree :
   #
   #    variables en sortie :
   #
   #--------------------------------------------------
   proc save { } {
      variable This
      global audace
      global conf
      global bddconf
      variable allparams

      # Sauve les preferences bddimages dans audela.ini
      foreach param $allparams {
        set conf(bddimages,$param) $bddconf($param)
      }

      # Defini la structure de la config courante a partir des champs de saisie
      ::bddimagesXML::set_config $bddconf(current_config)
      # Defini et charge la config par defaut comme etant la config courante
      set bddconf(default_config) [::bddimagesXML::get_config $bddconf(current_config)]
      # Sauve le fichiers XML si demande
      if {$bddconf(sauve_xml) == 1} {
         # Defini la config par defaut
         set ::bddimagesXML::default_config $bddconf(default_config) 
         # Enregistre la config
         ::bddimagesXML::save_xml_config 
      }

      # Config courante
      if { ![info exists bddconf(default_config)] } {
         #--- Charge les config bddimages depuis le fichier XML
         set err [::bddimagesXML::load_xml_config]
         #--- et recupere la config par defaut
         set bddconf(current_config) $::bddimagesXML::current_config
      } else {
         # Charge la config par defaut
         set bddconf(current_config) [::bddimagesXML::get_config $bddconf(default_config)]
      }

      #--- Mise en forme du resultat
      set errconn [catch {::bddimages_sql::connect} connectstatus]
      if { $errconn } {
         ::console::affiche_erreur "Connexion echouee : $connectstatus\n"
      } else {
         ::console::affiche_resultat "Connexion reussie : $connectstatus\n"
      }



      if {[info exists bddconf(dirfits)]} {
         set  audace(rep_images)  $bddconf(dirfits)
      }
      if {[info exists bddconf(dirtmp)]} {
         set  audace(rep_travail)  $bddconf(dirtmp)
      }


      # Fin
      ::bddimages_config::recup_position
      destroy $This
   }

   #--------------------------------------------------
   #  recup_position { }
   #--------------------------------------------------
   #
   #    fonction  :
   #       Permet de recuperer et de sauvegarder
   #       la position de la fenetre
   #
   #    procedure externe :
   #
   #    variables en entree :
   #
   #    variables en sortie :
   #
   #--------------------------------------------------
   proc recup_position { } {
      variable This
      global audace
      global conf
      global bddconf

      set bddconf(geometry_config) [ wm geometry $This ]
      set conf(bddimages,geometry_config) $bddconf(geometry_config)
      return
   }

   #--------------------------------------------------
   # getDir { }
   #--------------------------------------------------
   # Recupere le nom d'un repertoire choisi par l'utilisateur
   # @param path repertoire de base
   # @param title titre a donner a la fenetre
   # @return nom du repertoire selectionne ou une erreur (code 1)
   #--------------------------------------------------
   proc getDir { {path ""} {title ""} } {

      variable This
      global audace
      global caption

      # Defini un repertoire de base -> rep_images
      set initDir $audace(rep_images)
      if {[info exists path]} { set initDir $path }

      # Ouvre la fenetre de choix des repertoires
      set title [concat $caption(bddimages_config,getdir) $title]
      set workDir [tk_chooseDirectory -title $title -initialdir $initDir -parent $This]

      # Extraction et chargement du fichier
      if { $workDir != "" } {
        return $workDir
      } else {
        return -code error 
      }
   }

   #--------------------------------------------------
   # checkOtherDir { base }
   #--------------------------------------------------
   # Essaye de recuperer le nom des repertoires de travail 
   # a partir du repertoire de base
   # @param base le repertoire de base
   # @return void
   #--------------------------------------------------
   proc checkOtherDir { base } {
      global bddconf
      
      # Liste des repertoires a chercher
      set listD [list "cata" "fits" "incoming" "error" "log" "tmp"]
      # Defini un repertoire de base -> rep_images
      foreach d $listD {
         if {[file isdirectory [file join $base $d]]} { 
            switch $d {
               "cata"     { set bddconf(dircata) [file join $base $d] }
               "fits"     { set bddconf(dirfits) [file join $base $d] }
               "incoming" { set bddconf(dirinco) [file join $base $d] }
               "error"    { set bddconf(direrr)  [file join $base $d] }
               "log"      { set bddconf(dirlog)  [file join $base $d] }
               "tmp"      { set bddconf(dirtmp)  [file join $base $d] }
            }
         }
      }
      return 0
   }

   #--------------------------------------------------
   #  GetInfo { }
   #--------------------------------------------------
   # Affichage d'un message sur le format d'une saisie pour un 
   # element de la structure de config XML de bddimages
   # @param subject le sujet a documenter
   # @return void
   #--------------------------------------------------
   proc ::bddimages_config::GetInfo { subject } {
      global caption
      global voconf
      switch $subject {
         dbname    { set msg $caption(bddimages_config,info_dbname) }
         login     { set msg $caption(bddimages_config,info_login) }
         passwd    { set msg $caption(bddimages_config,info_passwd) }
         host      { set msg $caption(bddimages_config,info_host) }
         dir_base  { set msg $caption(bddimages_config,info_dirbase) }
         dir_inco  { set msg $caption(bddimages_config,info_dirinco) }
         dir_fits  { set msg $caption(bddimages_config,info_dirfits) }
         dir_cata  { set msg $caption(bddimages_config,info_dircata) }
         dir_err   { set msg $caption(bddimages_config,info_direrr) }
         dir_log   { set msg $caption(bddimages_config,info_dirlog) }
         dir_tmp   { set msg $caption(bddimages_config,info_dirtmp) }
         listlimit { set msg $caption(bddimages_config,info_listlimit) }
      }
      tk_messageBox -title $caption(bddimages_config,info_title) -type ok -message $msg
      return -code 0
   }

   #--------------------------------------------------
   #  createDialog { }
   #--------------------------------------------------
   #
   #    fonction  :
   #       Creation de l'interface graphique
   #
   #    procedure externe :
   #
   #    variables en entree :
   #
   #    variables en sortie :
   #
   #--------------------------------------------------
   proc createDialog { } {
      variable This
      global audace
      global caption
      global color
      global conf
      global bddconf
      variable allparams
      global myconf
      global rbconfig
      
      #--- initConf
      if { ! [ info exists conf(bddimages,geometry_config) ] } { set conf(bddimages,geometry_config) "+100+100" }
      set bddconf(geometry_config) $conf(bddimages,geometry_config)

      #--- Affecte les variables depuis les valeurs de la conf
      foreach param $allparams {
         if {[info exists conf(bddimages,$param)]} {
            set bddconf($param) $conf(bddimages,$param)
         } else { 
            set bddconf($param) "" 
         }
      }
      #--- Force a 1 le choix bddconf(sauve_xml) si non defini
      if { [string equal $bddconf(sauve_xml) ""] } { set bddconf(sauve_xml) 1 }

      #---
      if { [ winfo exists $This ] } {
         wm withdraw $This
         wm deiconify $This
         focus $This.frame11.but_fermer
         return
      }

      #---
      if { [ info exists bddconf(geometry_status) ] } {
         set deb [ expr 1 + [ string first + $bddconf(geometry_status) ] ]
         set fin [ string length $bddconf(geometry_status) ]
         set bddconf(position_status) "+[ string range $bddconf(geometry_status) $deb $fin ]"
      }

      # Charge les config bddimages depuis le fichier XML
      set err [::bddimagesXML::load_xml_config]
      # Recupere la liste des bddimages disponibles
      set bddconf(list_config) $::bddimagesXML::list_bddimages
      # Recupere la config par defaut [liste id name]
      set bddconf(default_config) $::bddimagesXML::default_config
      # Recupere la config par courante [liste id name]
      set bddconf(current_config) $::bddimagesXML::current_config

      #---
      toplevel $This -class Toplevel
      wm geometry $This $bddconf(geometry_config)
      wm resizable $This 1 1
      wm title $This $caption(bddimages_config,main_title)
      wm protocol $This WM_DELETE_WINDOW { ::bddimages_config::fermer }

         #--- Cree un frame pour la liste des bddimages de l'utilisateur
         frame $This.conf -borderwidth 1 -relief groove
         pack $This.conf -in $This -anchor w -side top -expand 0 -fill x -padx 10 -pady 5

          #--- Cree un frame pour le titre et le menu deroulant
          frame $This.conf.m -borderwidth 0 -relief solid
          pack $This.conf.m -in $This.conf -anchor w -side top -expand 0 -fill both -padx 3 -pady 0
 
             #--- Cree un label pour le titre
             label $This.conf.m.titre -text "$caption(bddimages_config,titleconfig)" -borderwidth 0 -relief flat
             pack $This.conf.m.titre -in $This.conf.m -side left -anchor w -padx 3 -pady 3
             #--- Cree un menu bouton pour choisir la config
             menubutton $This.conf.m.menu -relief raised -borderwidth 2 -textvariable bddconf(current_config) -menu $This.conf.m.menu.list
             set rbconfig [menu $This.conf.m.menu.list -tearoff "1"]
             foreach myconf $bddconf(list_config) {
                $rbconfig add radiobutton -label [lindex "$myconf" 1] -value [lindex "$myconf" 1] -variable bddconf(current_config) \
                    -command { set bddconf(current_config) [::bddimagesXML::get_config $bddconf(current_config)] }
             }
             pack $This.conf.m.menu -in $This.conf.m -side left -anchor w -padx 3 -pady 3
             #--- Cree un bouton + pour ajouter une config
             button $This.conf.m.operationP -state active -text "+" \
                -command { 
                   set new_config [::bddimagesXML::add_config]
                   set bddconf(current_config) [::bddimagesXML::get_config $new_config]
                   set bddconf(list_config) $::bddimagesXML::list_bddimages
                   $rbconfig add radiobutton -label $bddconf(current_config) -value $bddconf(current_config) -variable bddconf(current_config) \
                      -command { set bddconf(current_config) [::bddimagesXML::get_config $bddconf(current_config)] }
                 }
             pack $This.conf.m.operationP -in $This.conf.m -side left -anchor w -padx 1
             #--- Cree un bouton - pour effacer la config courante
             button $This.conf.m.operationM -state active -text "-" \
                -command { 
                   if {[catch {::bddimagesXML::delete_config $bddconf(current_config)} new_config] == 0} {
                      $rbconfig delete $bddconf(current_config)
                      set bddconf(current_config) [::bddimagesXML::get_config $new_config]
                      set bddconf(list_config) $::bddimagesXML::list_bddimages
                   }
                 }
             pack $This.conf.m.operationM -in $This.conf.m -side left -anchor w -padx 1

          #--- Cree un checkbutton pour sauver le xml
          frame $This.conf.c -borderwidth 0 -relief solid
          pack $This.conf.c -in $This.conf -anchor w -side top -expand 0 -fill both -padx 3 -pady 0

             checkbutton $This.conf.c.sauve -indicatoron 1 -offvalue 0 -onvalue 1 \
                -variable bddconf(sauve_xml) -text "$::caption(bddimages_config,sauvexml)"
             pack $This.conf.c.sauve -in $This.conf.c -anchor w -side left -padx 3 -pady 1

         #--- Cree un frame pour les acces a la bdd
         frame $This.bdd -borderwidth 1 -relief groove
         pack $This.bdd -in $This -anchor w -side top -expand 0 -fill x -padx 10 -pady 5

          #--- Cree un label pour le titre
          label $This.bdd.titre -text "$caption(bddimages_config,access)" -borderwidth 0 -relief flat
          pack $This.bdd.titre -in $This.bdd -side top -anchor w -padx 3 -pady 3

          #--- Cree un frame pour le nom de la BDD
          frame $This.bdd.name -borderwidth 0 -relief solid
          pack $This.bdd.name -in $This.bdd -anchor w -side top -expand 0 -fill both -padx 3 -pady 0

            #--- Cree un label
            label $This.bdd.name.lab -text "$caption(bddimages_config,dbname)" -width 30 -anchor w -borderwidth 0 -relief flat
            pack $This.bdd.name.lab -in $This.bdd.name -side left -anchor w -padx 1
            #--- Cree une ligne d'entree pour la variable
            entry $This.bdd.name.dat -textvariable bddconf(dbname) -borderwidth 1 -relief groove -width 25 -justify left
            pack $This.bdd.name.dat -in $This.bdd.name -side left -anchor w -padx 1
            #--- Cree un bouton Create BDD
            button $This.bdd.name.test -state active -relief groove -anchor c -width 4 -text "Create" \
              -command { ::bddimagesAdmin::RAZBdd }
            pack $This.bdd.name.test -in $This.bdd.name -side left -anchor w -padx 1
            #--- Cree un bouton info
            button $This.bdd.name.help -state active -relief groove -anchor c \
                 -text "$caption(bddimages_config,info)" -command { ::bddimages_config::GetInfo "dbname" }
            pack $This.bdd.name.help -in $This.bdd.name -side left -anchor w -padx 1

          #--- Cree un frame pour le login
          frame $This.bdd.login -borderwidth 0 -relief solid
          pack $This.bdd.login -in $This.bdd -anchor w -side top -expand 0 -fill both -padx 3 -pady 0

            #--- Cree un label
            label $This.bdd.login.lab -text "$caption(bddimages_config,login)" -width 30 -anchor w -borderwidth 0 -relief flat
            pack $This.bdd.login.lab -in $This.bdd.login -side left -anchor w -padx 1
            #--- Cree une ligne d'entree pour la variable
            entry $This.bdd.login.dat -textvariable bddconf(login) -borderwidth 1 -relief groove -width 25 -justify left
            pack $This.bdd.login.dat -in $This.bdd.login -side left -anchor w -padx 1
            #--- Cree un bouton vide
            button $This.bdd.login.test -state disabled -relief flat -anchor c -width 4
            pack $This.bdd.login.test -in $This.bdd.login -side left -anchor w -padx 1
            #--- Cree un bouton info
            button $This.bdd.login.help -state active -relief groove -anchor c \
                 -text "$caption(bddimages_config,info)" -command { ::bddimages_config::GetInfo "login" }
            pack $This.bdd.login.help -in $This.bdd.login -side left -anchor w -padx 1

          #--- Cree un frame pour le mot de passe
          frame $This.bdd.pass -borderwidth 0 -relief flat
          pack $This.bdd.pass -in $This.bdd -anchor w -side top -expand 0 -fill both -padx 3 -pady 0

            #--- Cree un label
            label $This.bdd.pass.lab -text "$caption(bddimages_config,pass)" -width 30 -anchor w -borderwidth 0 -relief flat
            pack $This.bdd.pass.lab -in $This.bdd.pass -side left -anchor w -padx 1
            #--- Cree une ligne d'entree pour la variable
            entry $This.bdd.pass.dat -textvariable bddconf(pass) -borderwidth 1 -relief groove -width 25 -justify left -show "*"
            pack $This.bdd.pass.dat -in $This.bdd.pass -side left -anchor w -padx 1
            #--- Cree un bouton vide
            button $This.bdd.pass.test -state disabled -relief flat -anchor c -width 4
            pack $This.bdd.pass.test -in $This.bdd.pass -side left -anchor w -padx 1
            #--- Cree un bouton info
            button $This.bdd.pass.help -state active -relief groove -anchor c \
                 -text "$caption(bddimages_config,info)" -command { ::bddimages_config::GetInfo "passwd" }
            pack $This.bdd.pass.help -in $This.bdd.pass -side left -anchor w -padx 1

          #--- Cree un frame pour le serveur
          frame $This.bdd.serv -borderwidth 0 -relief flat
          pack $This.bdd.serv -in $This.bdd -anchor w -side top -expand 0 -fill both -padx 3 -pady 0

            #--- Cree un label
            label $This.bdd.serv.lab -text "$caption(bddimages_config,server)" -width 30 -anchor w -borderwidth 0 -relief flat
            pack $This.bdd.serv.lab -in $This.bdd.serv -side left -anchor w -padx 1
            #--- Cree une ligne d'entree pour la variable
            entry $This.bdd.serv.dat -textvariable bddconf(server) -borderwidth 1 -relief groove -width 25 -justify left
            pack $This.bdd.serv.dat -in $This.bdd.serv -side left -anchor w -padx 1
            #--- Cree un bouton Test BDD
            button $This.bdd.serv.test -state active -relief groove -anchor c -width 4 -text "Test" \
                 -command { set err [catch {::bddimagesAdmin::TestConnectBdd} status] }
            pack $This.bdd.serv.test -in $This.bdd.serv -side left -anchor w -padx 1
            #--- Cree un bouton info
            button $This.bdd.serv.help -state active -relief groove -anchor c \
                 -text "$caption(bddimages_config,info)" -command { ::bddimages_config::GetInfo "host" }
            pack $This.bdd.serv.help -in $This.bdd.serv -side left -anchor w -padx 1

 
 set widthlab 30
 set widthentry 60
 
 
 
        #--- Cree un frame pour les repertoires
        frame $This.dir -borderwidth 1 -relief groove
        pack $This.dir -in $This -anchor w -side top -expand 0 -fill x -padx 10 -pady 5

          #--- Cree un label pour le titre
          label $This.dir.titre -text "$caption(bddimages_config,dir)" -borderwidth 0 -relief flat
          pack $This.dir.titre -in $This.dir -side top -anchor w -padx 3 -pady 3

          #--- Cree un frame pour le repertoire de base
          frame $This.dir.dirbase -borderwidth 0 -relief flat
          pack $This.dir.dirbase -in $This.dir -anchor w -side top -expand 0 -fill both -padx 3 -pady 0

            #--- Cree un label
            label $This.dir.dirbase.lab -text "$caption(bddimages_config,dirbase)" -width $widthlab -anchor w -borderwidth 0 -relief flat
            pack $This.dir.dirbase.lab -in $This.dir.dirbase -side left -anchor w -padx 1
            #--- Cree une ligne d'entree pour la variable
            entry $This.dir.dirbase.dat -textvariable bddconf(dirbase) -borderwidth 1 -relief groove -width $widthentry -justify left
            pack $This.dir.dirbase.dat -in $This.dir.dirbase -side left -anchor w -padx 1
            #--- Cree un bouton charger
            button $This.dir.dirbase.explore -text "..." -width 3 \
               -command {
                  if {! [catch {::bddimages_config::getDir $bddconf(dirbase) "de base"} wdir]} {
                     set bddconf(dirbase) $wdir 
                     ::bddimages_config::checkOtherDir $bddconf(dirbase)
                  }
               }
            pack $This.dir.dirbase.explore -in $This.dir.dirbase -side left -anchor c -fill x -padx 6
            #--- Cree un bouton info
            button $This.dir.dirbase.help -state active -relief groove -anchor c \
                    -text "$caption(bddimages_config,info)" -command { ::bddimages_config::GetInfo "dir_base" }
            pack $This.dir.dirbase.help -in $This.dir.dirbase -side left -anchor w -padx 1

          #--- Cree un frame pour le repertoire incoming
          frame $This.dir.dirinco -borderwidth 0 -relief flat
          pack $This.dir.dirinco -in $This.dir -anchor w -side top -expand 0 -fill both -padx 3 -pady 0

            #--- Cree un label
            label $This.dir.dirinco.lab -text "$caption(bddimages_config,dirinco)" -width $widthlab -anchor w -borderwidth 0 -relief flat
            pack $This.dir.dirinco.lab -in $This.dir.dirinco -side left -anchor w -padx 1
            #--- Cree une ligne d'entree pour la variable
            entry $This.dir.dirinco.dat -textvariable bddconf(dirinco) -borderwidth 1 -relief groove -width $widthentry -justify left
            pack $This.dir.dirinco.dat -in $This.dir.dirinco -side left -anchor w -padx 1
            #--- Cree un bouton charger
            button $This.dir.dirinco.explore -text "..." -width 3 \
               -command { 
                  if {! [catch {::bddimages_config::getDir $bddconf(dirbase) "d'incoming"} wdir]} {
                     set bddconf(dirinco) $wdir
                  }
               }
            pack $This.dir.dirinco.explore -in $This.dir.dirinco -side left -anchor c -fill x -padx 6
            #--- Cree un bouton info
            button $This.dir.dirinco.help -state active -relief groove -anchor c \
                    -text "$caption(bddimages_config,info)" -command { ::bddimages_config::GetInfo "dir_inco" }
            pack $This.dir.dirinco.help -in $This.dir.dirinco -side left -anchor w -padx 1

          #--- Cree un frame pour le repertoire fits
          frame $This.dir.dirfits -borderwidth 0 -relief flat
          pack $This.dir.dirfits -in $This.dir -anchor w -side top -expand 0 -fill both -padx 3 -pady 0

            #--- Cree un label
            label $This.dir.dirfits.lab -text "$caption(bddimages_config,dirfits)" -width $widthlab -anchor w -borderwidth 0 -relief flat
            pack $This.dir.dirfits.lab -in $This.dir.dirfits -side left -anchor w -padx 1
            #--- Cree une ligne d'entree pour la variable
            entry $This.dir.dirfits.dat -textvariable bddconf(dirfits) -borderwidth 1 -relief groove -width $widthentry -justify left
            pack $This.dir.dirfits.dat -in $This.dir.dirfits -side left -anchor w -padx 1
            #--- Cree un bouton charger
            button $This.dir.dirfits.explore -text "..." -width 3 \
               -command { 
                  if {! [catch {::bddimages_config::getDir $bddconf(dirbase) "des images FITS"} wdir]} {
                     set bddconf(dirfits) $wdir
                  }
               }
            pack $This.dir.dirfits.explore -in $This.dir.dirfits -side left -anchor c -fill x -padx 6
            #--- Cree un bouton info
            button $This.dir.dirfits.help -state active -relief groove -anchor c \
                    -text "$caption(bddimages_config,info)" -command { ::bddimages_config::GetInfo "dir_fits" }
            pack $This.dir.dirfits.help -in $This.dir.dirfits -side left -anchor w -padx 1

          #--- Cree un frame pour le repertoire cata
          frame $This.dir.dircata -borderwidth 0 -relief flat
          pack $This.dir.dircata -in $This.dir -anchor w -side top -expand 0 -fill both -padx 3 -pady 0

            #--- Cree un label
            label $This.dir.dircata.lab -text "$caption(bddimages_config,dircata)" -width $widthlab -anchor w -borderwidth 0 -relief flat
            pack $This.dir.dircata.lab -in $This.dir.dircata -side left -anchor w -padx 1
            #--- Cree une ligne d'entree pour la variable
            entry $This.dir.dircata.dat -textvariable bddconf(dircata) -borderwidth 1 -relief groove -width $widthentry -justify left
            pack $This.dir.dircata.dat -in $This.dir.dircata -side left -anchor w -padx 1
            #--- Cree un bouton charger
            button $This.dir.dircata.explore -text "..." -width 3 \
               -command { 
                  if {! [catch {::bddimages_config::getDir $bddconf(dirbase) "des CATA"} wdir]} {
                     set bddconf(dircata) $wdir
                  }
               }
            pack $This.dir.dircata.explore -in $This.dir.dircata -side left -anchor c -fill x -padx 6
            #--- Cree un bouton info
            button $This.dir.dircata.help -state active -relief groove -anchor c \
                    -text "$caption(bddimages_config,info)" -command { ::bddimages_config::GetInfo "dir_cata" }
            pack $This.dir.dircata.help -in $This.dir.dircata -side left -anchor w -padx 1

          #--- Cree un frame pour le repertoire d erreur
          frame $This.dir.direrr -borderwidth 0 -relief flat
          pack $This.dir.direrr -in $This.dir -anchor w -side top -expand 0 -fill both -padx 3 -pady 0

            #--- Cree un label
            label $This.dir.direrr.lab -text "$caption(bddimages_config,direrr)" -width $widthlab -anchor w -borderwidth 0 -relief flat
            pack $This.dir.direrr.lab -in $This.dir.direrr -side left -anchor w -padx 1
            #--- Cree une ligne d'entree pour la variable
            entry $This.dir.direrr.dat -textvariable bddconf(direrr) -borderwidth 1 -relief groove -width $widthentry -justify left
            pack $This.dir.direrr.dat -in $This.dir.direrr -side left -anchor w -padx 1
            #--- Cree un bouton charger
            button $This.dir.direrr.explore -text "..." -width 3 \
               -command { 
                  if {! [catch {::bddimages_config::getDir $bddconf(dirbase) "des erreurs"} wdir]} {
                     set bddconf(direrr) $wdir
                  }
               }
            pack $This.dir.direrr.explore -in $This.dir.direrr -side left -anchor c -fill x -padx 6
            #--- Cree un bouton info
            button $This.dir.direrr.help -state active -relief groove -anchor c \
                    -text "$caption(bddimages_config,info)" -command { ::bddimages_config::GetInfo "dir_err" }
            pack $This.dir.direrr.help -in $This.dir.direrr -side left -anchor w -padx 1

          #--- Cree un frame pour le repertoire de log
          frame $This.dir.dirlog -borderwidth 0 -relief flat
          pack $This.dir.dirlog -in $This.dir -anchor w -side top -expand 0 -fill both -padx 3 -pady 0

            #--- Cree un label
            label $This.dir.dirlog.lab -text "$caption(bddimages_config,dirlog)" -width $widthlab -anchor w -borderwidth 0 -relief flat
            pack $This.dir.dirlog.lab -in $This.dir.dirlog -side left -anchor w -padx 1
            #--- Cree une ligne d'entree pour la variable
            entry $This.dir.dirlog.dat -textvariable bddconf(dirlog) -borderwidth 1 -relief groove -width $widthentry -justify left
            pack $This.dir.dirlog.dat -in $This.dir.dirlog -side left -anchor w -padx 1
            #--- Cree un bouton charger
            button $This.dir.dirlog.explore -text "..." -width 3 \
               -command { 
                  if {! [catch {::bddimages_config::getDir $bddconf(dirbase) "de log"} wdir]} {
                     set bddconf(dirlog) $wdir
                  }
               }
            pack $This.dir.dirlog.explore -in $This.dir.dirlog -side left -anchor c -fill x -padx 6
            #--- Cree un bouton info
            button $This.dir.dirlog.help -state active -relief groove -anchor c \
                    -text "$caption(bddimages_config,info)" -command { ::bddimages_config::GetInfo "dir_log" }
            pack $This.dir.dirlog.help -in $This.dir.dirlog -side left -anchor w -padx 1

   
   
   
   
          #--- Cree un frame pour le repertoire tmp
          frame $This.dir.dirtmp -borderwidth 0 -relief flat
          pack $This.dir.dirtmp -in $This.dir -anchor w -side top -expand 0 -fill both -padx 3 -pady 0

            #--- Cree un label
            label $This.dir.dirtmp.lab -text "$caption(bddimages_config,dirtmp)" -width $widthlab -anchor w -borderwidth 0 -relief flat
            pack $This.dir.dirtmp.lab -in $This.dir.dirtmp -side left -anchor w -padx 1
            #--- Cree une ligne d'entree pour la variable
            entry $This.dir.dirtmp.dat -textvariable bddconf(dirtmp) -borderwidth 1 -relief groove -width $widthentry -justify left
            pack $This.dir.dirtmp.dat -in $This.dir.dirtmp -side left -anchor w -padx 1
            #--- Cree un bouton charger
            button $This.dir.dirtmp.explore -text "..." -width 3 \
               -command { 
                  if {! [catch {::bddimages_config::getDir $bddconf(dirbase) "temporaire"} wdir]} {
                     set bddconf(dirtmp) $wdir
                  }
               }
            pack $This.dir.dirtmp.explore -in $This.dir.dirtmp -side left -anchor c -fill x -padx 6
            #--- Cree un bouton info
            button $This.dir.dirtmp.help -state active -relief groove -anchor c \
                    -text "$caption(bddimages_config,info)" -command { ::bddimages_config::GetInfo "dir_tmp" }
            pack $This.dir.dirtmp.help -in $This.dir.dirtmp -side left -anchor w -padx 1

        #--- Cree un frame pour les variables
        frame $This.var -borderwidth 1 -relief groove
        pack $This.var -in $This -anchor w -side top -expand 0 -fill x -padx 10 -pady 5

          #--- Cree un label pour le titre
          label $This.var.titre -text "$caption(bddimages_config,variables)" -borderwidth 0 -relief flat
          pack $This.var.titre -in $This.var -side top -anchor w -padx 3 -pady 3

          #--- Cree un frame pour la limite de liste
          frame $This.var.lim -borderwidth 0 -relief flat
          pack $This.var.lim -in $This.var -anchor w -side top -expand 0 -fill both -padx 3 -pady 0

            #--- Cree un label
            label $This.var.lim.lab -text "$caption(bddimages_config,listlimit)" -width $widthlab -anchor w -borderwidth 0 -relief flat
            pack $This.var.lim.lab -in $This.var.lim -side left -anchor w -padx 1
            #--- Cree une ligne d'entree pour la variable
            entry $This.var.lim.dat -textvariable bddconf(limit) -borderwidth 1 -relief groove -width 25 -justify left
            pack $This.var.lim.dat -in $This.var.lim -side left -anchor w -padx 1
            #--- Cree un bouton vide
            button $This.var.lim.test -state disabled -relief flat -anchor c -width 4
            pack $This.var.lim.test -in $This.var.lim -side left -anchor w -padx 1
            #--- Cree un bouton info
            button $This.var.lim.help -state active -relief groove -anchor c \
                    -text "$caption(bddimages_config,info)" -command { ::bddimages_config::GetInfo "listlimit" }
            pack $This.var.lim.help -in $This.var.lim -side left -anchor w -padx 1


         #--- Cree un frame pour y mettre les boutons
         frame $This.frame11 \
            -borderwidth 0 -cursor arrow
         pack $This.frame11 \
            -in $This -anchor s -side bottom -expand 0 -fill x

           #--- Creation du bouton fermer
           button $This.frame11.but_fermer \
              -text "$caption(bddimages_config,fermer)" -borderwidth 2 \
              -command { ::bddimages_config::fermer }
           pack $This.frame11.but_fermer \
              -in $This.frame11 -side right -anchor e \
              -padx 5 -pady 5 -ipadx 5 -ipady 5 -expand 0

           #--- Creation du bouton sauvegarder
           button $This.frame11.but_save \
              -text "$caption(bddimages_config,save)" -borderwidth 2 \
              -command { ::bddimages_config::save }
           pack $This.frame11.but_save \
              -in $This.frame11 -side right -anchor e \
              -padx 5 -pady 5 -ipadx 5 -ipady 5 -expand 0

           #--- Creation du bouton aide
           button $This.frame11.but_aide \
              -text "$caption(bddimages_config,aide)" -borderwidth 2 \
              -command { ::audace::showHelpPlugin tool bddimages bddimages.htm }
           pack $This.frame11.but_aide \
              -in $This.frame11 -side right -anchor e \
              -padx 5 -pady 5 -ipadx 5 -ipady 5 -expand 0


      #--- Gestion du bouton
      #$audace(base).bddimages_config.fra5.but1 configure -relief raised -state normal

      #--- La fenetre est active
      focus $This

      #--- Raccourci qui donne le focus a la Console et positionne le curseur dans la ligne de commande
      bind $This <Key-F1> { $audace(console)::GiveFocus }

      #--- Mise a jour dynamique des couleurs
      ::confColor::applyColor $This
   }

}

