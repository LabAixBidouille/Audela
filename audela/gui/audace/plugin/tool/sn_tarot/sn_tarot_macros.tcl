#
# Fichier : sn_tarot_macros.tcl
# Description : Macros des scripts pour la recherche de supernovae
# Auteur : Alain KLOTZ et Raymond ZACHANTKE
# Mise à jour $Id$
#

#--   Liste des proc
# ::sn_tarot::snGalaxyCenter
# ::sn_tarot::snStarRef
# ::sn_tarot::snCandidate
# ::sn_tarot::snCreateCandidateId
# ::sn_tarot::searchinArchives
# ::sn_tarot::SNChecker
# ::sn_tarot::MPChecker
# ::sn_tarot::prevnight
# ::sn_tarot::snVerifWCS
# ::sn_tarot::snCenterRaDec
# ::sn_tarot::getImgCenterRaDec


proc ::sn_tarot::snGalaxyCenter { } {
   global snvisu snconfvisu num

   set afflog  "$snvisu(afflog)"
   if { $afflog==0 } {
      set bufNo $num(buffer1)
   } else {
     set bufNo $num(buffer1b)
   }
   set res [snVerifWCS $bufNo]
   if {$res==0} {
      return ""
   }
   set x [lindex $snvisu(candidate,xy) 0]
   set y [lindex $snvisu(candidate,xy) 1]
   set x [expr $x/$snconfvisu(zoom_normal)]
   set y [expr $y/$snconfvisu(zoom_normal)]
   set radec [buf$bufNo xy2radec [list $x $y]]
   set ra [lindex $radec 0]
   set dec [lindex $radec 1]
   set ra [mc_angle2hms $ra 360 zero 1 auto string]
   set dec [mc_angle2dms $dec 90 zero 0 + string]
   set snvisu(candidate,host_coords) "$ra $dec"
}

proc ::sn_tarot::snStarRef { } {
   global snvisu snconfvisu num

   set afflog "$snvisu(afflog)"
   if { $afflog==0 } {
      set bufNo $num(buffer1)
   } else {
      set bufNo $num(buffer1b)
   }
   set res [snVerifWCS $bufNo]
   if {$res==0} {
      return ""
   }
   set x [lindex $snvisu(candidate,xy) 0]
   set y [lindex $snvisu(candidate,xy) 1]
   set x [expr $x/$snconfvisu(zoom_normal)]
   set y [expr $y/$snconfvisu(zoom_normal)]
   set radec [buf$bufNo xy2radec [list $x $y]]
   set ra [lindex $radec 0]
   set dec [lindex $radec 1]
   set ra [mc_angle2hms $ra 360 zero 1 auto string]
   set dec [mc_angle2dms $dec 90 zero 0 + string]
   set snvisu(candidate,starref_coords) "$ra $dec"
}

proc ::sn_tarot::snCandidate { } {
   global snvisu snconfvisu num

   set afflog "$snvisu(afflog)"
   if { $afflog==0 } {
      set bufNo $num(buffer1)
   } else {
      set bufNo $num(buffer1b)
   }
   set res [snVerifWCS $bufNo]
   if {$res==0} {
      return ""
   }
   set x [lindex $snvisu(candidate,xy) 0]
   set y [lindex $snvisu(candidate,xy) 1]
   set x [expr $x/$snconfvisu(zoom_normal)]
   set y [expr $y/$snconfvisu(zoom_normal)]
   set radec [buf$bufNo xy2radec [list $x $y]]
   set ra [lindex $radec 0]
   set dec [lindex $radec 1]
   set ra [mc_angle2hms $ra 360 zero 1 auto string]
   set dec [mc_angle2dms $dec 90 zero 0 + string]
   set snvisu(candidate,sn_coords) "$ra $dec"
}

proc ::sn_tarot::snCreateCandidateId { } {
   global audace snvisu snconfvisu num caption rep

   set textes ""

   #--   fenetre de sortie
   set fcand $audace(base).snvisu_cand

   if { [ winfo exists $fcand ] } {
      destroy $fcand
   }

   #--- Create the toplevel window .snvisu_cand
   #--- Cree la fenetre .snvisu_cand de niveau le plus haut
   toplevel $fcand -class Toplevel
   wm title $fcand $caption(sn_tarot,candidate)
   regsub -all {[\+|x]} [ wm geometry $audace(base).snvisu ]  " " pos
   wm geometry $fcand 600x600+[expr {[ lindex $pos 1 ] + 20 } ]+[ expr {[ lindex $pos 2 ] + 0} ]
   wm resizable $fcand 1 1
   wm transient $fcand $audace(base).snvisu
   wm protocol $fcand WM_DELETE_WINDOW "destroy $fcand"

   #--- Create the label and the radiobutton
   #--- Cree l'etiquette et les radiobuttons
   frame $fcand.frame1 -borderwidth 0 -relief raised
      #--- Label
      label $fcand.frame1.label -text "$caption(sn_tarot,candidate) in [file rootname $snvisu(name)]" \
         -borderwidth 0 -relief flat
      pack $fcand.frame1.label -fill x -side left -padx 5 -pady 5
   pack $fcand.frame1 -side top -fill both -expand 0

   #--- cree un acsenseur vertical pour la console de retour d'etats
   frame $fcand.fra1
      scrollbar $fcand.fra1.scr1 -orient vertical \
         -command "$fcand.fra1.lst1 yview" -takefocus 0 -borderwidth 1
      pack $fcand.fra1.scr1 \
         -in $fcand.fra1 -side right -fill y
      set snvisu(status_scrl) $fcand.fra1.scr1

      scrollbar $fcand.fra1.scr2 -orient horizontal \
         -command "$fcand.fra1.lst1 xview" -takefocus 0 -borderwidth 1
      pack $fcand.fra1.scr2 \
         -in $fcand.fra1 -side bottom -fill x
      set snvisu(status_scrlx) $fcand.fra1.scr2

      #--- cree la console de retour d'etats
      text $fcand.fra1.lst1 \
         -borderwidth 1 -relief sunken  -height 6 -font {courier 8 bold} \
         -yscrollcommand "$fcand.fra1.scr1 set"  -xscrollcommand "$fcand.fra1.scr2 set" -wrap none
      pack $fcand.fra1.lst1 \
         -in $fcand.fra1 -expand yes -fill both \
         -padx 3 -pady 3
      set snvisu(status_list) $fcand.fra1.lst1
   pack $fcand.fra1 -side top -fill both -expand 1

   $snvisu(status_list) insert end "$caption(sn_tarot,cand_wait)\n"
   $snvisu(status_list) yview moveto 1.0
   update

   #--- Create the button 'Modify'
   #--- Cree le bouton 'Modify'
   button $fcand.but_modify -text $caption(sn_tarot,modify) \
      -borderwidth 2 -command {
         global snvisu audace
         set res [$snvisu(status_list) dump -text 1.0 end]
         set snvisu(candidate,textes) ""
         set n [llength $res]
         for {set k 1} {$k<$n} {incr k 3} {
            #::console::affiche_resultat "[lindex $res $k]"
            append snvisu(candidate,textes) [lindex $res $k]
         }
         set fichier "$snvisu(candidate,candidate_file)"
         set f [open $fichier w]
         puts -nonewline $f $snvisu(candidate,textes)
         close $f
       }
   pack $fcand.but_modify -side left -anchor w -padx 5 -pady 5
   $fcand.but_modify configure  -state disabled

   #--- Create the button 'OK'
   #--- Cree le bouton 'OK'
   button $fcand.but_ok -text $caption(sn_tarot,ok) -width 8 \
      -borderwidth 2 -command "destroy $audace(base).snvisu_cand"
   pack $fcand.but_ok -side right -anchor w -padx 5 -pady 5
   $fcand.but_ok configure  -state disabled

   #--- La fenetre est active
   focus $fcand

   #--- Mise a jour dynamique des couleurs
   ::confColor::applyColor $fcand

   # --- calculs
   set bufNo $num(buffer1)
   set ra_host [lindex $snvisu(candidate,host_coords) 0]
   set dec_host [lindex $snvisu(candidate,host_coords) 1]
   set ra_starref [lindex $snvisu(candidate,starref_coords) 0]
   set dec_starref [lindex $snvisu(candidate,starref_coords) 1]
   set ra_sn [lindex $snvisu(candidate,sn_coords) 0]
   set dec_sn [lindex $snvisu(candidate,sn_coords) 1]
   set pi [expr 4*atan(1.)]
   set dec [expr [mc_angle2deg $dec_host 90]*$pi/180.]
   set cosdec [expr cos($dec)]
   set dra [expr ([mc_angle2deg $ra_sn]-[mc_angle2deg $ra_host])*3600.]
   set ddec [expr ([mc_angle2deg $dec_sn 90]-[mc_angle2deg $dec_host 90])*3600.]
   set dratan [expr $dra/$cosdec]
   if {$dratan<0} { set sensew W } else { set sensew E }
   set dratan [expr abs($dratan)]
   if {$ddec<0} { set sensns S } else { set sensns N }
   set ddec [expr abs($ddec)]
   # --- taille de la fenetre de mesure
   set cdelt2 [lindex [buf$bufNo getkwd CDELT2] 1]
   set ech [expr abs($cdelt2)*3600]
   set dbox [expr int(10./$ech)]
   set exptime [lindex [buf$bufNo getkwd EXPOSURE] 1]
   # --- flux de l'etoile de reference
   set err [catch {vo_neareststar $ra_starref $dec_starref} starref]
   set err2 1
   if {$err==0} {
      set magoff 0
      set magr [lindex [lindex $starref 0] 5]
      set err2 [catch {expr $magr} magr]
   }
   if {($err==0)&&($err2==0)} {
      set mag_ref [expr $magr+$magoff]
      set xy [buf$bufNo radec2xy [list [mc_angle2deg $ra_starref] [mc_angle2deg $dec_starref 90]]]
      set x [lindex $xy 0]
      set y [lindex $xy 1]
      set x1 [expr int($x-$dbox/2)] ; set x2 [expr $x1+$dbox]
      set y1 [expr int($y-$dbox/2)] ; set y2 [expr $y1+$dbox]
      set box [list $x1 $y1 $x2 $y2]
      set valeurs [ buf$bufNo fitgauss $box ]
      set dif 0.
      set intx [lindex $valeurs 0]
      set xc [lindex $valeurs 1]
      set fwhmx [lindex $valeurs 2]
      set bgx [lindex $valeurs 3]
      set inty [lindex $valeurs 4]
      set yc [lindex $valeurs 5]
      set fwhmy [lindex $valeurs 6]
      set bgy [lindex $valeurs 7]
      set if0 [ expr $fwhmx*$fwhmy*.601*.601*3.14159265 ]
      set if1 [ expr $intx*$if0 ]
      set if2 [ expr $inty*$if0 ]
      set if0 [ expr ($if1+$if2)/2. ]
      set dif [ expr abs($if1-$if0) ]
      set flux_ref $if0
   } else {
      set flux_ref [expr 5000.*$exptime/240.]
      set mag_ref 15.4
   }
   # --- flux de l'etoile du GRB
   set xy [buf$bufNo radec2xy [list [mc_angle2deg $ra_sn] [mc_angle2deg $dec_sn 90]]]
   set x [lindex $xy 0]
   set y [lindex $xy 1]
   set x1 [expr int($x-$dbox/2)] ; set x2 [expr $x1+$dbox]
   set y1 [expr int($y-$dbox/2)] ; set y2 [expr $y1+$dbox]
   set box [list $x1 $y1 $x2 $y2]
   set valeurs [ buf$bufNo fitgauss $box ]
   set dif 0.
   set intx [lindex $valeurs 0]
   set xc [lindex $valeurs 1]
   set fwhmx [lindex $valeurs 2]
   set bgx [lindex $valeurs 3]
   set inty [lindex $valeurs 4]
   set yc [lindex $valeurs 5]
   set fwhmy [lindex $valeurs 6]
   set bgy [lindex $valeurs 7]
   set if0 [ expr $fwhmx*$fwhmy*.601*.601*3.14159265 ]
   set if1 [ expr $intx*$if0 ]
   set if2 [ expr $inty*$if0 ]
   set if0 [ expr ($if1+$if2)/2. ]
   set dif [ expr abs($if1-$if0) ]
   set flux_sn $if0
   set intxy [expr ($intx+$inty)/2.]
   set sigma [lindex [buf$bufNo stat $box] 7]
   set snr [expr $intxy/$sigma]
   set dmag [expr 1.1/$snr]
   # --- magnitude
   set mag [expr $mag_ref-2.5*log10($flux_sn/$flux_ref)]
   #
   set date [lindex [buf$bufNo getkwd DATE-OBS] 1]
   set dateref [lindex [buf$num(buffer2) getkwd DATE-OBS] 1]
   set telescop [lindex [buf$bufNo getkwd TELESCOP] 1]
   if {$telescop=="TAROT CALERN"} { set telescop "TAROT Calern observatory, France" ; set codmpc 910 }
   if {$telescop=="TAROT CHILI"} { set telescop "TAROT La Silla observatory, Chile" ; set codmpc 809 }
   #
   set ra [mc_angle2hms $ra_sn 360 zero 2 auto list]
   set dec [mc_angle2dms $dec_sn 90 zero 1 + list]
   set ra_sn [lindex $ra 0]h[lindex $ra 1]m[lindex $ra 2]s
   set dec_sn "[lindex $dec 0]o[lindex $dec 1]'[lindex $dec 2]\""
   set radec_sn "[lindex $ra 0] [lindex $ra 1] [lindex $ra 2] [lindex $dec 0] [lindex $dec 1] [lindex $dec 2]"
   set ra [mc_angle2hms $ra_host 360 zero 2 auto list]
   set dec [mc_angle2dms $dec_host 90 zero 1 + list]
   set ra_host [lindex $ra 0]h[lindex $ra 1]m[lindex $ra 2]s
   set dec_host "[lindex $dec 0]o[lindex $dec 1]'[lindex $dec 2]\""
   set radec_host "[lindex $ra 0] [lindex $ra 1] [lindex $ra 2] [lindex $dec 0] [lindex $dec 1] [lindex $dec 2]"
   #
   $snvisu(status_list) insert end "$caption(sn_tarot,cand_wait_mp)\n"
   $snvisu(status_list) yview moveto 1.0
   update
   set minorplanets [::sn_tarot::MPChecker $date $ra_host $dec_host $codmpc]
   $snvisu(status_list) insert end "$caption(sn_tarot,cand_wait_sn)\n"
   $snvisu(status_list) yview moveto 1.0
   update
   set recentsupernovae [::sn_tarot::SNChecker $date $ra_sn $dec_sn]
   #
   append textes "------------------------------------------\n"
   set texte "Personal comment about this candidate :"
   append textes "$texte\n\n"
   append textes "------------------------------------------\n"
   set texte "Example of email :"
   append textes "$texte\n\n"
   set texte "Send to: cbat@cfa.harvard.edu and copies to dgreen@cfa.harvard.edu & green@cfa.harvard.edu"
   append textes "$texte\n\n"
   set texte "Title: SN in [file rootname $snvisu(name)]"
   append textes "$texte\n\n"
   set texte "X. YYYYY on behalf of the TAROT Collaboration"
   append textes "$texte\n"
   set texte "reports the discovery of an apparent"
   append textes "$texte\n"
   set texte "supernova (mag about [format %.1f $mag] +/- [format %.1f $dmag]) on $date"
   append textes "$texte\n"
   set texte "using public images of the 0.25m robotic telescope"
   append textes "$texte\n"
   set texte "${telescop}."
   append textes "$texte\n"
   set texte "SN is located at about R.A. = $ra_sn, Decl. = $dec_sn"
   append textes "$texte\n"
   set texte "(equinox J2000.0), which is [format %.0f $dratan]\" $sensew and [format %.0f $ddec]\" $sensns from the nucleus of"
   append textes "$texte\n"
   set texte "[file rootname $snvisu(name)] ($ra_host $dec_host)."
   append textes "$texte\n"
   set texte "The supernova does not appear in an image taken $dateref."
   append textes "$texte\n"
   append textes "\n"
   append textes "------------------------------------------\n"
   set texte "Check minor planets from MPC Checker:"
   append textes "$texte\n\n"
   set texte "$minorplanets"
   append textes "$texte\n"
   append textes "\n"
   append textes "------------------------------------------\n"
   set texte "Check recent supernovae from CBAT:"
   append textes "$texte\n\n"
   set texte "$recentsupernovae"
   append textes "$texte\n"
   #
   $snvisu(status_list) insert end "$caption(sn_tarot,cand_wait_ar)\n"
   $snvisu(status_list) yview moveto 1.0
   update
   set fichiers [lsort -decreasing [::sn_tarot::searchinArchives [file rootname $snvisu(name)]]]
   #
   append textes "\n"
   append textes "------------------------------------------\n"
   set texte "List of archives containing this galaxy:"
   append textes "$texte\n"
   foreach fichier $fichiers {
      set texte "$fichier"
      append textes "$texte\n"
   }
   #
   append textes "\n"
   append textes "------------------------------------------\n"
   set texte "Details of computation:"
   append textes "$texte\n"
   set texte "snvisu(candidate,host_coords)=$snvisu(candidate,host_coords)"
   append textes "$texte\n"
   set texte "snvisu(candidate,starref_coords)=$snvisu(candidate,starref_coords)"
   append textes "$texte\n"
   set texte "snvisu(candidate,sn_coords)=$snvisu(candidate,sn_coords)"
   append textes "$texte\n"
   set texte "sampling=$ech arcsec/pix"
   append textes "$texte\n"
   set texte "starref=$starref"
   append textes "$texte\n"
   set texte "mag_ref=$mag_ref flux_ref=$flux_ref exptime=$exptime"
   append textes "$texte\n"
   set texte "mag=$mag flux_sn=$flux_sn"
   append textes "$texte\n"
   set texte "radec_host=$radec_host"
   append textes "$texte\n"
   #
   ::console::affiche_resultat "\n$textes"
   set candidate_file "[file rootname $snvisu(name)]_$snconfvisu(night)"
   set path "$rep(archives)/../alert"
   file mkdir $path
   set snvisu(candidate,candidate_file) [file normalize "$path/${candidate_file}.txt"]
   set snvisu(candidate,textes) "$textes"
   set fichier "$snvisu(candidate,candidate_file)"
   set f [open $fichier w]
   puts -nonewline $f $snvisu(candidate,textes)
   close $f

   $snvisu(status_list) delete 1.0 end
   $snvisu(status_list) insert end "$textes"
   $snvisu(status_list) yview moveto 0.0
   $fcand.but_modify configure  -state normal
   $fcand.but_ok configure  -state normal
   $fcand.frame1.label configure -text $snvisu(candidate,candidate_file)
   $fcand.fra1.lst1 configure -font {courier 8 bold}
   update
}

#------------------------------------------------------------
# searchinArchives
#    Recherche les fichiers du dossier archives repondant au nom d'une galaxie en particulier,
#    en excluant refgaltarot. Utile pour rechercher les images d'une candidate
#------------------------------------------------------------
proc ::sn_tarot::searchinArchives { name } {
   global audace rep

   #--   chemin de unzip.exe
   set tarot_unzip [ file join $audace(rep_plugin) tool sn_tarot unzip.exe ]

   set name [ string toupper $name ].fit
   set fichiers ""
   foreach archive $rep(list_archives) {
      set contents [ exec $tarot_unzip -l [ file join $rep(archives) $archive ] ]
      set k [ string first $name $contents ]
      if { $k>0 } { lappend fichiers $archive }
   }
   return $fichiers
}

#------------------------------------------------------------
# ::sn_tarot::SNChecker
#    Appel au Cheker SN des supernovae
#------------------------------------------------------------
# source $audace(rep_install)/gui/audace/plugin/tool/sn_tarot/sn_tarot_macros.tcl ; package require http
# set lignes [::sn_tarot::SNChecker {2012 01 06.96} 03h38m51.5s -35d35'33"]
proc ::sn_tarot::SNChecker { date ra dec } {
   global panneau caption

   set ra_cand [mc_angle2deg $ra ]
   set dec_cand [mc_angle2deg $dec 90 ]
   set url http://www.cbat.eps.harvard.edu/lists/RecentSupernovae.html
   if { [catch { set tok [ ::http::geturl $url ] } ErrInfo ] } {
      return "No internet connection."
   }

   upvar #0 $tok state

  if { [ ::http::status $tok ] != "ok" } {
      return "Problem while reading the html code."
   }

   #--   verifie le contenu
   set key [ string range [ ::http::data $tok ] 0 4 ]

   if { $key == "<?xml" } {
      return "Problem while decoding the html code."
   }

   set lignes [::http::data $tok ]
   ::http::cleanup $tok

   set np 0
   set planets ""
   append planets "SN      Host Galaxy      Date         R.A.    Decl.    Offset   Mag.   Disc. Ref.            SN Position         Posn. Ref.       Type  SN      Discoverer(s)\n"
   set lignes [regsub -all \" $lignes " "]
   set lignes [regsub -all \{ $lignes " "]
   set lignes [regsub -all \} $lignes " "]
   set lignes [split $lignes \n]
   set n [llength $lignes]
   set valid 0
   for {set k 0} {$k<$n} {incr k} {
      set ligne [lindex $lignes $k]
      #::console::affiche_resultat "A <$ligne>\n"
      if {$ligne==""} { continue }
      set key1 [lindex $ligne 0]
      set key2 [lindex $ligne 1]
      if {($key1=="SN")&&($key2=="Host")} {
         set valid 1
         incr k 1
         continue
      }
      if {($key1=="</pre>")} {
         break
      }
      if {$valid>=1} {
         #          1         2         3         4         5         6         7         8         9        10
         # 123456789 123456789 123456789 123456789 123456789 123456789 123456789 123456789 123456789 123456789 123456789 123456789
         #2011jx  Anon.            2011 12 29  10 29.1 +46 05
         #SN      Host Galaxy      Date         R.A.    Decl.    Offset   Mag.   Disc. Ref.            SN Position         Posn. Ref.       Type  SN      Discoverer(s)
         #2011iv  NGC 1404         2011 12 02  03 38.9 -35 36    7W   8N  12.8   CBET 2940       03 38 51.35 -35 35 32.0   CBET 2940        Ia    2011iv  Parker

         # --- on enleve les balises <>
         set k2 [string first < $ligne]
         set reste [string range $ligne [expr $k2+1] end]
         set newligne ""
         for {set kk 0} {$kk<20} {incr kk } {
            set k1 [string first > $reste]
            set k2 [string first < $reste]
            if {$k2==-1} {
               set isole [string range $reste [expr $k1+1] end]
            } else {
               set isole [string range $reste [expr $k1+1] [expr $k2-1]]
            }
            append newligne "$isole"
            if {$k2==-1} { break }
            set reste [string range $reste [expr $k2+1] end]
         }
         set ligne $newligne
         set ra  [mc_angle2deg [string range $ligne 87  88]h[string range $ligne  90  91]m[string range $ligne  93  97]s ]
         set dec [mc_angle2deg [string range $ligne 99 101]d[string range $ligne 103 104]m[string range $ligne 106 109]s 90 ]
         set sep_arcmin [expr 60*[lindex [mc_sepangle $ra $dec $ra_cand $dec_cand] 0]]
         #::console::affiche_resultat "[lindex $ligne 0] sep_arcmin=$sep_arcmin    ($ra $dec $ra_cand $dec_cand)\n"
         if {$sep_arcmin<3} {
            append planets "$ligne\n"
            incr np
         }
         incr valid
      }
   }
   if {$np==0} {
      set planets "No recent supernova found from CBAT."
   }
   return $planets
}

#------------------------------------------------------------
# ::sn_tarot::MPChecker
#    Appel au Cheker MPC des asteroides
# set lignes [::sn_tarot::MPChecker {2012 01 06.96} {10 34 67 h} {3 45 10}]
#------------------------------------------------------------
proc ::sn_tarot::MPChecker { date ra dec {obscod 500} } {

   #set date {2012 01 06.96}
   #set ra {10 34 67 h}
   #set dec {3 45 10}
   #set obscod 500
   set res [mc_date2ymdhms $date]
   set y [lindex $res 0]
   set m [lindex $res 1]
   set d [format %.2f [expr 1.*[lindex $res 2]+[lindex $res 3]/24.+[lindex $res 4]/1440.+[lindex $res 5]/86400.]]
   set ra [mc_angle2hms $ra 360 zero 2 auto list]
   set dec [mc_angle2dms $dec 90 zero 1 auto list]
   #::console::affiche_resultat "<ra=$ra> <dec=$dec>\n"
   set radius 10
   set url http://mpcapp1.cfa.harvard.edu/cgi-bin/mpcheck.cgi
   set query [::http::formatQuery year $y month $m day $d which pos ra $ra decl $dec TextArea {} radius $radius limit 22 oc $obscod sort d mot m tmot t pdes u needed f ps n type p]
   #::console::affiche_resultat "< $query >\n"

   if { [catch { set tok [ ::http::geturl $url -query $query ] } ErrInfo ] } {
      return "No internet connection."
   }

   upvar #0 $tok state

  if { [ ::http::status $tok ] != "ok" } {
      return "Problem while reading the html code."
   }

   #--   verifie le contenu
   set key [ string range [ ::http::data $tok ] 0 4 ]

   if { $key == "<?xml" } {
      return "Problem while decoding the html code."
   }

   set lignes [::http::data $tok ]
   ::http::cleanup $tok

   set np 0
   set planets ""
   append planets " Object designation         R.A.      Decl.     V       Offsets     Motion/min  Orbit  Further observations?\n"
   append planets "                           h  m  s     d  '  \"        R.A.   Decl.  Mot.   PA          Comment (Elong/Decl/V at date 1)\n"
   set lignes [regsub -all \" $lignes " "]
   set lignes [split $lignes \n]
   set n [llength $lignes]
   set valid 0
   for {set k 0} {$k<$n} {incr k} {
      set ligne [lindex $lignes $k]
      set key1 [lindex $ligne 0]
      set key2 [lindex $ligne 1]
      if {($key1=="Object")&&($key2=="designation")} {
         set valid 1
         incr k 2
         continue
      }
      if {($key1=="</pre>")} {
         break
      }
      if {$valid==1} {
         #::console::affiche_resultat "$ligne\n"
         append planets "$ligne\n"
         incr np
      }
   }
   if {$np==0} {
      set planets "No minor planet found in the image."
   }
   return $planets
}

#------------------------------------------------------------
# ::sn_tarot::prevnight
#  Retourne la date de la nuit courante et le creneau horaire
#  Lancee par
#------------------------------------------------------------
proc ::sn_tarot::prevnight { home } {

   set date [::audace::date_sys2ut]
   set jd [mc_date2jd $date]
   set elev_sun_set 0
   set elev_sun_twilight 0
   set res [mc_nextnight $date $home $elev_sun_set $elev_sun_twilight]
   set mer2mer [lindex $res 0]
   set rise2rise [lindex $res 1]
   set prev_sun_rise [lindex $rise2rise 0]
   set mer [lindex $rise2rise 1]
   set sun_set [lindex $rise2rise 2]
   set dusk [lindex $rise2rise 3]
   set dawn [lindex $rise2rise 4]
   set next_sun_rise [lindex $rise2rise 5]
   if {$jd<$sun_set} {
      set skylight Day
   } elseif {$jd<$dusk} {
      set skylight Dusk
   } elseif {$jd<$dawn} {
      set skylight Night
   } else {
      set skylight Dawn
   }
   set res [mc_date2ymdhms [expr $prev_sun_rise-1]]
   set res "[format %04d [lindex $res 0]][format %02d [lindex $res 1]][format %02d [lindex $res 2]]"
   return [list $res $skylight]
}

proc ::sn_tarot::snVerifWCS { bufNo } {

   set calib 1
   foreach kwd [ list CRPIX1 CRPIX2 CRVAL1 CRVAL2 ] {
      if { [ lindex [buf$bufNo getkwd $kwd ] 0 ] eq ""} {  set calib 0 }
   }
   set nouveau 0
   foreach kwd [ list CD1_1 CD1_2 CD2_1 CD2_2 ] {
      if { [ lindex [buf$bufNo getkwd $kwd ] 0 ] != ""} { incr nouveau }
   }
   set classic 0
   foreach kwd [ list CDELT1 CDELT2 CROTA1 CROTA2 ] {
      if { [ lindex [buf$bufNo getkwd $kwd ] 0] != ""} { incr classic }
   }

   if {(($calib == 1)&&($nouveau==4)) || (($calib == 1)&&($classic>=3)) } {
      return 1
   } else {
      return 0
   }
}

proc ::sn_tarot::snCenterRaDec { bufNo } {

   set res [snVerifWCS $bufNo]
   if {$res==0} {
      return ""
   }
   set x [expr [buf$bufNo getpixelswidth]/2.]
   set y [expr [buf$bufNo getpixelsheight]/2.]
   set radec [buf$bufNo xy2radec [list $x $y]]
   set ra [lindex $radec 0]
   set dec [lindex $radec 1]
   set ra [mc_angle2hms $ra 360 zero 2 auto list]
   set dec [mc_angle2dms $dec 90 zero 1 + list]
   return "{ $ra $dec }"
}

#------------------------------------------------------------
#  ::sn_tarot::getImgCenterRaDec
#  Retourne la liste des coordonnees RaDec du centre de l'image
#  et le champ de l'image en degres
#  Parametres : naxis1 naxis2 crota2 cdelt1 cdelt2 crpix1 crpix2 crval1 crval2
#  issus des mot cles d'une image (les valeurs angulaires sont en degres)
#  Lancee par ::sn_tarot::listRequest
#------------------------------------------------------------
proc ::sn_tarot::getImgCenterRaDec { naxis1 naxis2 crota2 cdelt1 cdelt2 crpix1 crpix2 crval1 crval2 } {

   set pi [ expr {4*atan(1)} ]
   set coscrota2 [expr cos($crota2*$pi/180.)]
   set sincrota2 [expr sin($crota2*$pi/180.)]
   set cd11 [expr $pi/180*($cdelt1*$coscrota2)]
   set cd12 [expr $pi/180*(abs($cdelt2)*$cdelt1/abs($cdelt1)*$sincrota2)]
   set cd21 [expr $pi/180*(-abs($cdelt1)*$cdelt2/abs($cdelt2)*$sincrota2)]
   set cd22 [expr $pi/180*($cdelt2*$coscrota2)]

   set x [expr $naxis1/2.]
   set y [expr $naxis2/2.]
   set dra  [expr $cd11*($x-($crpix1-0.5)) + $cd12*($y-($crpix2-0.5))]
   set ddec [expr $cd21*($x-($crpix1-0.5)) + $cd22*($y-($crpix2-0.5))]
   set coscrval2 [expr cos($crval2*$pi/180.)]
   set sincrval2 [expr sin($crval2*$pi/180.)]
   set delta [expr $coscrval2 -$ddec*$sincrval2 ]
   set gamma [expr sqrt($dra*$dra + $delta*$delta) ]
   set ra [expr $crval1 + 180./$pi*atan($dra/$delta)]
   set dec [expr 180./$pi*atan( ($sincrval2+$ddec*$coscrval2)/$gamma )]

   set fov_x [ format %.6f [expr abs($cdelt1)*$naxis1]]
   set fov_y [ format %.6f [expr abs($cdelt2)*$naxis2]]

   return [ list $ra $dec $fov_x $fov_y ]
}

# source $audace(rep_install)/gui/audace/plugin/tool/sn_tarot/sn_tarot_macros.tcl
proc ::sn_tarot::snAnalyzeCandidateId { } {
   global audace snvisu snconfvisu num caption rep

   set textes ""

   #--   fenetre de sortie
   set fcand $audace(base).snvisu_ancand

   if { [ winfo exists $fcand ] } {
      destroy $fcand
   }

   #--- Create the toplevel window .snvisu_ancand
   #--- Cree la fenetre .snvisu_ancand de niveau le plus haut
   toplevel $fcand -class Toplevel
   wm title $fcand $caption(sn_tarot,candidate)
   regsub -all {[\+|x]} [ wm geometry $audace(base).snvisu_ancand ]  " " pos
   wm geometry $fcand 600x600+[expr {[ lindex $pos 1 ] + 20 } ]+[ expr {[ lindex $pos 2 ] + 0} ]
   wm resizable $fcand 1 1
   if {[info exists audace(base).snvisu]==1} {
      wm transient $fcand $audace(base).snvisu
   }
   wm protocol $fcand WM_DELETE_WINDOW "destroy $fcand"

   #--- Create the label and the radiobutton
   #--- Cree l'etiquette et les radiobuttons
   frame $fcand.frame1 -borderwidth 0 -relief raised
      #--- Label
      label $fcand.frame1.label -text " " \
         -borderwidth 0 -relief flat
      pack $fcand.frame1.label -fill x -side left -padx 5 -pady 5
   pack $fcand.frame1 -side top -fill both -expand 0

   #--- cree un acsenseur vertical pour la console de retour d'etats
   frame $fcand.fra1
      scrollbar $fcand.fra1.scr1 -orient vertical \
         -command "$fcand.fra1.lst1 yview" -takefocus 0 -borderwidth 1
      pack $fcand.fra1.scr1 \
         -in $fcand.fra1 -side right -fill y
      set snvisu(status_scrl) $fcand.fra1.scr1

      scrollbar $fcand.fra1.scr2 -orient horizontal \
         -command "$fcand.fra1.lst1 xview" -takefocus 0 -borderwidth 1
      pack $fcand.fra1.scr2 \
         -in $fcand.fra1 -side bottom -fill x
      set snvisu(status_scrlx) $fcand.fra1.scr2

      #--- cree la console de retour d'etats
      text $fcand.fra1.lst1 \
         -borderwidth 1 -relief sunken  -height 6 -font {courier 8 bold} \
         -yscrollcommand "$fcand.fra1.scr1 set"  -xscrollcommand "$fcand.fra1.scr2 set" -wrap none
      pack $fcand.fra1.lst1 \
         -in $fcand.fra1 -expand yes -fill both \
         -padx 3 -pady 3
      set snvisu(status_list) $fcand.fra1.lst1
   pack $fcand.fra1 -side top -fill both -expand 1

   $snvisu(status_list) insert end "$caption(sn_tarot,ancand_wait)\n"
   $snvisu(status_list) yview moveto 1.0
   update

   #--- Create the button 'Modify'
   #--- Cree le bouton 'Modify'
#    button $fcand.but_modify -text $caption(sn_tarot,modify) \
#       -borderwidth 2 -command {
#          global snvisu audace
#          set res [$snvisu(status_list) dump -text 1.0 end]
#          set snvisu(candidate,textes) ""
#          set n [llength $res]
#          for {set k 1} {$k<$n} {incr k 3} {
#             #::console::affiche_resultat "[lindex $res $k]"
#             append snvisu(candidate,textes) [lindex $res $k]
#          }
#          set fichier "$snvisu(candidate,candidate_file)"
#          set f [open $fichier w]
#          puts -nonewline $f $snvisu(candidate,textes)
#          close $f
#        }
#    pack $fcand.but_modify -side left -anchor w -padx 5 -pady 5
#    $fcand.but_modify configure  -state disabled

   #--- Create the button 'OK'
   #--- Cree le bouton 'OK'
   button $fcand.but_ok -text $caption(sn_tarot,ok) -width 8 \
      -borderwidth 2 -command "destroy $audace(base).snvisu_ancand"
   pack $fcand.but_ok -side right -anchor w -padx 5 -pady 5
   $fcand.but_ok configure  -state disabled

   #--- La fenetre est active
   focus $fcand

   #--- Mise a jour dynamique des couleurs
   ::confColor::applyColor $fcand

   # --- File readings
   update
   set path "$rep(archives)/../alert"
   set fichiers [lsort [glob -nocomplain ${path}/*.txt]]
   set ficlists ""
   set objname0 ""
   set objdates ""
   foreach fichier $fichiers {
      set fics [split [file tail $fichier] _]
      set objname [lindex $fics 0]
      set objdate [lindex $fics 3]
      if {$objname!=$objname0} {
         if {$objname0!=""} {
            lappend ficlists $comment
         }
         set comment [list $objname $objdate $fichier]
      } else {
         lappend comment $fichier
      }
      set objname0 $objname
   }
   set ficlists [lsort -index 1 -decreasing $ficlists]
   set objname0 ""
   set comments "$caption(sn_tarot,result_analysis)\n\n"
   foreach ficlist $ficlists {
      set objname [lindex $ficlist 0]
      set fichiers [lrange $ficlist 2 end]
      append comments "---------------------------\n"
      append comments "--- $objname ---\n"
      foreach fichier $fichiers {
         append comments "[file tail $fichier]\n"
         #::console::affiche_resultat "fichier=[file normalize $fichier]\n"
         $snvisu(status_list) insert end "[file normalize $fichier]\n"
         $snvisu(status_list) yview moveto 1.0
         set f [open $fichier r]
         set lignes [split [read $f] \n]
         close $f
         set fics [split [file tail $fichier] _]
         set objname [lindex $fics 0]
         set objdate [lindex $fics 3]
         if {$objname!=$objname0} {
            set comment ""
         }
         set n [expr [llength $lignes]-1]
         #::console::affiche_resultat "n=$n\n"
         for {set k 0} {$k<$n} {incr k} {
            set ligne [lindex $lignes $k]
            set key [string range $ligne 0 36]
            #::console::affiche_resultat "<$key>\n"
            if {[string compare $key "Personal comment about this candidate"]==0} {
               incr k
               for {set kk $k} {$kk<$n} {incr kk} {
                  set ligne [lindex $lignes $kk]
                  set key [string range $ligne 0 4]
                  if {$key=="-----"} {
                     break
                  } else {
                     if {$ligne!=""} {
                        append comments "$ligne\n"
                     }
                  }
               }
            }
         }
      }
      set arfichiers [lsort -decreasing [::sn_tarot::searchinArchives [file rootname $objname]]]
      append comments "-> List of archives:\n"
      foreach arfichier $arfichiers {
         append comments "$arfichier\n"
      }
      append comments "---------------------------\n\n"

   }

   #
   ::console::affiche_resultat "\n$comments"

   $snvisu(status_list) delete 1.0 end
   $snvisu(status_list) insert end "$comments"
   $snvisu(status_list) yview moveto 0.0
   #$fcand.but_modify configure  -state normal
   $fcand.but_ok configure  -state normal
   #$fcand.frame1.label configure -text $snvisu(candidate,candidate_file)
   $fcand.fra1.lst1 configure -font {courier 8 bold}
   update
}

