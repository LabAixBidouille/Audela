# source audace/plugin/tool/bddimages/bddimages_status.tcl

#
# Fichier     : bddimages_status.tcl
# Description : Affiche le status de la base de donnees
# Auteur      : Frédéric Vachier
#

namespace eval bddimages_status {
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
   }

   #
   # bddimages_status::fermer
   # Fonction appellee lors de l'appui sur le bouton 'Fermer'
   #
   proc fermer { } {
      variable This

      ::bddimages_status::recup_position
      destroy $This
   }

   #
   # bddimages_status::sql_nbimg
   # Permet de recuperer le nombre d images
   #
   proc sql_nbimg { } {

   set sqlcmd ""
   append sqlcmd "SELECT count(*) FROM images;"
   set err [catch {set status [::bddimages_sql::sql query $sqlcmd]} msg]
   if {$err} {
      ::console::affiche_resultat "ERREUR sql_nbimg\n"      
      ::console::affiche_resultat "  SQL : <$sqlcmd>\n"      
      ::console::affiche_resultat "  ERR : <$err>\n"      
      ::console::affiche_resultat "  MSG : <$msg>\n"      
      set status "Table 'images' inexistantes"
   }
   return $status
   }
   
   #
   # bddimages_status::sql_nbimg
   # Permet de recuperer le nombre d images
   #
   proc sql_header { } {

   set sqlcmd ""
   append sqlcmd "SELECT distinct idheader FROM header;"
   set err [catch {set status [::bddimages_sql::sql query $sqlcmd]} msg]
   if {$err} {
      ::console::affiche_resultat "ERREUR sql_nbimg\n"      
      ::console::affiche_resultat "  SQL : <$sqlcmd>\n"      
      ::console::affiche_resultat "  ERR : <$err>\n"      
      ::console::affiche_resultat "  MSG : <$msg>\n"      
      set status "Table 'header' inexistantes"
      return $status
   } else {
      set nb [llength $status]
      return $nb
   }
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



    proc GetPassword { msg } { 
    global getPassword 
    # getPassword est un tableau qui va contenir 3 entrées: 
    # name qui va contenir le nom de l'utilisateur 
    # passwd qui va contenir son mot de passe 
    # result qui va contenir 1 si et seulement si l'utilisateur a cliqué sur Ok 
    set getPassword(result) 0 
    set getPassword(passwd) "" 
    toplevel .passwd 
    wm title .passwd "Password" 
    wm maxsize .passwd 300 100 
    wm minsize .passwd 200 100 

    wm positionfrom .passwd user 
    wm sizefrom .passwd user 
    frame .passwd.f 
    pack configure .passwd.f -side top -fill both -expand 1 


    frame .passwd.f.pass 
    pack configure .passwd.f.pass -side top -fill x 
    # Frame qui va contenir le label "Type your password:" et une entrée pour le rentrer 
    label .passwd.f.pass.e -text $msg
    pack configure .passwd.f.pass.e -side left -anchor e

    frame .passwd.f.gpass
    pack configure .passwd.f.gpass -side top -fill x 
    entry .passwd.f.gpass.v -textvariable getPassword(passwd) -show "*" 
    pack configure .passwd.f.gpass.v -side bottom -anchor e
    # L'option -show permet de masquer la véritable entrée, et de mettre une étoile à la place des 
    # caractères entrés

    frame .passwd.f.buttons
    pack configure .passwd.f.buttons -side top -fill x 
    # Frame qui va contenir les boutons Cancel et Ok 
    button .passwd.f.buttons.cancel -text Cancel -command {destroy .passwd} 
    pack configure .passwd.f.buttons.cancel -side left 
    button .passwd.f.buttons.ok -text Ok -command {set getPassword(result) 1;destroy .passwd} 
    pack configure .passwd.f.buttons.ok -side right 
    grab set .passwd
    tkwait window .passwd 
    if {$getPassword(result)} { 
    return $getPassword(passwd) 
    } else { 
    return "" 
    } 
    }



   #
   # bddimages_status::razbdd
   # reinitialisation de la base;
   #
   proc razbdd { } {
      global caption
      global conf
  

         set answer [tk_messageBox -title $caption(bddimages_status,msg_prevent) -message $caption(bddimages_status,msg_prevent2) \
                 -icon question -type okcancel ]
         switch -- $answer {
             ok { set passwd [GetPassword $caption(bddimages_status,mdprootsql)]
                  # Supprime la bdd bddimages et la recree ainsi que les privileges utilisateurs
                  set status "ok"
                  set dblink [::mysql::connect -host $conf(bddimages,serv) -user root -password $passwd]

                  if {$status=="ok"} { 
                     set sqlcmd "DROP DATABASE IF EXISTS bddimages;"
                     set err [catch {::mysql::query $dblink $sqlcmd} msg]
                     if {$err} {
                       set status "Failed : \n <$sqlcmd> \n <$err> \n <$msg>"
                       } 
                     }
                  if {$status=="ok"} { 
                     set sqlcmd "CREATE DATABASE IF NOT EXISTS bddimages;"
                     set err [catch {::mysql::query $dblink $sqlcmd} msg]
                     if {$err} {
                        set status "Failed : \n <$sqlcmd> \n <$err> \n <$msg>"
                        } 
                     }
#                  if {$status=="ok"} { 
#                     set sqlcmd "GRANT ALL PRIVILEGES ON `bddimages` . * TO '$conf(login)'@'$conf(serv)' WITH GRANT OPTION ;"
#                     set err [catch {::mysql::query $dblink $sqlcmd} msg]
#                     if {$err} {
#                        set status "Failed : \n <$sqlcmd> \n <$err> \n <$msg>"
#                        } 
#                     }

                  ::mysql::close $dblink
                   unset dblink

                  tk_messageBox -message "$caption(bddimages_status,efface) \n Status : -$status-" -type ok

                  # Supprime le repertoire fits
                  set errnum [catch {file delete -force $conf(bddimages,dirfits)} msg]
                  if {$errnum==0} {
                    ::console::affiche_resultat "Effacement du repertoire : $conf(bddimages,dirfits) \n" 
                    set errnum [catch {file mkdir  $conf(bddimages,dirfits)} msg]
                    if {$errnum==0} {
                      ::console::affiche_resultat "Creation du repertoire : $conf(bddimages,dirfits) \n" 
                      } else {
                        ::console::affiche_resultat "ERREUR: Creation du repertoire : $conf(bddimages,dirfits) impossible <$errnum>\n"
                        }
                    } else {
                      ::console::affiche_resultat "ERREUR: Effacement du repertoire : $conf(bddimages,dirfits) impossible <$errnum>\n"
                      }

                  # Supprime le repertoire logs
                  set errnum [catch {file delete -force $conf(bddimages,dirlog)} msg]
                  if {$errnum==0} {
                    ::console::affiche_resultat "Effacement du repertoire : $conf(bddimages,dirlog) \n" 
                    set errnum [catch {file mkdir  $conf(bddimages,dirlog)} msg]
                    if {$errnum==0} {
                      ::console::affiche_resultat "Creation du repertoire : $conf(bddimages,dirlog) \n" 
                      } else {
                        ::console::affiche_resultat "ERREUR: Creation du repertoire : $conf(bddimages,dirlog) impossible <$errnum>\n"
                        }
                    } else {
                      ::console::affiche_resultat "ERREUR: Effacement du repertoire : $conf(bddimages,dirlog) impossible <$errnum>\n"
                      }
                  
                  # Supprime le repertoire probleme
                  set errnum [catch {file delete -force $conf(bddimages,direrr)} msg]
                  if {$errnum==0} {
                    ::console::affiche_resultat "Effacement du repertoire : $conf(bddimages,direrr) \n" 
                    set errnum [catch {file mkdir  $conf(bddimages,direrr)} msg]
                    if {$errnum==0} {
                      ::console::affiche_resultat "Creation du repertoire : $conf(bddimages,direrr) \n" 
                      } else {
                        ::console::affiche_resultat "ERREUR: Creation du repertoire : $conf(bddimages,direrr) impossible <$errnum>\n"
                        }
                    } else {
                      ::console::affiche_resultat "ERREUR: Effacement du repertoire : $conf(bddimages,direrr) impossible <$errnum>\n"
                      }
                  
               }
             }


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

      
      #--- Mise en forme du resultat
      set status    [::bddimages_sql::connect]
      set nbimg     [sql_nbimg] 
      set nbheader  [sql_header]
      set nbfichbdd [numberoffile $conf(bddimages,dirfits)]
      set nbfichinc [numberoffile $conf(bddimages,dirinco)]
      set nbficherr [numberoffile $conf(bddimages,direrr)]
      
      set erreur 0
       #--- Gestion des erreurs
      if { $erreur == "0"} {
#      if { $erreur == "0" && $status != "failed"} {}

         #---
         toplevel $This -class Toplevel
         wm geometry $This $bddconf(position_status)
         wm resizable $This 1 1
         wm title $This $caption(bddimages_status,main_title)
         wm protocol $This WM_DELETE_WINDOW { ::bddimages_status::fermer }


         #--- Cree un frame pour afficher le status de la base
         frame $This.frame1 -borderwidth 0 -cursor arrow
         pack $This.frame1 -in $This -anchor s -side top -expand 0 -fill x

           #--- Cree un label pour le titre
           label $This.frame1.titre  \
                 -text "$caption(bddimages_status,titre)"
           pack $This.frame1.titre \
                -in $This.frame1 -side top -padx 3 -pady 3

           #--- Cree un frame pour afficher les resultats
           frame $This.frame1.status \
                 -borderwidth 1 -relief raised -cursor arrow
           pack $This.frame1.status \
                -in $This.frame1 -side top -expand 0 -fill x -padx 1 -pady 1

           #--- Cree un label pour le status
           label $This.frame1.statusbdd -font $audace(font,en_tete_2) \
                -text "$caption(bddimages_status,label_bdd)"
           pack $This.frame1.statusbdd -in $This.frame1.status -side top -padx 3 -pady 1 -anchor w

             #--- Cree un frame pour afficher les intitules
             set intitle [frame $This.frame1.status.l -borderwidth 0]
             pack $intitle -in $This.frame1.status -side left

               #--- Cree un label pour le status
               label $intitle.ok -font $audace(font,en_tete_1) -padx 3 \
                     -text "$caption(bddimages_status,label_connect)"
               pack $intitle.ok -in $intitle -side top -padx 3 -pady 1 -anchor w
               #--- Cree un label pour le nb d image
               label $intitle.nbimg -font $audace(font,en_tete_1) \
                     -text "$caption(bddimages_status,label_nbimg)"
               pack $intitle.nbimg -in $intitle -side top -padx 3 -pady 1 -anchor w
               #--- Cree un label pour le nb de header
               label $intitle.header -font $audace(font,en_tete_1) \
                     -text "$caption(bddimages_status,label_nbheader)"
               pack $intitle.header -in $intitle -side top -padx 3 -pady 1 -anchor w

             #--- Cree un frame pour afficher les valeurs
             set inparam [frame $This.frame1.status.v -borderwidth 0]
             pack $inparam -in $This.frame1.status -side right -expand 1 -fill x

               #--- Cree un label pour le status
               label $inparam.ok \
                     -text $status -fg $color(green)
               if {$status != "Connecté"} { $inparam.ok configure -fg $color(red) }
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
           label $This.frame1.statusrep -font $audace(font,en_tete_2) \
                -text "$caption(bddimages_status,label_rep)"
           pack $This.frame1.statusrep -in $This.frame1.rep -side top -padx 3 -pady 1 -anchor w

             #--- Cree un frame pour afficher les intitules
             set intitle [frame $This.frame1.rep.l -borderwidth 0]
             pack $intitle -in $This.frame1.rep -side left

               #--- Cree un label pour le status
               label $intitle.nbimgrep -font $audace(font,en_tete_1) \
                     -text "$caption(bddimages_status,label_nbimgrep)" -anchor center
               pack $intitle.nbimgrep -in $intitle -side top -padx 3 -pady 1 -anchor center

               label $intitle.nbimginco -font $audace(font,en_tete_1) \
                     -text "$caption(bddimages_status,label_nbimginc)" -anchor center
               pack $intitle.nbimginco -in $intitle -side top -padx 3 -pady 1 -anchor center

               label $intitle.nbimgerr -font $audace(font,en_tete_1) \
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
              -command {::bddimages_status::razbdd}
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




proc list_diff_shift { ref test }  {
# retourne la liste test epurée de l intersection des deux listes
  foreach elemref $ref {
    set new_test ""
    foreach elemtest $test {
      if {$elemref!=$elemtest} {lappend new_test $elemtest} 
      }
    set test $new_test
    }

return $test
} 


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

  bddimages_sauve_fich "Obtention de la liste des fichiers sur le disque"
  globrdk $conf(bddimages,dirfits) $limit

  set err [catch {set maliste [lsort -increasing $maliste]} result]

  set list_file_dir $maliste

  if {$err} {bddimages_sauve_fich "Erreur de tri de la liste"}
       
  bddimages_sauve_fich "Obtention de la liste des fichiers sur le serveur sql"
  set sqlcmd "SELECT dirfilename,filename FROM images;"
  set err [catch {set resultsql [::bddimages_sql::sql query $sqlcmd]} msg]
  if {$err} {bddimages_sauve_fich "Erreur de lecture de la liste par SQL"}

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
  if {$err} {bddimages_sauve_fich "Erreur de lecture de la liste par SQL"}


  foreach line $resultsql {
    set idhd [lindex $line 0]
    set sqlcmd "SELECT count(*) FROM images WHERE idheader='$idhd';"
    set err [catch {set res_images [::bddimages_sql::sql query $sqlcmd]} msg]
    if {$err} {bddimages_sauve_fich "Erreur  SQL"}
    set sqlcmd "SELECT count(*) FROM images_$idhd;"
    set err [catch {set res_images_hd [::bddimages_sql::sql query $sqlcmd]} msg]
    if {$err} {bddimages_sauve_fich "Erreur  SQL"}
    if {$res_images_hd!=$res_images} {
      bddimages_sauve_fich "-- Header num : $idhd"
      # recupere la liste des idbddimg de images
      set sqlcmd "SELECT idbddimg FROM images WHERE idheader='$idhd';"
      set err [catch {set res_images [::bddimages_sql::sql query $sqlcmd]} msg]
      if {$err} {bddimages_sauve_fich "Erreur  SQL"}
      # recupere la liste des idbddimg de images_idhd
      set sqlcmd "SELECT idbddimg FROM images_$idhd;"
      set err [catch {set res_images_hd [::bddimages_sql::sql query $sqlcmd]} msg]
      if {$err} {bddimages_sauve_fich "Erreur  SQL"}
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

