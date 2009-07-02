#--------------------------------------------------  
# source audace/plugin/tool/bddimages/bddimages_config.tcl
#--------------------------------------------------  
#
# Fichier     : bddimages_config.tcl
# Description : Configuration des variables globales bddconf
#               necessaires au service
# Auteur      : Frédéric Vachier
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
#
#   -- Procedures du namespace
#
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
#
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
  
namespace eval bddimages_config {
   global audace
   global bddconf

   # Tous les parametres de configuration
   set allparams { login pass serv dirbase dirinco dirfits dircata direrr dirlog limit intellilists }

   #--- Chargement des captions
   uplevel #0 "source \"[ file join $audace(rep_plugin) tool bddimages bddimages_config.cap ]\""

   #
   # bddimages_config::run this
   # Cree la fenetre de tests
   # this = chemin de la fenetre
   #
   proc run { this } {
      variable This

      set This $this
      createDialog 
   }

   #
   # ::bddimages_config::fermer
   # Fonction appellee lors de l'appui sur le bouton 'Fermer'
   #
   proc fermer { } {
      variable This

      ::bddimages_config::recup_position
      destroy $This
   }

   #
   # ::bddimages_config::save
   # Fonction appellee lors de l'appui sur le bouton 'Sauver'
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

   #
   # bddimages_config::recup_position
   # Permet de recuperer et de sauvegarder la position de la fenetre
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

   #
   # bddimages_config::createDialog
   # Creation de l'interface graphique
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
       if {[info exists conf(bddimages,$param)]} { set bddconf($param) $conf(bddimages,$param) } else { set bddconf($param) "" }
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
        frame $This.bdd -borderwidth 1 -relief solid
        pack $This.bdd -in $This -anchor w -side top -expand 0 -fill x -padx 10

          #--- Cree un label pour le titre 
          label $This.bdd.titre -text "$caption(bddimages_config,access)" -borderwidth 0 -relief flat
          pack $This.bdd.titre -in $This.bdd -side top -anchor w -padx 3 -pady 3

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
                    -text "$caption(bddimages_config,test)" -command { ::skybot_Search::GetInfo "ad" }
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
                    -text "$caption(bddimages_config,test)" -command { ::skybot_Search::GetInfo "ad" }
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
                    -text "$caption(bddimages_config,test)" -command { ::skybot_Search::GetInfo "ad" }
            pack $This.bdd.serv.help -in $This.bdd.serv -side left -anchor w -padx 1

        #--- Cree un frame pour les repertoires
        frame $This.dir -borderwidth 1 -relief solid
        pack $This.dir -in $This -anchor w -side top -expand 0 -fill x -padx 10

          #--- Cree un label pour le titre 
          label $This.dir.titre -text "$caption(bddimages_config,dir)" -borderwidth 0 -relief flat
          pack $This.dir.titre -in $This.dir -side top -anchor w -padx 3 -pady 3

          #--- Cree un frame pour le repertoire de la base
          frame $This.dir.dirbase -borderwidth 0 -relief flat
          pack $This.dir.dirbase -in $This.dir -anchor w -side top -expand 0 -fill both -padx 3 -pady 0

            #--- Cree un label
            label $This.dir.dirbase.lab -text "$caption(bddimages_config,dirbase)" -width 30 -anchor w -borderwidth 0 -relief flat
            pack $This.dir.dirbase.lab -in $This.dir.dirbase -side left -anchor w -padx 1
            #--- Cree une ligne d'entree pour la variable
            entry $This.dir.dirbase.dat -textvariable bddconf(dirbase) -borderwidth 1 -relief groove -width 25 -justify left
            pack $This.dir.dirbase.dat -in $This.dir.dirbase -side left -anchor w -padx 1
            #--- Cree un bouton info
            button $This.dir.dirbase.help -state active -borderwidth 0 -relief flat -anchor c -height 1 \
                    -text "$caption(bddimages_config,test)" -command { ::skybot_Search::GetInfo "ad" }
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
            #--- Cree un bouton info
            button $This.dir.dirinco.help -state active -borderwidth 0 -relief flat -anchor c -height 1 \
                    -text "$caption(bddimages_config,test)" -command { ::skybot_Search::GetInfo "ad" }
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
            #--- Cree un bouton info
            button $This.dir.dirfits.help -state active -borderwidth 0 -relief flat -anchor c -height 1 \
                    -text "$caption(bddimages_config,test)" -command { ::skybot_Search::GetInfo "ad" }
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
            #--- Cree un bouton info
            button $This.dir.dircata.help -state active -borderwidth 0 -relief flat -anchor c -height 1 \
                    -text "$caption(bddimages_config,test)" -command { ::skybot_Search::GetInfo "ad" }
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
            #--- Cree un bouton info
            button $This.dir.direrr.help -state active -borderwidth 0 -relief flat -anchor c -height 1 \
                    -text "$caption(bddimages_config,test)" -command { ::skybot_Search::GetInfo "ad" }
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
            #--- Cree un bouton info
            button $This.dir.dirlog.help -state active -borderwidth 0 -relief flat -anchor c -height 1 \
                    -text "$caption(bddimages_config,test)" -command { ::skybot_Search::GetInfo "ad" }
            pack $This.dir.dirlog.help -in $This.dir.dirlog -side left -anchor w -padx 1

        #--- Cree un frame pour les variables
        frame $This.var -borderwidth 1 -relief solid
        pack $This.var -in $This -anchor w -side top -expand 0 -fill x -padx 10

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
                    -text "$caption(bddimages_config,test)" -command { ::skybot_Search::GetInfo "ad" }
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

