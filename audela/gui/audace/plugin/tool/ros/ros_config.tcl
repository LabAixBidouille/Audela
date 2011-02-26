#--------------------------------------------------
# source audace/plugin/tool/ros/ros_config.tcl
#--------------------------------------------------
#
# Fichier        : ros_config.tcl
# Description    : Configuration des variables globales rosconf
#                  necessaires au service
# Auteur         : Frédéric Vachier
# Mise à jour $Id$
#
#--------------------------------------------------
#
# - namespace ros_config
#
#--------------------------------------------------
#
#   -- Fichiers source externe :
#
#  ros_config.cap
#
#--------------------------------------------------

namespace eval ros_config {
   package require rosXML 1.0
   package require rosAdmin 1.0

   global audace
   global rosconf

   # Tous les parametres de configuration
   set allparams { sauve_xml dbname login pass server dirbase dirinco dirfits dircata direrr dirlog limit intellilists }

   #--- Chargement des captions
   uplevel #0 "source \"[ file join $audace(rep_plugin) tool ros ros_config.cap ]\""

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
      
      ::ros_config::recup_position
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
      global rosconf
      variable allparams

      # Sauve les preferences ros dans audela.ini
      foreach param $allparams {
        set conf(ros,$param) $rosconf($param)
      }

      # Defini la structure de la config courante a partir des champs de saisie
      ::rosXML::set_config $rosconf(current_config)
      # Defini et charge la config par defaut comme etant la config courante
      set rosconf(default_config) [::rosXML::get_config $rosconf(current_config)]
      # Sauve le fichiers XML si demande
      if {$rosconf(sauve_xml) == 1} {
         # Defini la config par defaut
         set ::rosXML::default_config $rosconf(default_config) 
         # Enregistre la config
         ::rosXML::save_xml_config 
      }

      # Fin
      ::ros_config::recup_position
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
   proc ::ros_config::install { } {

      global ros

      set ros(withtk) 1
      source [file join $::audela_start_dir ros_install.tcl]
      ::ros_install::run
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
      global rosconf

      set rosconf(geometry_status) [ wm geometry $This ]
      set deb [ expr 1 + [ string first + $rosconf(geometry_status) ] ]
      set fin [ string length $rosconf(geometry_status) ]
      set rosconf(position_status) "+[ string range $rosconf(geometry_status) $deb $fin ]"
      #---
      set conf(ros,position_status) $rosconf(position_status)
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
      set title [concat $caption(ros_config,getdir) $title]
      set workDir [tk_chooseDirectory -title $title -initialdir $initDir -parent $This]
      
      # Extraction et chargement du fichier
      if { $workDir != "" } {
        return $workDir
      } else {
        return -code 1
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
      global rosconf
      
      # Liste des repertoires a chercher
      set listD [list "cata" "fits" "incoming" "error" "log"]
      # Defini un repertoire de base -> rep_images
      foreach d $listD {
         if {[file isdirectory [file join $base $d]]} { 
            switch $d {
               "cata"     { set rosconf(dircata) [file join $base $d] }
               "fits"     { set rosconf(dirfits) [file join $base $d] }
               "incoming" { set rosconf(dirinco) [file join $base $d] }
               "error"    { set rosconf(direrr)  [file join $base $d] }
               "log"      { set rosconf(dirlog)  [file join $base $d] }
            }
         }
      }
      return 0
   }

   #--------------------------------------------------
   #  GetInfo { }
   #--------------------------------------------------
   # Affichage d'un message sur le format d'une saisie pour un 
   # element de la structure de config XML de ros
   # @param subject le sujet a documenter
   # @return void
   #--------------------------------------------------
   proc GetInfo { subject } {
      global caption
      global voconf
      switch $subject {
         dbname    { set msg $caption(ros_config,info_dbname) }
         login     { set msg $caption(ros_config,info_login) }
         passwd    { set msg $caption(ros_config,info_passwd) }
         host      { set msg $caption(ros_config,info_host) }
         dir_base  { set msg $caption(ros_config,info_dirbase) }
         dir_inco  { set msg $caption(ros_config,info_dirinco) }
         dir_fits  { set msg $caption(ros_config,info_dirfits) }
         dir_cata  { set msg $caption(ros_config,info_dircata) }
         dir_err   { set msg $caption(ros_config,info_direrr) }
         dir_log   { set msg $caption(ros_config,info_dirlog) }
         listlimit { set msg $caption(ros_config,info_listlimit) }
      }
      tk_messageBox -title $caption(ros_config,info_title) -type ok -message $msg
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
      global rosconf
      variable allparams
      global myconf
      global rbconfig
      
      #--- initConf
      if { ! [ info exists conf(ros,position_status) ] } { set conf(ros,position_status) "+80+40" } 

      #--- confToWidget
      set rosconf(position_status) $conf(ros,position_status)

      foreach param $allparams {
         if {[info exists conf(ros,$param)]} {
            set rosconf($param) $conf(ros,$param)
         } else { 
            set rosconf($param) "" 
         }
      }

      #---
      if { [ winfo exists $This ] } {
         wm withdraw $This
         wm deiconify $This
         focus $This.frame11.but_fermer
         #--- Gestion du bouton
         #$audace(base).ros_config.fra5.but1 configure -relief raised -state normal
         return
      }

      #---
      if { [ info exists rosconf(geometry_status) ] } {
         set deb [ expr 1 + [ string first + $rosconf(geometry_status) ] ]
         set fin [ string length $rosconf(geometry_status) ]
         set rosconf(position_status) "+[ string range $rosconf(geometry_status) $deb $fin ]"
      }

      # Charge les config ros depuis le fichier XML
      set err [::rosXML::load_xml_config]
      # Recupere la liste des ros disponibles
      set rosconf(list_config) $::rosXML::list_ros
      # Recupere la config par defaut [liste id name]
      set rosconf(default_config) $::rosXML::default_config
      # Recupere la config par courante [liste id name]
      set rosconf(current_config) $::rosXML::current_config
      
      #---
      toplevel $This -class Toplevel
      wm geometry $This $rosconf(position_status)
      wm resizable $This 1 1
      wm title $This $caption(ros_config,main_title)
      wm protocol $This WM_DELETE_WINDOW { ::ros_config::fermer }

         #--- Cree un frame pour la liste des ros de l'utilisateur
         frame $This.conf -borderwidth 1 -relief groove
         pack $This.conf -in $This -anchor w -side top -expand 0 -fill x -padx 10 -pady 5

          #--- Cree un frame pour le titre et le menu deroulant
          frame $This.conf.m -borderwidth 0 -relief solid
          pack $This.conf.m -in $This.conf -anchor w -side top -expand 0 -fill both -padx 3 -pady 0
 
             #--- Cree un label pour le titre
             label $This.conf.m.titre -text "$caption(ros_config,titleconfig)" -borderwidth 0 -relief flat
             pack $This.conf.m.titre -in $This.conf.m -side left -anchor w -padx 3 -pady 3
             #--- Cree un menu bouton pour choisir la config
             menubutton $This.conf.m.menu -relief raised -borderwidth 2 -textvariable rosconf(current_config) -menu $This.conf.m.menu.list
             set rbconfig [menu $This.conf.m.menu.list -tearoff "1"]
             foreach myconf $rosconf(list_config) {
                $rbconfig add radiobutton -label [lindex "$myconf" 1] -value [lindex "$myconf" 1] -variable rosconf(current_config) \
                    -command { set rosconf(current_config) [::rosXML::get_config $rosconf(current_config)] }
             }
             pack $This.conf.m.menu -in $This.conf.m -side left -anchor w -padx 3 -pady 3


         #--- Cree un frame pour y mettre les boutons
         frame $This.frame11 \
            -borderwidth 0 -cursor arrow
         pack $This.frame11 \
            -in $This -anchor s -side bottom -expand 0 -fill x

           #--- Creation du bouton fermer
           button $This.frame11.but_fermer \
              -text "$caption(ros_config,fermer)" -borderwidth 2 \
              -command { ::ros_config::fermer }
           pack $This.frame11.but_fermer \
              -in $This.frame11 -side right -anchor e \
              -padx 5 -pady 5 -ipadx 5 -ipady 5 -expand 0

           #--- Creation du bouton ok
           button $This.frame11.but_save \
              -text "$caption(ros_config,save)" -borderwidth 2 \
              -command { ::ros_config::save }
           pack $This.frame11.but_save \
              -in $This.frame11 -side right -anchor e \
              -padx 5 -pady 5 -ipadx 5 -ipady 5 -expand 0

           #--- Creation du bouton ok
           button $This.frame11.but_install -text $caption(ros_config,install) -borderwidth 2 -command { ::ros_config::install }
           pack $This.frame11.but_install -in $This.frame11 -side right -anchor e -padx 5 -pady 5 -ipadx 5 -ipady 5 -expand 0

           #--- Creation du bouton aide
           button $This.frame11.but_aide \
              -text "$caption(ros_config,aide)" -borderwidth 2 \
              -command { ::audace::showHelpPlugin tool ros ros.htm }
           pack $This.frame11.but_aide \
              -in $This.frame11 -side right -anchor e \
              -padx 5 -pady 5 -ipadx 5 -ipady 5 -expand 0


      #--- Gestion du bouton
      #$audace(base).ros_config.fra5.but1 configure -relief raised -state normal

      #--- La fenetre est active
      focus $This

      #--- Raccourci qui donne le focus a la Console et positionne le curseur dans la ligne de commande
      bind $This <Key-F1> { $audace(console)::GiveFocus }

      #--- Mise a jour dynamique des couleurs
      ::confColor::applyColor $This
   }

}

