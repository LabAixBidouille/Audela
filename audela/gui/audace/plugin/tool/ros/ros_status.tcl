#--------------------------------------------------
# source audace/plugin/tool/ros/ros_status.tcl
#--------------------------------------------------
#
# Fichier        : ros_status.tcl
# Description    : Affiche le status de la base de donnees
# Auteur         : Frédéric Vachier
# Mise à jour $Id$
#

namespace eval ros_status {
   package require rosAdmin 1.0

   global audace
   global rosconf

   #--- Chargement des captions
   uplevel #0 "source \"[ file join $audace(rep_plugin) tool ros ros_status.cap ]\""
   uplevel #0 "source \"[ file join $audace(rep_plugin) tool ros ros_sub_fichier.tcl ]\""

   #
   # ros_status::run this
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
   # ros_status::fermer
   # Fonction appellee lors de l'appui sur le bouton 'Fermer'
   #
   proc fermer { } {
      variable This

      ::ros_status::recup_position
      destroy $This
      return
   }

   #
   # ros_status::recup_position
   # Permet de recuperer et de sauvegarder la position de la fenetre
   #
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


   #
   # ros_status::createDialog
   # Creation de l'interface graphique
   #
   proc createDialog { } {
      variable This
      global audace
      global caption
      global color
      global conf
      global rosconf

      #--- initConf
      if { ! [ info exists conf(ros,position_status) ] } { set conf(ros,position_status) "+80+40" }

      #--- confToWidget
      set rosconf(position_status) $conf(ros,position_status)

      #---
      if { [ winfo exists $This ] } {
         wm withdraw $This
         wm deiconify $This
         focus $This.frame11.but_fermer
         #--- Gestion du bouton
         #$audace(base).ros.fra5.but1 configure -relief raised -state normal
         return
      }

      #---
      if { [ info exists rosconf(geometry_status) ] } {
         set deb [ expr 1 + [ string first + $rosconf(geometry_status) ] ]
         set fin [ string length $rosconf(geometry_status) ]
         set rosconf(position_status) "+[ string range $rosconf(geometry_status) $deb $fin ]"
      }

      #--- Interrogation de la base de donnees
      #set erreur [ catch { ros_status_sql } msg ]

      # Config courante
      if { ![info exists rosconf(default_config)] } {
         #--- Charge les config ros depuis le fichier XML
         set err [::rosXML::load_xml_config]
         #--- et recupere la config par defaut
         set rosconf(current_config) $::rosXML::current_config
      } else {
         # Charge la config par defaut
         set rosconf(current_config) [::rosXML::get_config $rosconf(default_config)]
      }

      #--- Mise en forme du resultat
      set errconn    [catch {::ros_sql::connect} status]
      set nbrequetes [catch {::rosAdmin::sql_nbrequetes} status2]
      #::console::affiche_erreur $status2
      set nbrequetes $status2
      set nbscenes   [catch {::rosAdmin::sql_nbscenes  } status2]
      #::console::affiche_erreur $status2
      set nbscenes $status2
      set errc  [catch {::ros_webservice::alive_ping} tconnect]
      set nbfichinc 0
      set nbficherr 0
      set erreur    0

      #--- Gestion des erreurs
      if { $erreur == "0"} {

         #---
         toplevel $This -class Toplevel
         wm geometry $This $rosconf(position_status)
         wm resizable $This 1 1
         wm title $This $caption(ros_status,main_title)
         wm protocol $This WM_DELETE_WINDOW { ::ros_status::fermer }

         #--- Cree un frame pour afficher le status de la base
         frame $This.frame1 -borderwidth 0 -cursor arrow -relief groove
         pack $This.frame1 -in $This -anchor s -side top -expand 0 -fill x -padx 10 -pady 5

           #--- Cree un label pour le titre
           label $This.frame1.titre -font $rosconf(font,arial_14_b) \
                 -text "$caption(ros_status,titre)"
           pack $This.frame1.titre \
                -in $This.frame1 -side top -padx 3 -pady 3

           #--- Cree un frame pour afficher les resultats
           frame $This.frame1.status \
                 -borderwidth 1 -relief raised -cursor arrow
           pack $This.frame1.status \
                -in $This.frame1 -side top -expand 0 -fill x -padx 1 -pady 1

           #--- Cree un label pour le status
           label $This.frame1.statusbdd -font $rosconf(font,arial_12_b) \
                -text "$caption(ros_status,label_bdd)"
           pack $This.frame1.statusbdd -in $This.frame1.status -side top -padx 3 -pady 1 -anchor w

             #--- Cree un frame pour afficher les intitules
             set intitle [frame $This.frame1.status.l -borderwidth 0]
             pack $intitle -in $This.frame1.status -side left

               #--- Cree un label pour le status
               label $intitle.ok -font $rosconf(font,courier_10) -padx 3 \
                     -text "$caption(ros_status,label_connect)"
               pack $intitle.ok -in $intitle -side top -padx 3 -pady 1 -anchor w
               #--- Cree un label pour le nb d image
               label $intitle.requetes -font $rosconf(font,courier_10) \
                     -text "$caption(ros_status,label_nbrequetes)"
               pack $intitle.requetes -in $intitle -side top -padx 3 -pady 1 -anchor w
               #--- Cree un label pour le nb de header
               label $intitle.scenes -font $rosconf(font,courier_10) \
                     -text "$caption(ros_status,label_nbscenes)"
               pack $intitle.scenes -in $intitle -side top -padx 3 -pady 1 -anchor w

             #--- Cree un frame pour afficher les valeurs
             set inparam [frame $This.frame1.status.v -borderwidth 0]
             pack $inparam -in $This.frame1.status -side right -expand 1 -fill x

               #--- Cree un label pour le status
               label $inparam.ok \
                     -text $status -fg $color(green)
               if {$errconn != 0} { $inparam.ok configure -fg $color(red) }
               pack $inparam.ok -in $inparam -side top -pady 1 -anchor w
               #--- Cree un label pour le nb image
               label $inparam.requetes   \
                     -text $nbrequetes -fg $color(blue)
               pack $inparam.requetes -in $inparam -side top -pady 1 -anchor w
               #--- Cree un label pour le nb de header
               label $inparam.scenes   \
                     -text $nbscenes -fg $color(blue)
               pack $inparam.scenes -in $inparam -side top -pady 1 -anchor w


           #--- Cree un frame pour le status des repertoires
           frame $This.frame1.rep \
                 -borderwidth 1 -relief raised -cursor arrow
           pack $This.frame1.rep \
                -in $This.frame1 -side top -expand 0 -fill x -padx 1 -pady 1

           #--- Cree un label pour le status des repertoires
           label $This.frame1.statusrep -font $rosconf(font,arial_12_b) \
                -text "$caption(ros_status,label_rep)"
           pack $This.frame1.statusrep -in $This.frame1.rep -side top -padx 3 -pady 1 -anchor w

             #--- Cree un frame pour afficher les intitules
             set intitle [frame $This.frame1.rep.l -borderwidth 0]
             pack $intitle -in $This.frame1.rep -side left

               #--- Cree un label pour le status
               label $intitle.tconnect -font $rosconf(font,courier_10) \
                     -text "$caption(ros_status,label_tconnect)" -anchor center
               pack $intitle.tconnect -in $intitle -side top -padx 3 -pady 1 -anchor center


             #--- Cree un frame pour afficher les valeurs
             set inparam [frame $This.frame1.rep.v -borderwidth 0]
             pack $inparam -in $This.frame1.rep -side right -expand 1 -fill x

               #--- Cree un label pour le status
               label $inparam.tconnect  \
                     -text $tconnect -fg $color(green)
               #if {$nbfichbdd != $nbimg} { $inparam.nbimgrep configure -fg $color(red) }
               pack $inparam.tconnect -in $inparam -side top -pady 1 -anchor w



         #--- Cree un frame pour y mettre les boutons
         frame $This.frame11 \
            -borderwidth 0 -cursor arrow
         pack $This.frame11 \
            -in $This -anchor s -side bottom -expand 0 -fill x

           #--- Creation du bouton fermer
           button $This.frame11.but_fermer \
              -text "$caption(ros_status,fermer)" -borderwidth 2 \
              -command { ::ros_status::fermer }
           pack $This.frame11.but_fermer \
              -in $This.frame11 -side right -anchor e \
              -padx 5 -pady 5 -ipadx 5 -ipady 5 -expand 0

           #--- Creation du bouton aide
           button $This.frame11.but_aide \
              -text "$caption(ros_status,aide)" -borderwidth 2 \
              -command { ::audace::showHelpPlugin tool ros ros.htm }
           pack $This.frame11.but_aide \
              -in $This.frame11 -side right -anchor e \
              -padx 5 -pady 5 -ipadx 5 -ipady 5 -expand 0

           #--- Creation du bouton Connect
           button $This.frame11.but_connect \
              -text "$caption(ros_status,verif)" -borderwidth 2 \
              -command { ::ros_status::verif }
           pack $This.frame11.but_connect \
              -in $This.frame11 -side right -anchor e \
              -padx 5 -pady 5 -ipadx 5 -ipady 5 -expand 0

           #--- Creation du bouton RAZ
           button $This.frame11.but_raz \
              -text "$caption(ros_status,raz)" -borderwidth 2 \
              -command { ::rosAdmin::RAZBdd }
           pack $This.frame11.but_raz \
              -in $This.frame11 -side right -anchor e \
              -padx 5 -pady 5 -ipadx 5 -ipady 5 -expand 0

      } else {

         tk_messageBox -title $caption(ros_status,msg_erreur) -type ok -message $caption(ros_status,msg_prevent2)
         #$audace(base).ros.fra5.but1 configure -relief raised -state normal
         return

      }

      #--- Gestion du bouton
      #$audace(base).ros.fra5.but1 configure -relief raised -state normal

      #--- La fenetre est active
      focus $This

      #--- Raccourci qui donne le focus a la Console et positionne le curseur dans la ligne de commande
      bind $This <Key-F1> { $audace(console)::GiveFocus }

   }

   # ros_status::list_diff_shift
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

   # ros_status::verif
   # Verification des donnees
   proc verif { } {
   
      global maliste
      global conf
      global entetelog
   
      set entetelog "verif"
      ros_sauve_fich ""
      ros_sauve_fich "*** Verification des donnees *** "
      ros_sauve_fich ""
   
      set list_file_dir ""
      set list_file_sql ""
   
      set limit 0
      set maliste {}
   
      # Recupere la liste des fichiers sur le disque par la globale maliste
      ros_sauve_fich "Obtention de la liste des fichiers sur le disque"
      globrdk $conf(ros,dirfits) $limit

      set err [catch {set maliste [lsort -increasing $maliste]} result]
      set list_file_dir $maliste
      if {$err} {
         set error_msg "Erreur de tri de la liste: $msg"
         ros_sauve_fich $error_msg
         tk_messageBox -message "$error_msg\n" -type ok
         return
      }

      # Recupere la liste des fichiers sur le serveur sql
      ros_sauve_fich "Obtention de la liste des fichiers sur le serveur sql"
      set sqlcmd "SELECT dirfilename,filename FROM images;"
      set err [catch {set resultsql [::ros_sql::sql query $sqlcmd]} msg]
      if {$err} {
         set error_msg "Erreur de lecture de la liste par SQL: $msg"
         ros_sauve_fich $error_msg
         tk_messageBox -message "$error_msg\n" -type ok
         return
      }

      # Comparaison des liste
      ros_sauve_fich "Comparaison des listes"
      foreach line $resultsql {
         set dir [lindex $line 0]
         set fic [lindex $line 1]
         lappend list_file_sql "$conf(ros,dirbase)/$dir/$fic"
      }
   
      set new_list_sql [list_diff_shift $list_file_dir $list_file_sql]
      set new_list_dir [list_diff_shift $list_file_sql $list_file_dir]
   
      ros_sauve_fich ""
      ros_sauve_fich "-- Nombre d'images absentes sur le serveur SQL : [llength $new_list_sql]"
      ros_sauve_fich ""
      foreach elemsql $new_list_sql { ros_sauve_fich $elemsql }
      ros_sauve_fich ""
      ros_sauve_fich "-- Nombre d'images absentes sur le disque : [llength $new_list_dir]"
      ros_sauve_fich ""
      foreach elemdir $new_list_sql { ros_sauve_fich $elemdir }
      ros_sauve_fich ""
   
      # verification des donnees sur le serveur SQL
   
      set sqlcmd "SELECT DISTINCT idheader FROM header;"
      set err [catch {set resultsql [::ros_sql::sql query $sqlcmd]} msg]
      if {$err} {
         set error_msg "Erreur de lecture de la liste par SQL: $msg"
         ros_sauve_fich $error_msg
         tk_messageBox -message "$error_msg\n" -type ok
         return
      }
   
      foreach line $resultsql {
         set idhd [lindex $line 0]
         set sqlcmd "SELECT count(*) FROM images WHERE idheader='$idhd';"
         set err [catch {set res_images [::ros_sql::sql query $sqlcmd]} msg]
         if {$err} {
            set error_msg "Erreur SQL: $msg"
            ros_sauve_fich $error_msg
            tk_messageBox -message "$error_msg\n" -type ok
            return
         }
         set sqlcmd "SELECT count(*) FROM images_$idhd;"
         set err [catch {set res_images_hd [::ros_sql::sql query $sqlcmd]} msg]
         if {$err} {
            set error_msg "Erreur SQL: $msg"
            ros_sauve_fich $error_msg
            tk_messageBox -message "$error_msg\n" -type ok
            return
         }
         if {$res_images_hd!=$res_images} {
            ros_sauve_fich "-- Header num : $idhd"
            # recupere la liste des idbddimg de images
            set sqlcmd "SELECT idbddimg FROM images WHERE idheader='$idhd';"
            set err [catch {set res_images [::ros_sql::sql query $sqlcmd]} msg]
            if {$err} {
               set error_msg "Erreur SQL: $msg"
               ros_sauve_fich $error_msg
               tk_messageBox -message "$error_msg\n" -type ok
               return
            }
            # recupere la liste des idbddimg de images_idhd
            set sqlcmd "SELECT idbddimg FROM images_$idhd;"
            set err [catch {set res_images_hd [::ros_sql::sql query $sqlcmd]} msg]
            if {$err} {
               set error_msg "Erreur SQL: $msg"
               ros_sauve_fich $error_msg
               tk_messageBox -message "$error_msg\n" -type ok
               return
            }
            # effectue les compraisons
            set list_img [list_diff_shift $res_images_hd $res_images]
            set list_img_hd [list_diff_shift $res_images $res_images_hd]
            # affiche les resultats
            ros_sauve_fich "  Nombre d'images absentes dans la table images_$idhd : [llength $list_img]"
            ros_sauve_fich ""
            foreach elem $list_img { ros_sauve_fich $elem }
            ros_sauve_fich ""
            ros_sauve_fich "  Nombre d'images absentes dans la table images : [llength $list_img_hd]"
            ros_sauve_fich ""
            foreach elem $list_img_hd { ros_sauve_fich $elem }
            ros_sauve_fich ""
         }
      }
   
   }

}
