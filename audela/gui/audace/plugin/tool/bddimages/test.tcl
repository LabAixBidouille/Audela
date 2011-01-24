# source audace/plugin/tool/bddimages/test.tcl
#
# Fichier        : test.tcl
# Description    : Test de fonctionnement de procedures
# Auteur         : Frédéric Vachier
# Mise à jour $Id: test.tcl,v 1.4 2011-01-24 00:35:08 jberthier Exp $
#

namespace eval testprocedure {
   global audace
   global bddconf
   global conf
   uplevel #0 "source \"[ file join $audace(rep_plugin) tool bddimages bddimages_sub_fichier.tcl ]\""

   if { [ package require dom ] == "2.6" } {
      interp alias {} ::dom::parse {} ::dom::tcl::parse
      interp alias {} ::dom::selectNode {} ::dom::tcl::selectNode
      interp alias {} ::dom::node {} ::dom::tcl::node
   }


   proc run {  } {

      test6
   }


proc notebook'add {w title} {
   set btn [button $w.top.b$title -text $title -command [list $w raise $title]]
   pack $btn -side left -ipadx 5
   set f [frame $w.f$title -relief raised -borderwidth 2]
   pack $f -fill both -expand 1
   $btn invoke
   bind $btn <3> "destroy {$btn}; destroy {$f}" ;# (1)
   return $f
}

proc notebook'raise {w title} {
   foreach i [winfo children $w.top] {$i config -borderwidth 0}
   $w.top.b$title config -borderwidth 1
   set frame $w.f$title
   foreach i [winfo children $w] {
       if {![string match *top $i] && $i ne $frame} {pack forget $i}
   }
   pack $frame -fill both -expand 1
}

proc notebook {w args} {
   frame $w
   pack [frame $w.top] -side top -fill x -anchor w
   rename $w _$w
   proc $w {cmd args} { #-- overloaded frame command
       set w [lindex [info level 0] 0]
       switch -- $cmd {
           add     {notebook'add   $w $args}
           raise   {notebook'raise $w $args}
           default {eval [linsert $args 0 _$w $cmd]}
       }
   }

   return $w
}




proc test2 { } {

global audace

option add *highlightThickness 0

tk_setPalette gray60

source [ file join $audace(rep_plugin) tool bddimages rnotebook.tcl ]

    toplevel .fix
    wm title .fix "Password"
    wm maxsize .fix 300 100
    wm minsize .fix 200 100
    wm geometry .fix 400x220

#destroy .fix.un
#destroy .fix.deux

set un .fix.un
set deux .fix.deux

frame $un -borderwidth 2 -relief raised
frame $deux -borderwidth 2 -relief raised

pack $un -side top -fill both -expand 1
pack $deux -side top -fill x

button $deux.xit -text "quit" -command {destroy .fix}
button $deux.conf -text "reconfigure" -command reconf

pack $deux.xit $deux.conf -side left -padx 10 -pady 5

set nn $un.n

Rnotebook:create $nn -tabs {on two three} -borderwidth 2

pack $nn -in $un -fill both -expand 1 -padx 10 -pady 10

set frm [Rnotebook:frame $nn 1]
label $frm.l1 -text "Welcome frame 1 !"
pack $frm.l1 -fill both -expand 1

set frm [Rnotebook:frame $nn 2]
label $frm.l2 -text "Good Morning frame 2 !"
pack $frm.l2 -fill both -expand 1

set frm [Rnotebook:frame $nn 3]
label $frm.l3 -text "Hello frame 3 !"
pack $frm.l3 -fill both -expand 1

proc reconf {} {
    set frm [Rnotebook:button $un.n 1]
    $frm configure -text "page one"
}



}


proc test1 { } {
   global conf

set list_file [globr $conf(bddimages,dirbase)/*]
::console::affiche_resultat "dirlis : $list_file\n"
set nbfile [llength $list_file]
::console::affiche_resultat "nb fichiers : $nbfile\n"

::console::affiche_resultat "-----------------\n"
set nbfichbdd [numberoffile $conf(bddimages,dirfits)]
::console::affiche_resultat "nb fichiers : $nbfichbdd\n"
::console::affiche_resultat "-----------------\n"


}

proc test3 { } {
   global conf
   set err [catch {set list_file [globr $conf(bddimages,dirfits)/*]} result]
   ::console::affiche_resultat "--liste fichiers :\n $list_file\n"

   set sqlcmd ""
   append sqlcmd "SELECT dirfilename,filename FROM images;"
   set err [catch {set status [::bddimages_sql::sql query $sqlcmd]} msg]
   if {$err} {
      ::console::affiche_resultat "ERREUR sql_nbimg\n"
      ::console::affiche_resultat "  SQL : <$sqlcmd>\n"
      ::console::affiche_resultat "  ERR : <$err>\n"
      ::console::affiche_resultat "  MSG : <$msg>\n"
      set status "Table 'header' inexistantes"
   }
    set res {}
    foreach i $status {
      set dir [lindex $i 0]
      set file [lindex $i 1]
      eval lappend res "$conf(bddimages,dirbase)/$dir/$file"
    }
   ::console::affiche_resultat "--liste mysql :\n $res\n"

   ::console::affiche_resultat "-- verif 1 \n"

    foreach i $res {
      set exist 0
      foreach j $list_file {
        if {$i==$j} {
	set exist 1
	}
      }
      if {$exist==0} {
        ::console::affiche_resultat "$i n existe pas sur le disque \n"
      }

    }

   ::console::affiche_resultat "-- verif 2 \n"

    foreach i $list_file {
      set exist 0
      foreach j $res {
        if {$i==$j} {
	set exist 1
	}
      }
      if {$exist==0} {
        ::console::affiche_resultat "$i n existe pas dans la base \n"
      }

    }

}

proc test4 { } {
   global conf
   global maliste

 #set list_file [globrd $conf(bddimages,dirinco)/*]
# set nbfile [llength $list_file]
#::console::affiche_resultat "nb fichiers : $nbfile\n"

#::console::affiche_resultat "-----------------\n"

# set list_file [globrlimit $conf(bddimages,dirinco)/*]
#::console::affiche_resultat "dirlis : $list_file\n"
# set nbfile [llength $list_file]
#::console::affiche_resultat "nb fichiers  : $nbfile\n"

#::console::affiche_resultat "-----------------\n"

 set maliste {}
 set list_file [globrdk $conf(bddimages,dirinco)/*]
 set nbfile [llength $maliste]
 ::console::affiche_resultat "dirlis : $maliste \n"
 ::console::affiche_resultat "---------------------------\n"
 ::console::affiche_resultat "nb fichiers k: $nbfile \n"
 ::console::affiche_resultat "---------------------------\n"

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


proc test5 { } {

   global maliste
   global conf

  set list_file_dir ""
  set list_file_sql ""

  set limit 5000
  set maliste {}
  globrdk $conf(bddimages,dirfits) $limit

  set err [catch {set maliste [lsort -increasing $maliste]} result]

  set list_file_dir $maliste

  if {$err} {bddimages_sauve_fich "Erreur de tri de la liste"}

  set sqlcmd "SELECT dirfilename,filename FROM images;"
  set err [catch {set resultsql [::bddimages_sql::sql query $sqlcmd]} msg]
  if {$err} {bddimages_sauve_fich "Erreur de lecture de la liste par SQL"}


  foreach line $resultsql {
    set dir [lindex $line 0]
    set fic [lindex $line 1]
    lappend list_file_sql "$conf(bddimages,dirbase)/$dir/$fic"
    }

  set new_list_sql [list_diff_shift $list_file_dir $list_file_sql]
  set new_list_dir [list_diff_shift $list_file_sql $list_file_dir]

  bddimages_sauve_fich ""
  bddimages_sauve_fich "*** Verification des données *** "
  bddimages_sauve_fich ""
  bddimages_sauve_fich "  Nombre d'images absentes sur le serveur SQL : [llength $new_list_sql]"
  bddimages_sauve_fich ""
  foreach elemsql $new_list_sql { bddimages_sauve_fich $elemsql }
  bddimages_sauve_fich ""
  bddimages_sauve_fich "  Nombre d'images absentes sur le disque : [llength $new_list_dir]"
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

proc test6 { } {

   global maliste
   global conf

  set limit 0
  set maliste {}
  globrdk $conf(bddimages,dirfits) $limit
  ::console::affiche_resultat "  Nombre d'images dans $conf(bddimages,dirfits) [llength $maliste]"
}


proc test7 { } {
   
   package require tdom
   
   set doc [dom createDocument example]
 
   set root [$doc documentElement]
   $root setAttribute version 1.0
 
   set node [$doc createElement description]
   $node appendChild [$doc createTextNode "Date and Time"]
   $root appendChild $node
 
   set subnode [$doc createElement dt]
   $root appendChild $subnode
 
   set node [$doc createElement date]
   $node appendChild [$doc createTextNode 2006-12-03]
   $subnode appendChild $node
 
   set node [$doc createElement time]
   $node appendChild [$doc createTextNode 09:22:14]
   $subnode appendChild $node
 
   set fxml [open "/tmp/toto.xml" "w"]
   puts $fxml [$root asXML]
   close $fxml

}

}
# fin du namespace

