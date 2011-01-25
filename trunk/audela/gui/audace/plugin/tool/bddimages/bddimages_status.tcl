#--------------------------------------------------
# source audace/plugin/tool/bddimages/bddimages_status.tcl
#--------------------------------------------------
#
# Fichier        : bddimages_status.tcl
# Description    : Affiche le status de la base de donnees
# Auteur         : Frédéric Vachier
# Mise à jour $Id: bddimages_status.tcl,v 1.9 2011-01-25 22:49:43 jberthier Exp $
#

namespace eval bddimages_status {
   package require bddimagesAdmin 1.0

   global audace
   global bddconf

   #--- Chargement des captions
   uplevel #0 "source \"[ file join $audace(rep_plugin) tool bddimages bddimages_status.cap ]\""
   uplevel #0 "source \"[ file join $audace(rep_plugin) tool bddimages bddimages_sub_fichier.tcl ]\""

   #
   # bddimages_status::run this
   # Cree la fenetre de tests
   # this = chemin de la fenetre
   #
   proc run { this } {
      variable This

      set This $this
      createDialog
      return
   }

   #
   # bddimages_status::fermer
   # Fonction appellee lors de l'appui sur le bouton 'Fermer'
   #
   proc fermer { } {
      variable This

      ::bddimages_status::recup_position
      destroy $This
      return
   }

   #
   # bddimages_status::recup_position
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
   # bddimages_status::createDialog
   # Creation de l'interface graphique
   #
   proc createDialog { } {
      variable This
      global audace
      global caption
      global color
      global conf
      global bddconf

      #--- initConf
      if { ! [ info exists conf(bddimages,position_status) ] } { set conf(bddimages,position_status) "+80+40" }

      #--- confToWidget
      set bddconf(position_status) $conf(bddimages,position_status)

      #---
      if { [ winfo exists $This ] } {
         wm withdraw $This
         wm deiconify $This
         focus $This.frame11.but_fermer
         #--- Gestion du bouton
         #$audace(base).bddimages.fra5.but1 configure -relief raised -state normal
         return
      }

      #---
      if { [ info exists bddconf(geometry_status) ] } {
         set deb [ expr 1 + [ string first + $bddconf(geometry_status) ] ]
         set fin [ string length $bddconf(geometry_status) ]
         set bddconf(position_status) "+[ string range $bddconf(geometry_status) $deb $fin ]"
      }

      #--- Interrogation de la base de donnees
      #set erreur [ catch { bddimages_status_sql } msg ]

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
      set errconn   [catch {::bddimages_sql::connect} status]
      set nbimg     [catch {::bddimagesAdmin::sql_nbimg} status]
      set nbheader  [catch {::bddimagesAdmin::sql_header} status]
      set nbfichbdd [numberoffile $conf(bddimages,dirfits)]
      set nbfichinc [numberoffile $conf(bddimages,dirinco)]
      set nbficherr [numberoffile $conf(bddimages,direrr)]
      set erreur    0

#      ::console::affiche_resultat "NAME)       =$bddconf(name)    \n"
#      ::console::affiche_resultat "DBNAME)     =$bddconf(dbname)  \n"
#      ::console::affiche_resultat "LOGIN)      =$bddconf(login)   \n"
#      ::console::affiche_resultat "PASS)       =$bddconf(pass)    \n"
#      ::console::affiche_resultat "SERVER)     =$bddconf(server)  \n"
#      ::console::affiche_resultat "PORT)       =$bddconf(port)    \n"
#      ::console::affiche_resultat "ROOT)       =$bddconf(dirbase) \n"
#      ::console::affiche_resultat "INCOMING)   =$bddconf(dirinco) \n"
#      ::console::affiche_resultat "FITS)       =$bddconf(dirfits) \n"
#      ::console::affiche_resultat "CATA)       =$bddconf(dircata) \n"
#      ::console::affiche_resultat "ERROR)      =$bddconf(direrr)  \n"
#      ::console::affiche_resultat "LOG)        =$bddconf(dirlog)  \n"
#      ::console::affiche_resultat "SCREENLIMIT)=$bddconf(limit)   \n"

      #--- Gestion des erreurs
      if { $erreur == "0"} {

         #---
         toplevel $This -class Toplevel
         wm geometry $This $bddconf(position_status)
         wm resizable $This 1 1
         wm title $This $caption(bddimages_status,main_title)
         wm protocol $This WM_DELETE_WINDOW { ::bddimages_status::fermer }

         #--- Cree un frame pour afficher le status de la base
         frame $This.frame1 -borderwidth 0 -cursor arrow -relief groove
         pack $This.frame1 -in $This -anchor s -side top -expand 0 -fill x -padx 10 -pady 5

           #--- Cree un label pour le titre
           label $This.frame1.titre -font $bddconf(font,arial_14_b) \
                 -text "$caption(bddimages_status,titre)"
           pack $This.frame1.titre \
                -in $This.frame1 -side top -padx 3 -pady 3

           #--- Cree un frame pour afficher les resultats
           frame $This.frame1.status \
                 -borderwidth 1 -relief raised -cursor arrow
           pack $This.frame1.status \
                -in $This.frame1 -side top -expand 0 -fill x -padx 1 -pady 1

           #--- Cree un label pour le status
           label $This.frame1.statusbdd -font $bddconf(font,arial_12_b) \
                -text "$caption(bddimages_status,label_bdd)"
           pack $This.frame1.statusbdd -in $This.frame1.status -side top -padx 3 -pady 1 -anchor w

             #--- Cree un frame pour afficher les intitules
             set intitle [frame $This.frame1.status.l -borderwidth 0]
             pack $intitle -in $This.frame1.status -side left

               #--- Cree un label pour le status
               label $intitle.ok -font $bddconf(font,courier_10) -padx 3 \
                     -text "$caption(bddimages_status,label_connect)"
               pack $intitle.ok -in $intitle -side top -padx 3 -pady 1 -anchor w
               #--- Cree un label pour le nb d image
               label $intitle.nbimg -font $bddconf(font,courier_10) \
                     -text "$caption(bddimages_status,label_nbimg)"
               pack $intitle.nbimg -in $intitle -side top -padx 3 -pady 1 -anchor w
               #--- Cree un label pour le nb de header
               label $intitle.header -font $bddconf(font,courier_10) \
                     -text "$caption(bddimages_status,label_nbheader)"
               pack $intitle.header -in $intitle -side top -padx 3 -pady 1 -anchor w

             #--- Cree un frame pour afficher les valeurs
             set inparam [frame $This.frame1.status.v -borderwidth 0]
             pack $inparam -in $This.frame1.status -side right -expand 1 -fill x

               #--- Cree un label pour le status
               label $inparam.ok \
                     -text $status -fg $color(green)
               if {$errconn != 0} { $inparam.ok configure -fg $color(red) }
               pack $inparam.ok -in $inparam -side top -pady 1 -anchor w
               #--- Cree un label pour le nb image
               label $inparam.nbimg   \
                     -text $nbimg -fg $color(blue)
               pack $inparam.nbimg -in $inparam -side top -pady 1 -anchor w
               #--- Cree un label pour le nb de header
               label $inparam.dm   \
                     -text $nbheader -fg $color(blue)
               pack $inparam.dm -in $inparam -side top -pady 1 -anchor w


           #--- Cree un frame pour le status des repertoires
           frame $This.frame1.rep \
                 -borderwidth 1 -relief raised -cursor arrow
           pack $This.frame1.rep \
                -in $This.frame1 -side top -expand 0 -fill x -padx 1 -pady 1

           #--- Cree un label pour le status des repertoires
           label $This.frame1.statusrep -font $bddconf(font,arial_12_b) \
                -text "$caption(bddimages_status,label_rep)"
           pack $This.frame1.statusrep -in $This.frame1.rep -side top -padx 3 -pady 1 -anchor w

             #--- Cree un frame pour afficher les intitules
             set intitle [frame $This.frame1.rep.l -borderwidth 0]
             pack $intitle -in $This.frame1.rep -side left

               #--- Cree un label pour le status
               label $intitle.nbimgrep -font $bddconf(font,courier_10) \
                     -text "$caption(bddimages_status,label_nbimgrep)" -anchor center
               pack $intitle.nbimgrep -in $intitle -side top -padx 3 -pady 1 -anchor center

               label $intitle.nbimginco -font $bddconf(font,courier_10) \
                     -text "$caption(bddimages_status,label_nbimginc)" -anchor center
               pack $intitle.nbimginco -in $intitle -side top -padx 3 -pady 1 -anchor center

               label $intitle.nbimgerr -font $bddconf(font,courier_10) \
                     -text "$caption(bddimages_status,label_nbimgerr)" -anchor center
               pack $intitle.nbimgerr -in $intitle -side top -padx 3 -pady 1 -anchor center


             #--- Cree un frame pour afficher les valeurs
             set inparam [frame $This.frame1.rep.v -borderwidth 0]
             pack $inparam -in $This.frame1.rep -side right -expand 1 -fill x

               #--- Cree un label pour le status
               label $inparam.nbimgrep  \
                     -text $nbfichbdd -fg $color(green)
               if {$nbfichbdd != $nbimg} { $inparam.nbimgrep configure -fg $color(red) }
               pack $inparam.nbimgrep -in $inparam -side top -pady 1 -anchor w

               label $inparam.nbimginco  \
                     -text $nbfichinc -fg $color(blue)
               pack $inparam.nbimginco -in $inparam -side top -pady 1 -anchor w

               label $inparam.nbimgerr  \
                     -text $nbficherr -fg $color(blue)
               pack $inparam.nbimgerr -in $inparam -side top -pady 1 -anchor w


         #--- Cree un frame pour y mettre les boutons
         frame $This.frame11 \
            -borderwidth 0 -cursor arrow
         pack $This.frame11 \
            -in $This -anchor s -side bottom -expand 0 -fill x

           #--- Creation du bouton fermer
           button $This.frame11.but_fermer \
              -text "$caption(bddimages_status,fermer)" -borderwidth 2 \
              -command { ::bddimages_status::fermer }
           pack $This.frame11.but_fermer \
              -in $This.frame11 -side right -anchor e \
              -padx 5 -pady 5 -ipadx 5 -ipady 5 -expand 0

           #--- Creation du bouton aide
           button $This.frame11.but_aide \
              -text "$caption(bddimages_status,aide)" -borderwidth 2 \
              -command { ::audace::showHelpPlugin tool bddimages bddimages.htm }
           pack $This.frame11.but_aide \
              -in $This.frame11 -side right -anchor e \
              -padx 5 -pady 5 -ipadx 5 -ipady 5 -expand 0

           #--- Creation du bouton Connect
           button $This.frame11.but_connect \
              -text "$caption(bddimages_status,verif)" -borderwidth 2 \
              -command { ::bddimages_status::verif }
           pack $This.frame11.but_connect \
              -in $This.frame11 -side right -anchor e \
              -padx 5 -pady 5 -ipadx 5 -ipady 5 -expand 0

           #--- Creation du bouton RAZ
           button $This.frame11.but_raz \
              -text "$caption(bddimages_status,raz)" -borderwidth 2 \
              -command { ::bddimagesAdmin::RAZBdd }
           pack $This.frame11.but_raz \
              -in $This.frame11 -side right -anchor e \
              -padx 5 -pady 5 -ipadx 5 -ipady 5 -expand 0

      } else {

         tk_messageBox -title $caption(bddimages_status,msg_erreur) -type ok -message $caption(bddimages_status,msg_prevent2)
         #$audace(base).bddimages.fra5.but1 configure -relief raised -state normal
         return

      }

      #--- Gestion du bouton
      #$audace(base).bddimages.fra5.but1 configure -relief raised -state normal

      #--- La fenetre est active
      focus $This

      #--- Raccourci qui donne le focus a la Console et positionne le curseur dans la ligne de commande
      bind $This <Key-F1> { $audace(console)::GiveFocus }

   }

   # bddimages_status::list_diff_shift
   # Retourne la liste test epurée de l intersection des deux listes
   proc list_diff_shift { ref test }  {
      foreach elemref $ref {
         set new_test ""
         foreach elemtest $test {
            if {$elemref!=$elemtest} {lappend new_test $elemtest}
         }
         set test $new_test
      }
      return $test
   }

   # bddimages_status::verif
   # Verification des donnees
   proc verif { } {
   
      global maliste
      global conf
      global entetelog
   
      set entetelog "verif"
      bddimages_sauve_fich ""
      bddimages_sauve_fich "*** Verification des donnees *** "
      bddimages_sauve_fich ""
   
      set list_file_dir ""
      set list_file_sql ""
   
      set limit 0
      set maliste {}
   
      # Recupere la liste des fichiers sur le disque par la globale maliste
      bddimages_sauve_fich "Obtention de la liste des fichiers sur le disque"
      globrdk $conf(bddimages,dirfits) $limit

      set err [catch {set maliste [lsort -increasing $maliste]} result]
      set list_file_dir $maliste
      if {$err} {
         set error_msg "Erreur de tri de la liste: $msg"
         bddimages_sauve_fich $error_msg
         tk_messageBox -message "$error_msg\n" -type ok
         return
      }

      # Recupere la liste des fichiers sur le serveur sql
      bddimages_sauve_fich "Obtention de la liste des fichiers sur le serveur sql"
      set sqlcmd "SELECT dirfilename,filename FROM images;"
      set err [catch {set resultsql [::bddimages_sql::sql query $sqlcmd]} msg]
      if {$err} {
         set error_msg "Erreur de lecture de la liste par SQL: $msg"
         bddimages_sauve_fich $error_msg
         tk_messageBox -message "$error_msg\n" -type ok
         return
      }

      # Comparaison des liste
      bddimages_sauve_fich "Comparaison des listes"
      foreach line $resultsql {
         set dir [lindex $line 0]
         set fic [lindex $line 1]
         lappend list_file_sql "$conf(bddimages,dirbase)/$dir/$fic"
      }
   
      set new_list_sql [list_diff_shift $list_file_dir $list_file_sql]
      set new_list_dir [list_diff_shift $list_file_sql $list_file_dir]
   
      bddimages_sauve_fich ""
      bddimages_sauve_fich "-- Nombre d'images absentes sur le serveur SQL : [llength $new_list_sql]"
      bddimages_sauve_fich ""
      foreach elemsql $new_list_sql { bddimages_sauve_fich $elemsql }
      bddimages_sauve_fich ""
      bddimages_sauve_fich "-- Nombre d'images absentes sur le disque : [llength $new_list_dir]"
      bddimages_sauve_fich ""
      foreach elemdir $new_list_sql { bddimages_sauve_fich $elemdir }
      bddimages_sauve_fich ""
   
      # verification des donnees sur le serveur SQL
   
      set sqlcmd "SELECT DISTINCT idheader FROM header;"
      set err [catch {set resultsql [::bddimages_sql::sql query $sqlcmd]} msg]
      if {$err} {
         set error_msg "Erreur de lecture de la liste par SQL: $msg"
         bddimages_sauve_fich $error_msg
         tk_messageBox -message "$error_msg\n" -type ok
         return
      }
   
      foreach line $resultsql {
         set idhd [lindex $line 0]
         set sqlcmd "SELECT count(*) FROM images WHERE idheader='$idhd';"
         set err [catch {set res_images [::bddimages_sql::sql query $sqlcmd]} msg]
         if {$err} {
            set error_msg "Erreur SQL: $msg"
            bddimages_sauve_fich $error_msg
            tk_messageBox -message "$error_msg\n" -type ok
            return
         }
         set sqlcmd "SELECT count(*) FROM images_$idhd;"
         set err [catch {set res_images_hd [::bddimages_sql::sql query $sqlcmd]} msg]
         if {$err} {
            set error_msg "Erreur SQL: $msg"
            bddimages_sauve_fich $error_msg
            tk_messageBox -message "$error_msg\n" -type ok
            return
         }
         if {$res_images_hd!=$res_images} {
            bddimages_sauve_fich "-- Header num : $idhd"
            # recupere la liste des idbddimg de images
            set sqlcmd "SELECT idbddimg FROM images WHERE idheader='$idhd';"
            set err [catch {set res_images [::bddimages_sql::sql query $sqlcmd]} msg]
            if {$err} {
               set error_msg "Erreur SQL: $msg"
               bddimages_sauve_fich $error_msg
               tk_messageBox -message "$error_msg\n" -type ok
               return
            }
            # recupere la liste des idbddimg de images_idhd
            set sqlcmd "SELECT idbddimg FROM images_$idhd;"
            set err [catch {set res_images_hd [::bddimages_sql::sql query $sqlcmd]} msg]
            if {$err} {
               set error_msg "Erreur SQL: $msg"
               bddimages_sauve_fich $error_msg
               tk_messageBox -message "$error_msg\n" -type ok
               return
            }
            # effectue les compraisons
            set list_img [list_diff_shift $res_images_hd $res_images]
            set list_img_hd [list_diff_shift $res_images $res_images_hd]
            # affiche les resultats
            bddimages_sauve_fich "  Nombre d'images absentes dans la table images_$idhd : [llength $list_img]"
            bddimages_sauve_fich ""
            foreach elem $list_img { bddimages_sauve_fich $elem }
            bddimages_sauve_fich ""
            bddimages_sauve_fich "  Nombre d'images absentes dans la table images : [llength $list_img_hd]"
            bddimages_sauve_fich ""
            foreach elem $list_img_hd { bddimages_sauve_fich $elem }
            bddimages_sauve_fich ""
         }
      }
   
   }

}
