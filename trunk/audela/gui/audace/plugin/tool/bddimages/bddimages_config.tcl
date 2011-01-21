#--------------------------------------------------
# source audace/plugin/tool/bddimages/bddimages_config.tcl
#--------------------------------------------------
#
# Fichier        : bddimages_config.tcl
# Description    : Configuration des variables globales bddconf
#                  necessaires au service
# Auteur         : Frédéric Vachier
# Mise à jour $Id: bddimages_config.tcl,v 1.6 2011-01-21 12:29:02 fredvachier Exp $
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
   global audace
   global bddconf

   # Tous les parametres de configuration
   set allparams { dbname login pass serv dirbase dirinco dirfits dircata direrr dirlog limit intellilists }

   #--- Chargement des captions
   uplevel #0 "source \"[ file join $audace(rep_plugin) tool bddimages bddimages_config.cap ]\""
   uplevel #0 "source \"[ file join $audace(rep_plugin) tool bddimages bddimages_config.tcl ]\""

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
   proc fermer { } {
      variable This

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
   proc save { } {
      variable This
      global audace
      global conf
      global bddconf
      variable allparams

      foreach param $allparams {
        set conf(bddimages,$param) $bddconf($param)
      }

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
   proc recup_position { } {
      variable This
      global audace
      global conf
      global bddconf

      set bddconf(geometry_status) [ wm geometry $This ]
      set deb [ expr 1 + [ string first + $bddconf(geometry_status) ] ]
      set fin [ string length $bddconf(geometry_status) ]
      set bddconf(position_status) "+[ string range $bddconf(geometry_status) $deb $fin ]"
      #---
      set conf(bddimages,position_status) $bddconf(position_status)
   }

#--------------------------------------------------
#  read_default_config { }
#--------------------------------------------------
#
#    fonction  :
#       Charge le fichier d initialisation xml 
#       
#
#    procedure externe :
#
#    variables en entree :
#
#    variables en sortie :
#
proc read_default_config { file_config } {

   global bddconf

   set txt_config ""
   set f [open $file_config r]
   while {![eof $f]} {
       append txt_config [gets $f]
   }
   close $f
   #::console::affiche_resultat "TXT=$txt_config \n"

   set xmlconfig [::dom::parse $txt_config]

   foreach n [::dom::selectNode $xmlconfig {descendant::bddimages}] {

      set default [::dom::node stringValue [::dom::selectNode $n {attribute::default}]]
      if {$default == "yes"} {
         ::console::affiche_resultat "Lecture de la configuration \n"
         set bddconf(name)        [::dom::node stringValue [::dom::selectNode $n {descendant::name/text()}]]
         set bddconf(dbname)      [::dom::node stringValue [::dom::selectNode $n {descendant::dbname/text()}]]
         set bddconf(login)       [::dom::node stringValue [::dom::selectNode $n {descendant::login/text()}]]
         set bddconf(pass)        [::dom::node stringValue [::dom::selectNode $n {descendant::pass/text()}]]
         set bddconf(serv)        [::dom::node stringValue [::dom::selectNode $n {descendant::ip/text()}]]
         set bddconf(port)        [::dom::node stringValue [::dom::selectNode $n {descendant::port/text()}]]
         set bddconf(dirbase)     [::dom::node stringValue [::dom::selectNode $n {descendant::root/text()}]]
         set bddconf(dirinco)     [::dom::node stringValue [::dom::selectNode $n {descendant::incoming/text()}]]
         set bddconf(dirfits)     [::dom::node stringValue [::dom::selectNode $n {descendant::fits/text()}]]
         set bddconf(dircata)     [::dom::node stringValue [::dom::selectNode $n {descendant::cata/text()}]]
         set bddconf(direrr)      [::dom::node stringValue [::dom::selectNode $n {descendant::error/text()}]]
         set bddconf(dirlog)      [::dom::node stringValue [::dom::selectNode $n {descendant::log/text()}]]
         set bddconf(limit)       [::dom::node stringValue [::dom::selectNode $n {descendant::screenlimit/text()}]]
         }
      }
   return 0
   }


#--------------------------------------------------
#  charge_ini_xml { }
#--------------------------------------------------
#
#    fonction  :
#       Charge le fichier d initialisation xml 
#       
#
#    procedure externe :
#
#    variables en entree :
#
#    variables en sortie :
#

   proc charge_ini_xml {  } {
      variable This
      global audace
      global caption



      set inifile [ file join $audace(rep_home) bddimages_ini.xml ]
      set defaultinifile [ file join $audace(rep_plugin) tool bddimages config ] bddimages_ini.xml ]

      # Verifie que le fichier xml existe

      if {[file exists $inifile]==0} {
         ::console::affiche_resultat "charge_ini_xml : file $inifile doesn't exist\n"
         # S il n existe pas Creer le fichier 
         set errnum [catch {file copy $defaultinifile $inifile} msg ]
         }

      # Charge le fichier de config
      set err [read_default_config $inifile]

      ::console::affiche_resultat "NAME)       =$bddconf(name)    \n"
      ::console::affiche_resultat "DBNAME)     =$bddconf(dbname)  \n"
      ::console::affiche_resultat "LOGIN)      =$bddconf(login)   \n"
      ::console::affiche_resultat "PASS)       =$bddconf(pass)    \n"
      ::console::affiche_resultat "IP)         =$bddconf(serv)    \n"
      ::console::affiche_resultat "PORT)       =$bddconf(port)    \n"
      ::console::affiche_resultat "ROOT)       =$bddconf(dirbase) \n"
      ::console::affiche_resultat "INCOMING)   =$bddconf(dirinco) \n"
      ::console::affiche_resultat "FITS)       =$bddconf(dirfits) \n"
      ::console::affiche_resultat "CATA)       =$bddconf(dircata) \n"
      ::console::affiche_resultat "ERROR)      =$bddconf(direrr)  \n"
      ::console::affiche_resultat "LOG)        =$bddconf(dirlog)  \n"
      ::console::affiche_resultat "SCREENLIMIT)=$bddconf(limit)   \n"

      return
      }

#--------------------------------------------------
#  charge_selection { }
#--------------------------------------------------
#
#    fonction  :
#       Charge le fichier d initialisation xml 
#       
#
#    procedure externe :
#
#    variables en entree :
#
#    variables en sortie :
#

proc charge_selection { selection file_config } {

   global bddconf

   set txt_config ""
   set f [open $file_config r]
   while {![eof $f]} {
       append txt_config [gets $f]
   }
   close $f
   #::console::affiche_resultat "TXT=$txt_config \n"

   set xmlconfig [::dom::parse $txt_config]

   foreach n [::dom::selectNode $xmlconfig {descendant::bddimages}] {

      set default [::dom::node stringValue [::dom::selectNode $n {attribute::default}]]
      if {$default == "yes"} {
         ::console::affiche_resultat "Lecture de la configuration \n"
         set bddconf(name)        [::dom::node stringValue [::dom::selectNode $n {descendant::name/text()}]]
         set bddconf(dbname)      [::dom::node stringValue [::dom::selectNode $n {descendant::dbname/text()}]]
         set bddconf(login)       [::dom::node stringValue [::dom::selectNode $n {descendant::login/text()}]]
         set bddconf(pass)        [::dom::node stringValue [::dom::selectNode $n {descendant::pass/text()}]]
         set bddconf(serv)        [::dom::node stringValue [::dom::selectNode $n {descendant::ip/text()}]]
         set bddconf(port)        [::dom::node stringValue [::dom::selectNode $n {descendant::port/text()}]]
         set bddconf(dirbase)     [::dom::node stringValue [::dom::selectNode $n {descendant::root/text()}]]
         set bddconf(dirinco)     [::dom::node stringValue [::dom::selectNode $n {descendant::incoming/text()}]]
         set bddconf(dirfits)     [::dom::node stringValue [::dom::selectNode $n {descendant::fits/text()}]]
         set bddconf(dircata)     [::dom::node stringValue [::dom::selectNode $n {descendant::cata/text()}]]
         set bddconf(direrr)      [::dom::node stringValue [::dom::selectNode $n {descendant::error/text()}]]
         set bddconf(dirlog)      [::dom::node stringValue [::dom::selectNode $n {descendant::log/text()}]]
         set bddconf(limit)       [::dom::node stringValue [::dom::selectNode $n {descendant::screenlimit/text()}]]
         }
      }
   return 0
   }




#--------------------------------------------------
#  getDir { }
#--------------------------------------------------
#
#    fonction  :
#       Permet de recuperer le nom des repertoires de travail
#
#    procedure externe :
#
#    variables en entree 
#
#
#    variables en sortie :
#
#

   proc getDir { {path ""} {title ""} } {
      variable This
      global audace
      global caption

      # Defini un repertoire de base -> rep_images
      set initDir $audace(rep_images)
      if {[info exists path]} { set initDir $path }

      # Defini le titre de la fenetre
      set title [concat $caption(bddimages_config,getdir) $title]
      
      #--- Ouvre la fenetre de choix des repertoires
      set workDir [tk_chooseDirectory -title $title -initialdir $initDir -parent $This]
      #--- Extraction et chargement du fichier
      if { $workDir != "" } {
        ::console::affiche_resultat "WORKDIR : $workDir\n"
        return $workDir
      } else {
        return
      }
   }





#--------------------------------------------------
#  GetInfo { }
#--------------------------------------------------
#
#    fonction  :
#       Affichage d'un message sur le format d'une saisie
#       pour un element de la structure d une config pour 
#       une base de donnees de forme bddimages
#       La structure contient toutes les variables
#
#    procedure externe :
#
#    variables en entree 
#
#        subject : nom d une variable de configuration
#
#    variables en sortie :
#
#

   proc GetInfo { subject } {
      global caption
      global voconf
      switch $subject {
         name      { set msg $caption(bddimages_config,info_dbname) }
         login     { set msg $caption(bddimages_config,info_login) }
         passwd    { set msg $caption(bddimages_config,info_passwd) }
         host      { set msg $caption(bddimages_config,info_host) }
         dir_base  { set msg $caption(bddimages_config,info_dirbase) }
         dir_inco  { set msg $caption(bddimages_config,info_dirinco) }
         dir_fits  { set msg $caption(bddimages_config,info_dirfits) }
         dir_cata  { set msg $caption(bddimages_config,info_dircata) }
         dir_err   { set msg $caption(bddimages_config,info_direrr) }
         dir_log   { set msg $caption(bddimages_config,info_dirlog) }
         listlimit { set msg $caption(bddimages_config,info_listlimit) }
      }
      tk_messageBox -title $caption(bddimages_config,info_title) -type ok -message $msg
      return 1
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
   proc createDialog { } {
      variable This
      global audace
      global caption
      global color
      global conf
      global bddconf
      variable allparams

      #--- initConf
      if { ! [ info exists conf(bddimages,position_status) ] } { set conf(bddimages,position_status) "+80+40" } 

      #--- confToWidget
      set bddconf(position_status) $conf(bddimages,position_status)

      foreach param $allparams {
         if {[info exists conf(bddimages,$param)]} {
            set bddconf($param) $conf(bddimages,$param)
         } else { 
            set bddconf($param) "" 
         }
      }

      #---
      if { [ winfo exists $This ] } {
         wm withdraw $This
         wm deiconify $This
         focus $This.frame11.but_fermer
         #--- Gestion du bouton
         #$audace(base).bddimages_config.fra5.but1 configure -relief raised -state normal
         return
      }

      #---
      if { [ info exists bddconf(geometry_status) ] } {
         set deb [ expr 1 + [ string first + $bddconf(geometry_status) ] ]
         set fin [ string length $bddconf(geometry_status) ]
         set bddconf(position_status) "+[ string range $bddconf(geometry_status) $deb $fin ]"
      }


         #---
         toplevel $This -class Toplevel
         wm geometry $This $bddconf(position_status)
         wm resizable $This 1 1
         wm title $This $caption(bddimages_config,main_title)
         wm protocol $This WM_DELETE_WINDOW { ::bddimages_config::fermer }



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
            #--- Cree un bouton info
            button $This.bdd.name.help -state active -borderwidth 0 -relief flat -anchor c -height 1 \
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
            #--- Cree un bouton info
            button $This.bdd.login.help -state active -borderwidth 0 -relief flat -anchor c -height 1 \
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
            #--- Cree un bouton info
            button $This.bdd.pass.help -state active -borderwidth 0 -relief flat -anchor c -height 1 \
                    -text "$caption(bddimages_config,info)" -command { ::bddimages_config::GetInfo "passwd" }
            pack $This.bdd.pass.help -in $This.bdd.pass -side left -anchor w -padx 1

          #--- Cree un frame pour le serveur
          frame $This.bdd.serv -borderwidth 0 -relief flat
          pack $This.bdd.serv -in $This.bdd -anchor w -side top -expand 0 -fill both -padx 3 -pady 0

            #--- Cree un label
            label $This.bdd.serv.lab -text "$caption(bddimages_config,serv)" -width 30 -anchor w -borderwidth 0 -relief flat
            pack $This.bdd.serv.lab -in $This.bdd.serv -side left -anchor w -padx 1
            #--- Cree une ligne d'entree pour la variable
            entry $This.bdd.serv.dat -textvariable bddconf(serv) -borderwidth 1 -relief groove -width 25 -justify left
            pack $This.bdd.serv.dat -in $This.bdd.serv -side left -anchor w -padx 1
            #--- Cree un bouton info
            button $This.bdd.serv.help -state active -borderwidth 0 -relief flat -anchor c -height 1 \
                    -text "$caption(bddimages_config,info)" -command { ::bddimages_config::GetInfo "host" }
            pack $This.bdd.serv.help -in $This.bdd.serv -side left -anchor w -padx 1

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
            label $This.dir.dirbase.lab -text "$caption(bddimages_config,dirbase)" -width 30 -anchor w -borderwidth 0 -relief flat
            pack $This.dir.dirbase.lab -in $This.dir.dirbase -side left -anchor w -padx 1
            #--- Cree une ligne d'entree pour la variable
            entry $This.dir.dirbase.dat -textvariable bddconf(dirbase) -borderwidth 1 -relief groove -width 25 -justify left
            pack $This.dir.dirbase.dat -in $This.dir.dirbase -side left -anchor w -padx 1
            #--- Cree un bouton charger
            button $This.dir.dirbase.explore -text "..." -width 3 -command { set bddconf(dirbase) [::bddimages_config::getDir $bddconf(dirbase) "de base"] }
            pack $This.dir.dirbase.explore -in $This.dir.dirbase -side left -anchor c -fill x -padx 6
            #--- Cree un bouton info
            button $This.dir.dirbase.help -state active -borderwidth 0 -relief flat -anchor c -height 1 \
                    -text "$caption(bddimages_config,info)" -command { ::bddimages_config::GetInfo "dir_base" }
            pack $This.dir.dirbase.help -in $This.dir.dirbase -side left -anchor w -padx 1

          #--- Cree un frame pour le repertoire incoming
          frame $This.dir.dirinco -borderwidth 0 -relief flat
          pack $This.dir.dirinco -in $This.dir -anchor w -side top -expand 0 -fill both -padx 3 -pady 0

            #--- Cree un label
            label $This.dir.dirinco.lab -text "$caption(bddimages_config,dirinco)" -width 30 -anchor w -borderwidth 0 -relief flat
            pack $This.dir.dirinco.lab -in $This.dir.dirinco -side left -anchor w -padx 1
            #--- Cree une ligne d'entree pour la variable
            entry $This.dir.dirinco.dat -textvariable bddconf(dirinco) -borderwidth 1 -relief groove -width 25 -justify left
            pack $This.dir.dirinco.dat -in $This.dir.dirinco -side left -anchor w -padx 1
            #--- Cree un bouton charger
            button $This.dir.dirinco.explore -text "..." -width 3 -command { set bddconf(dirinco) [::bddimages_config::getDir $bddconf(dirbase) "d'incoming"] }
            pack $This.dir.dirinco.explore -in $This.dir.dirinco -side left -anchor c -fill x -padx 6
            #--- Cree un bouton info
            button $This.dir.dirinco.help -state active -borderwidth 0 -relief flat -anchor c -height 1 \
                    -text "$caption(bddimages_config,info)" -command { ::bddimages_config::GetInfo "dir_inco" }
            pack $This.dir.dirinco.help -in $This.dir.dirinco -side left -anchor w -padx 1

          #--- Cree un frame pour le repertoire fits
          frame $This.dir.dirfits -borderwidth 0 -relief flat
          pack $This.dir.dirfits -in $This.dir -anchor w -side top -expand 0 -fill both -padx 3 -pady 0

            #--- Cree un label
            label $This.dir.dirfits.lab -text "$caption(bddimages_config,dirfits)" -width 30 -anchor w -borderwidth 0 -relief flat
            pack $This.dir.dirfits.lab -in $This.dir.dirfits -side left -anchor w -padx 1
            #--- Cree une ligne d'entree pour la variable
            entry $This.dir.dirfits.dat -textvariable bddconf(dirfits) -borderwidth 1 -relief groove -width 25 -justify left
            pack $This.dir.dirfits.dat -in $This.dir.dirfits -side left -anchor w -padx 1
            #--- Cree un bouton charger
            button $This.dir.dirfits.explore -text "..." -width 3 -command { set bddconf(dirfits) [::bddimages_config::getDir $bddconf(dirbase) "des images FITS"] }
            pack $This.dir.dirfits.explore -in $This.dir.dirfits -side left -anchor c -fill x -padx 6
            #--- Cree un bouton info
            button $This.dir.dirfits.help -state active -borderwidth 0 -relief flat -anchor c -height 1 \
                    -text "$caption(bddimages_config,info)" -command { ::bddimages_config::GetInfo "dir_fits" }
            pack $This.dir.dirfits.help -in $This.dir.dirfits -side left -anchor w -padx 1

          #--- Cree un frame pour le repertoire cata
          frame $This.dir.dircata -borderwidth 0 -relief flat
          pack $This.dir.dircata -in $This.dir -anchor w -side top -expand 0 -fill both -padx 3 -pady 0

            #--- Cree un label
            label $This.dir.dircata.lab -text "$caption(bddimages_config,dircata)" -width 30 -anchor w -borderwidth 0 -relief flat
            pack $This.dir.dircata.lab -in $This.dir.dircata -side left -anchor w -padx 1
            #--- Cree une ligne d'entree pour la variable
            entry $This.dir.dircata.dat -textvariable bddconf(dircata) -borderwidth 1 -relief groove -width 25 -justify left
            pack $This.dir.dircata.dat -in $This.dir.dircata -side left -anchor w -padx 1
            #--- Cree un bouton charger
            button $This.dir.dircata.explore -text "..." -width 3 -command { set bddconf(dircata) [::bddimages_config::getDir $bddconf(dirbase) "des CATA"] }
            pack $This.dir.dircata.explore -in $This.dir.dircata -side left -anchor c -fill x -padx 6
            #--- Cree un bouton info
            button $This.dir.dircata.help -state active -borderwidth 0 -relief flat -anchor c -height 1 \
                    -text "$caption(bddimages_config,info)" -command { ::bddimages_config::GetInfo "dir_cata" }
            pack $This.dir.dircata.help -in $This.dir.dircata -side left -anchor w -padx 1

          #--- Cree un frame pour le repertoire d erreur
          frame $This.dir.direrr -borderwidth 0 -relief flat
          pack $This.dir.direrr -in $This.dir -anchor w -side top -expand 0 -fill both -padx 3 -pady 0

            #--- Cree un label
            label $This.dir.direrr.lab -text "$caption(bddimages_config,direrr)" -width 30 -anchor w -borderwidth 0 -relief flat
            pack $This.dir.direrr.lab -in $This.dir.direrr -side left -anchor w -padx 1
            #--- Cree une ligne d'entree pour la variable
            entry $This.dir.direrr.dat -textvariable bddconf(direrr) -borderwidth 1 -relief groove -width 25 -justify left
            pack $This.dir.direrr.dat -in $This.dir.direrr -side left -anchor w -padx 1
            #--- Cree un bouton charger
            button $This.dir.direrr.explore -text "..." -width 3 -command { set bddconf(direrr) [::bddimages_config::getDir $bddconf(dirbase) "des erreurs"] }
            pack $This.dir.direrr.explore -in $This.dir.direrr -side left -anchor c -fill x -padx 6
            #--- Cree un bouton info
            button $This.dir.direrr.help -state active -borderwidth 0 -relief flat -anchor c -height 1 \
                    -text "$caption(bddimages_config,info)" -command { ::bddimages_config::GetInfo "dir_err" }
            pack $This.dir.direrr.help -in $This.dir.direrr -side left -anchor w -padx 1

          #--- Cree un frame pour le repertoire de log
          frame $This.dir.dirlog -borderwidth 0 -relief flat
          pack $This.dir.dirlog -in $This.dir -anchor w -side top -expand 0 -fill both -padx 3 -pady 0

            #--- Cree un label
            label $This.dir.dirlog.lab -text "$caption(bddimages_config,dirlog)" -width 30 -anchor w -borderwidth 0 -relief flat
            pack $This.dir.dirlog.lab -in $This.dir.dirlog -side left -anchor w -padx 1
            #--- Cree une ligne d'entree pour la variable
            entry $This.dir.dirlog.dat -textvariable bddconf(dirlog) -borderwidth 1 -relief groove -width 25 -justify left
            pack $This.dir.dirlog.dat -in $This.dir.dirlog -side left -anchor w -padx 1
            #--- Cree un bouton charger
            button $This.dir.dirlog.explore -text "..." -width 3 -command { set bddconf(dirlog) [::bddimages_config::getDir $bddconf(dirbase) "de log"] }
            pack $This.dir.dirlog.explore -in $This.dir.dirlog -side left -anchor c -fill x -padx 6
            #--- Cree un bouton info
            button $This.dir.dirlog.help -state active -borderwidth 0 -relief flat -anchor c -height 1 \
                    -text "$caption(bddimages_config,info)" -command { ::bddimages_config::GetInfo "dir_log" }
            pack $This.dir.dirlog.help -in $This.dir.dirlog -side left -anchor w -padx 1

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
            label $This.var.lim.lab -text "$caption(bddimages_config,listlimit)" -width 30 -anchor w -borderwidth 0 -relief flat
            pack $This.var.lim.lab -in $This.var.lim -side left -anchor w -padx 1
            #--- Cree une ligne d'entree pour la variable
            entry $This.var.lim.dat -textvariable bddconf(limit) -borderwidth 1 -relief groove -width 25 -justify left
            pack $This.var.lim.dat -in $This.var.lim -side left -anchor w -padx 1
            #--- Cree un bouton info
            button $This.var.lim.help -state active -borderwidth 0 -relief flat -anchor c -height 1 \
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

