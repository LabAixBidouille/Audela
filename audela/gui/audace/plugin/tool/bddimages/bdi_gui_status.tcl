#--------------------------------------------------
# source audace/plugin/tool/bddimages/bdd_gui_status.tcl
#--------------------------------------------------
#
# Fichier        : bdd_gui_status.tcl
# Description    : Affiche le status de la base de donnees
# Auteur         : Frédéric Vachier
# Mise à jour $Id: bdd_gui_status.tcl 7048 2011-04-02 15:52:09Z jberthier $
#

namespace eval bdi_gui_status {
   
   package require bddimagesXML 1.0
   package require bddimagesAdmin 1.0

   global audace
   global bddconf

   #--- Chargement des captions
   #uplevel #0 "source \"[ file join $audace(rep_plugin) tool bddimages bdi_status.cap ]\""
   #uplevel #0 "source \"[ file join $audace(rep_plugin) tool bddimages bddimages_sub_fichier.tcl ]\""

   #
   # ::run this
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
   # ::fermer
   # Fonction appellee lors de l'appui sur le bouton 'Fermer'
   #
   proc fermer { } {
      variable This

      ::bdi_gui_status::recup_position
      destroy $This
      return
   }

   #
   # ::fermer
   # Fonction appellee lors de l'appui sur le bouton 'Fermer'
   #
   proc restart { } {
      variable This

      ::bdi_gui_status::recup_position
      destroy $This
      ::bdi_gui_status::run $This
      return
   }

   #
   # ::recup_position
   # Permet de recuperer et de sauvegarder la position de la fenetre
   #
   proc recup_position { } {
      variable This
      global audace
      global conf
      global bddconf

      set bddconf(geometry_status) [ wm geometry $This ]
      set conf(bddimages,geometry_status) $bddconf(geometry_status)
      return
   }


   #
   # ::createDialog
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
      if { ! [ info exists conf(bddimages,geometry_status) ] } { set conf(bddimages,geometry_status) "+100+100" }
      set bddconf(geometry_status) $conf(bddimages,geometry_status)

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
      set errconn   [catch {::bddimages_sql::connect} connectstatus]
      ::console::affiche_erreur "  errconn : <$errconn>\n"
      ::console::affiche_erreur "  status  : <$connectstatus>\n"
      set nbimg     [::bddimagesAdmin::sql_nbimg]
      set nbheader  [::bddimagesAdmin::sql_header]
      set nbfichbdd [numberoffile $conf(bddimages,dirfits)]
      set nbfichinc [numberoffile $conf(bddimages,dirinco)]
      ::console::affiche_erreur "  dir  : <$conf(bddimages,dirinco)>\n"
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
         wm geometry $This $bddconf(geometry_status)
         wm resizable $This 1 1
         wm title $This $caption(bdi_status,main_title)
         wm protocol $This WM_DELETE_WINDOW { ::bdi_gui_status::fermer }

         #--- Cree un frame pour afficher le status de la base
         frame $This.frame1 -borderwidth 0 -cursor arrow -relief groove
         pack $This.frame1 -in $This -anchor s -side top -expand 0 -fill x -padx 10 -pady 5

           #--- Cree un label pour le titre
           label $This.frame1.titre -font $bddconf(font,arial_14_b) \
                 -text "$caption(bdi_status,titre)"
           pack $This.frame1.titre \
                -in $This.frame1 -side top -padx 3 -pady 3

           #--- Cree un frame pour afficher les resultats
           frame $This.frame1.status \
                 -borderwidth 1 -relief raised -cursor arrow
           pack $This.frame1.status \
                -in $This.frame1 -side top -expand 0 -fill x -padx 1 -pady 1

           #--- Cree un label pour le status
           label $This.frame1.statusbdd -font $bddconf(font,arial_12_b) \
                -text "$caption(bdi_status,label_bdd)"
           pack $This.frame1.statusbdd -in $This.frame1.status -side top -padx 3 -pady 1 -anchor w

             #--- Cree un frame pour afficher les intitules
             set intitle [frame $This.frame1.status.l -borderwidth 0]
             pack $intitle -in $This.frame1.status -side left

               #--- Cree un label pour le status
               label $intitle.ok -font $bddconf(font,courier_10) -padx 3 \
                     -text "$caption(bdi_status,label_connect)"
               pack $intitle.ok -in $intitle -side top -padx 3 -pady 1 -anchor w
               #--- Cree un label pour le nb d image
               label $intitle.nbimg -font $bddconf(font,courier_10) \
                     -text "$caption(bdi_status,label_nbimg)"
               pack $intitle.nbimg -in $intitle -side top -padx 3 -pady 1 -anchor w
               #--- Cree un label pour le nb de header
               label $intitle.header -font $bddconf(font,courier_10) \
                     -text "$caption(bdi_status,label_nbheader)"
               pack $intitle.header -in $intitle -side top -padx 3 -pady 1 -anchor w

             #--- Cree un frame pour afficher les valeurs
             set inparam [frame $This.frame1.status.v -borderwidth 0]
             pack $inparam -in $This.frame1.status -side right -expand 1 -fill x

               #--- Cree un label pour le status
               label $inparam.ok \
                     -text $connectstatus -fg "#007f00"
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
                -text "$caption(bdi_status,label_rep)"
           pack $This.frame1.statusrep -in $This.frame1.rep -side top -padx 3 -pady 1 -anchor w

             #--- Cree un frame pour afficher les intitules
             set intitle [frame $This.frame1.rep.l -borderwidth 0]
             pack $intitle -in $This.frame1.rep -side left

               #--- Cree un label pour le status
               label $intitle.nbimgrep -font $bddconf(font,courier_10) \
                     -text "$caption(bdi_status,label_nbimgrep)" -anchor center
               pack $intitle.nbimgrep -in $intitle -side top -padx 3 -pady 1 -anchor center

               label $intitle.nbimginco -font $bddconf(font,courier_10) \
                     -text "$caption(bdi_status,label_nbimginc)" -anchor center
               pack $intitle.nbimginco -in $intitle -side top -padx 3 -pady 1 -anchor center

               label $intitle.nbimgerr -font $bddconf(font,courier_10) \
                     -text "$caption(bdi_status,label_nbimgerr)" -anchor center
               pack $intitle.nbimgerr -in $intitle -side top -padx 3 -pady 1 -anchor center


             #--- Cree un frame pour afficher les valeurs
             set inparam [frame $This.frame1.rep.v -borderwidth 0]
             pack $inparam -in $This.frame1.rep -side right -expand 1 -fill x

               #--- Cree un label pour le status
               label $inparam.nbimgrep  \
                     -text $nbfichbdd -fg "#007f00"
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
              -text "$caption(bdi_status,fermer)" -borderwidth 2 \
              -command { ::bdi_gui_status::fermer }
           pack $This.frame11.but_fermer \
              -in $This.frame11 -side right -anchor e \
              -padx 5 -pady 5 -ipadx 5 -ipady 5 -expand 0

           #--- Creation du bouton aide
           button $This.frame11.but_aide \
              -text "$caption(bdi_status,aide)" -borderwidth 2 \
              -command { ::audace::showHelpPlugin tool bddimages bddimages.htm }
           pack $This.frame11.but_aide \
              -in $This.frame11 -side right -anchor e \
              -padx 5 -pady 5 -ipadx 5 -ipady 5 -expand 0

           #--- Creation du bouton Verifier
           button $This.frame11.but_connect \
              -text "$caption(bdi_status,verif)" -borderwidth 2 \
              -command { ::bdi_gui_status::verif }
           pack $This.frame11.but_connect \
              -in $This.frame11 -side right -anchor e \
              -padx 5 -pady 5 -ipadx 5 -ipady 5 -expand 0

           #--- Creation du bouton RAZ
           button $This.frame11.but_raz \
              -text "$caption(bdi_status,raz)" -borderwidth 2 \
              -command { 
                 ::bddimagesAdmin::RAZBdd 
                 ::bdi_gui_status::restart
              }
           pack $This.frame11.but_raz \
              -in $This.frame11 -side right -anchor e \
              -padx 5 -pady 5 -ipadx 5 -ipady 5 -expand 0

      } else {

         tk_messageBox -title $caption(bdi_status,msg_erreur) -type ok -message $caption(bdi_status,msg_prevent2)
         return

      }

      #--- La fenetre est active
      focus $This
      #--- Raccourci qui donne le focus a la Console et positionne le curseur dans la ligne de commande
      bind $This <Key-F1> { $audace(console)::GiveFocus }

   }






   # ::list_diff_shift
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





   # ** verif
   # Verification des donnees
   proc ::bdi_gui_status::verif { } {

      variable This
      global audace
      global caption
      global color
      global maliste
      global conf

      global reportConsole
      set reportConsole $This.verifreport
      if { [ winfo exists $reportConsole ] } {
         destroy $reportConsole
      }
      toplevel $reportConsole -class Toplevel
      wm resizable $reportConsole 1 1
      wm title $reportConsole "BddImages - Console"
      wm protocol $reportConsole WM_DELETE_WINDOW { 
         destroy $reportConsole 
      }

      text $reportConsole.text -height 30 -width 80 -yscrollcommand "$reportConsole.scroll set"
      scrollbar $reportConsole.scroll -command "$reportConsole.text yview"
      pack $reportConsole.scroll -side right -fill y
      pack $reportConsole.text -expand yes -fill both

      #--- Frame des boutons
      frame $reportConsole.pied -borderwidth 1 -relief groove
      pack $reportConsole.pied -side bottom -fill x

      set text $reportConsole.text
      $text tag configure BODY    -foreground black -background white
      $text tag configure TITLE   -foreground "#808080" -justify center -font [ list {Arial} 12 bold ]
      $text tag configure H1      -justify left -font [ list {Arial} 10 normal ]
      $text tag configure H2      -justify left -font [ list {Arial} 10 normal ] -foreground $color(blue) 
      $text tag configure LISTE0  -foreground $color(black) -lmargin1 20
      $text tag configure LISTE1  -foreground $color(red) -lmargin1 30 
      $text tag configure GREEN   -foreground $color(green)
      $text tag configure RED     -foreground $color(red)

      $text insert end "$caption(bdi_status,consoleTitre) \n\n" TITLE

      set list_file_dir ""
      set list_file_sql ""

      set limit 0
      set maliste {}

      # Recupere la liste des fichiers sur le disque par la globale maliste
      $text insert end "$caption(bdi_status,consoleAct1) \n" H1
      get_files $conf(bddimages,dirfits) $limit

      set err [catch {set maliste [lsort -increasing $maliste]} msg]
      set list_file_dir $maliste
      if {$err} {
         tk_messageBox -message "$caption(bdi_status,consoleErr1) $msg" -type ok
         return
      }
      

      # Recupere la liste des fichiers sur le serveur sql
      $text insert end "$caption(bdi_status,consoleAct2) \n" H1
      set sqlcmd "SELECT dirfilename,filename FROM images;"
      set err [catch {set resultsql [::bddimages_sql::sql query $sqlcmd]} msg]
      if {$err} {
         tk_messageBox -message "$caption(bdi_status,consoleErr2) $msg" -type ok
         return
      }

      # Comparaison des listes
      $text insert end "\n$caption(bdi_status,consoleAct3) \n\n" H2
      foreach line $resultsql {
         set dir [lindex $line 0]
         set fic [lindex $line 1]
         lappend list_file_sql "$conf(bddimages,dirbase)/$dir/$fic"
      }

      set ::bdi_tools_status::err_sql     "no"
      set ::bdi_tools_status::err_file    "no"
      set ::bdi_tools_status::err_img     "no"
      set ::bdi_tools_status::err_img_hd  "no"
      set ::bdi_tools_status::err_nblist  "no"
      set ::bdi_tools_status::err_doublon "no"

      set nb_list_file_dir [llength  $list_file_dir]
      set nb_list_file_sql [llength  $list_file_sql]
      if {$nb_list_file_dir != $nb_list_file_sql} {
      
         set  ::bdi_tools_status::err_nblist "yes"
         $text insert end "La longueur des listes differe \n" "RED" 
         
         # traiter le cas o� le fichier dirfilename/filename est en double
         set nb [llength $list_file_sql]
         set ::bdi_tools_status::list_doublon ""
         for {set i 0} {$i<$nb} {incr i} {
            set e1 [lindex $list_file_sql $i]
            for {set j 0} {$j<$nb} {incr j} {
               set e2 [lindex $list_file_sql $j]
               if {$e1==$e2} {
                   lappend ::bdi_tools_status::list_doublon $e1
               }

            }

         }
         set err [llength $::bdi_tools_status::list_doublon]
         if {$err} {
            $text insert end "Il y a un doublon sur le serveur SQL \n" "RED"
            set ::bdi_tools_status::err_doublon "yes"
         }


         
      }




   
      set ::bdi_tools_status::new_list_sql [list_diff_shift $list_file_dir $list_file_sql]

      set res ""
      foreach elem $::bdi_tools_status::new_list_sql {
          set isd [file isdirectory $elem]
          if {$isd == 1} {
             ::console::affiche_erreur "verif repertoire : $elem \n"
             continue
          }
          lappend res $elem        
      }
      set ::bdi_tools_status::new_list_sql $res 




      set ::bdi_tools_status::new_list_dir [list_diff_shift $list_file_sql $list_file_dir]
      set res ""
      foreach elem $::bdi_tools_status::new_list_dir {
          set isd [file isdirectory $elem]
          if {$isd == 1} {
             ::console::affiche_erreur "ld: [lsearch $list_file_dir $elem] [lindex $list_file_dir [lsearch $list_file_dir $elem] ] $elem\n"
             continue
          }
          lappend res $elem        
      }
      set ::bdi_tools_status::new_list_dir $res 


   
      $text insert end "$caption(bdi_status,consoleErrMsg1)" LISTE0
      set tag "GREEN"
      if {[llength $::bdi_tools_status::new_list_sql] > 0} { 
         set tag "RED" 
         set ::bdi_tools_status::err_sql "yes"
      }
      $text insert end "[llength $::bdi_tools_status::new_list_sql] \n" $tag
      foreach elemsql $::bdi_tools_status::new_list_sql { bddimages_sauve_fich $elemsql }

      $text insert end "$caption(bdi_status,consoleErrMsg2)" LISTE0 
      set tag "GREEN"
      if {[llength $::bdi_tools_status::new_list_dir] > 0} { 
         set tag "RED" 
         set ::bdi_tools_status::err_file "yes"
      }
      $text insert end "[llength $::bdi_tools_status::new_list_dir] \n" $tag
      foreach elemdir $::bdi_tools_status::new_list_sql { bddimages_sauve_fich $elemdir }
      $text insert end " \n" LISTE0

      # verification autres tables de donnees sur le serveur SQL
      set sqlcmd "SELECT DISTINCT idheader FROM header;"
      set err [catch {set resultsql [::bddimages_sql::sql query $sqlcmd]} msg]
      if {$err} {
         tk_messageBox -message "$caption(bdi_status,consoleErr2) $msg" -type ok
         return
      }

      foreach line $resultsql {
         set idhd [lindex $line 0]
         set sqlcmd "SELECT count(*) FROM images WHERE idheader='$idhd';"
         set err [catch {set res_images [::bddimages_sql::sql query $sqlcmd]} msg]
         if {$err} {
            tk_messageBox -message "Verif BDI: Erreur SQL: $msg" -type ok
            return
         }
         set sqlcmd "SELECT count(*) FROM images_$idhd;"
         set err [catch {set res_images_hd [::bddimages_sql::sql query $sqlcmd]} msg]
         if {$err} {
            tk_messageBox -message "$caption(bdi_status,consoleErr3) $msg" -type ok
            return
         }
         $text insert end "- Header #$idhd " LISTE0
         if {$res_images_hd != $res_images} {
            # recupere la liste des idbddimg de images
            set sqlcmd "SELECT idbddimg FROM images WHERE idheader='$idhd';"
            set err [catch {set res_images [::bddimages_sql::sql query $sqlcmd]} msg]
            if {$err} {
               tk_messageBox -message "$caption(bdi_status,consoleErr3) $msg" -type ok
               return
            }
            # recupere la liste des idbddimg de images_idhd
            set sqlcmd "SELECT idbddimg FROM images_$idhd;"
            set err [catch {set res_images_hd [::bddimages_sql::sql query $sqlcmd]} msg]
            if {$err} {
               tk_messageBox -message "$caption(bdi_status,consoleErr3) $msg" -type ok
               return
            }
            # effectue les compraisons
            set ::bdi_tools_status::list_img    [list_diff_shift $res_images_hd $res_images]
            set ::bdi_tools_status::list_img_hd [list_diff_shift $res_images $res_images_hd]

            if {[llength $::bdi_tools_status::list_img] > 0} { 
               set ::bdi_tools_status::err_img "yes"
            }
            if {[llength $::bdi_tools_status::list_img_hd] > 0} { 
               set ::bdi_tools_status::err_img_hd "yes"
            }
            # affiche les resultats
            $text insert end "\n $caption(bdi_status,consoleErrMsg3)$idhd : [llength $::bdi_tools_status::list_img]" LISTE1
            bddimages_sauve_fich ""
            foreach elem $::bdi_tools_status::list_img { bddimages_sauve_fich $elem }
            $text insert end "\n $caption(bdi_status,consoleErrMsg4) [llength $::bdi_tools_status::list_img_hd]" LISTE1
            foreach elem $::bdi_tools_status::list_img_hd { bddimages_sauve_fich $elem }
            $text insert end "\n" TEXT
         } else {
            $text insert end " -> ok \n" TEXT
         }
      }
      if { $::bdi_tools_status::err_sql == "yes" || $::bdi_tools_status::err_file == "yes" || $::bdi_tools_status::err_img == "yes" || $::bdi_tools_status::err_img_hd == "yes"  || $::bdi_tools_status::err_nblist == "yes" } { 
        #--- Bouton d'ouverture de l'outil d'insertion des images
        button $reportConsole.pied.repare -borderwidth 2 -text "Repare" \
           -command "::bdi_tools_status::repare"
        pack $reportConsole.pied.repare -in $reportConsole.pied -anchor center -fill none -pady 5 -ipadx 5 -ipady 3
            
      }
      
      $text insert end "\n $caption(bdi_status,consoleFin) \n" TEXT
      
   }

}
