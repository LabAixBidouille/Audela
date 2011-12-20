#
# Fichier : grb_tools.tcl
# Description : Outil pour les sursauts gamma
# Auteur : Alain KLOTZ
# Mise à jour $Id$
#
# source "$audace(rep_install)/gui/audace/grb_tools.tcl"
#
# --- Pour telecharger les GCN circulars
# grb_gcnc update 100
# grb_gcnc id_telescope
# grb_gcnc list_telescopes
#
# --- Pour telecharger les GRB de Greiner
# grb_greiner update
# grb_greiner prompt_map ?
#
# --- Pour analyser les alertes Antares
# grb_antares update
# grb_antares html
#
#loadima C:/Users/klotz/AppData/Roaming/AudeLA/catalog/grb/promptmaps/World-Coloured.bmp

# ===========================================================================================
# Lecture d'une page HTML via http
#
proc grb_read_url_contents { url {fullfile_out ""} } {
   package require http
   set token [::http::geturl $url]
   upvar #0 $token state
   set res $state(body)
   set len [string length $res]
   if {$fullfile_out!=""} {
      set f [open $fullfile_out w]
      puts -nonewline $f "$res"
      close $f
   }
   return $res
}

proc grb_greiner { args } {
   global audace

   set methode [lindex $args 0]
   set grbpath [ file join $::audace(rep_userCatalog) grb greiner]

   if {$methode=="update"} {

      set force [lindex $args 1]
      if {$force!=""} {
         set force 1
      } else {
         set force 0
      }
      file mkdir "$grbpath"
      set url0 "http://www.mpe.mpg.de/~jcg/grbgen.html"
      set lignes [split [grb_read_url_contents "$url0"] \n]
      set nl [llength $lignes]

      set id1 "<TR VALIGN=\"TOP\"><TD NOWRAP><a href=\"grb"
      set id2 ".html\">"
      set nid2 [string length $id2]
      set id3 "</a></TD>"
      set nid3 [string length $id3]
      set id4 ">"
      set nid4 [string length $id4]
      set id5 "<SUP>"
      set nid5 [string length $id5]
      set id6 "</SUP>"
      set nid6 [string length $id6]
      set id7 "&#"
      set nid7 [string length $id7]
      set id8 "; "
      set nid8 [string length $id8]
      set id9 "'</TD>"
      set nid9 [string length $id9]
      set id10 "</TD>"
      set nid10 [string length $id10]
      set id11 "{"
      set nid11 [string length $id11]
      set id12 "}"
      set nid12 [string length $id12]
      set id13 "DOY;"
      set nid13 [string length $id13]

      catch {unset grbs}
      for {set kl 0} {$kl<$nl} {incr kl} {
         set ligne [lindex $lignes $kl]
         if {[string first $id1 $ligne]==0} {
            set k1 [expr [string first "$id2" $ligne]+$nid2]
            set k2 [expr [string last "$id3" $ligne]-1]
            set grbname [string range $ligne $k1 $k2]
            set grbname [string trim $grbname ?]
            ::console::affiche_resultat "GRBNAME=$grbname\n"
            lappend grbs(name) $grbname
            # ---
            set l [lindex $lignes [expr $kl+1]]
            set k1 [expr [string first "$id4" $l]+$nid4]
            set k2 [expr [string first "$id5" $l]-1]
            set res [string range $l $k1 $k2]
            set ra ${res}h
            #::console::affiche_resultat "h=$res\n"
            set l [string range $l [expr $k2+17] end]
            set k1 [expr [string first "$id4" $l]+$nid4]
            set k2 [expr [string first "$id5" $l]-1]
            set res [string range $l $k1 $k2]
            append ra ${res}m
            #::console::affiche_resultat "m=$res\n"
            set l [string range $l [expr $k2+17] end]
            set k1 [expr [string first "$id4" $l]+$nid4]
            set k2 [expr [string first "$id5" $l]-1]
            set res [string range $l $k1 $k2]
            append ra ${res}s
            #::console::affiche_resultat "s=$res\n"
            lappend grbs(ra) [mc_angle2deg $ra]
            # ---
            set l [lindex $lignes [expr $kl+2]]
            set k1 [expr [string first "$id6" $l]+$nid6]
            set k2 [expr [string first "$id7" $l]-1]
            set res [string range $l $k1 $k2]
            set dec ${res}d
            #::console::affiche_resultat "d=$res\n"
            set k1 [expr [string first "$id8" $l]+$nid8]
            set k2 [expr [string first "$id9" $l]-1]
            set res [string range $l $k1 $k2]
            append dec ${res}m
            #::console::affiche_resultat "m=$res\n"
            lappend grbs(dec) [mc_angle2deg $dec 90]
            # ---
            set l [lindex $lignes [expr $kl+3]]
            set k1 [expr [string first "$id4" $l]+$nid4]
            set k2 [expr [string first "$id10" $l]-1]
            set res [string range $l $k1 $k2]
            lappend grbs(error) $res
            # ---
            set l [lindex $lignes [expr $kl+4]]
            set k1 [expr [string first "$id4" $l]+$nid4]
            set k2 [expr [string first "$id10" $l]-1]
            set res [string range $l $k1 $k2]
            lappend grbs(satellite) $res
            # ---
            set l [lindex $lignes [expr $kl+7]]
            set k1 [expr [string first "$id4" $l]+$nid4]
            set k2 [expr [string first "$id10" $l]-1]
            set res [string range $l $k1 $k2]
            if {[string compare $res "y"]==0} {
               set res "1"
            } else {
               set res "0"
            }
            lappend grbs(obsoptic) $res
            # ---
            set l [lindex $lignes [expr $kl+10]]
            set k1 [expr [string first "$id4" $l]+$nid4]
            set k2 [expr [string first "$id10" $l]-1]
            set res [string range $l $k1 $k2]
            if {[string compare $res "&nbsp;"]==0} {
               set res "-1"
            }
            lappend grbs(redshift) $res
            #if {$grbname=="061007"} {
            #   dfdfgdsf
            #}
            # ---
            set grbfile [ file join $grbpath grb${grbname}.html]
            if {([file exists $grbfile]==0)||($force==1)} {
               set url1 "http://www.mpe.mpg.de/~jcg/grb${grbname}.html"
               set contents ""
               for {set k 0} {$k<10} {incr k} {
                  set err [ catch {
                     set contents [grb_read_url_contents "$url1"]
                  } msg ]
                  if {$err==0} {
                     break
                  }
               }
               set f [open $grbfile w]
               puts -nonewline $f $contents
               close $f
               set ligne2s [split $contents \n]
            } else {
               set f [open $grbfile r]
               set ligne2s [split [read $f] \n]
               close $f
               set err 0
            }
            set nl2 [llength $ligne2s]
            set grbtime ""
            set grbdate ""
            set grbdateiso 1800-01-01T00:00:00
            if {($nl2<5)||($err==1)} {
               lappend grbs(date) [mc_date2iso8601 ${grbdateiso}]
               continue;
            }
            for {set kl2 0} {$kl2<$nl2} {incr kl2} {
               set l [lindex $ligne2s $kl2]
               set res [string range $l 0 8]
               if {[string compare $res "GRB_TIME:"]==0} {
                  set k1 [expr [string first "$id11" $l]+$nid11]
                  set k2 [expr [string first "$id12" $l]-1]
                  set res [string range $l $k1 $k2]
                  set grbtime $res
               } elseif {[string compare $res "GRB_DATE:"]==0} {
                  set k1 [expr [string first "$id13" $l]+$nid13]
                  set k2 end
                  set res [string trim [string range $l $k1 $k2]]
                  set res [regsub -all / $res -]
                  set y [string range $res 0 0]
                  if {$y<7} {
                     set res 20$res
                  } else {
                     set res 19$res
                  }
                  set grbdate $res
               }
               if {([string compare $grbtime ""]!=0)&&([string compare $grbdate ""]!=0)} {
                  set grbdateiso [mc_date2iso8601 ${grbdate}T${grbtime}]
                  break;
               }
            }
            lappend grbs(date) [mc_date2iso8601 ${grbdateiso}]
         }
      }
      set lignes ""
      set n [llength $grbs(name)]
      for {set k 0} {$k<$n} {incr k} {
         set name [lindex $grbs(name) $k]
         set ra [lindex $grbs(ra) $k]
         set dec [lindex $grbs(dec) $k]
         set satellite [lindex $grbs(satellite) $k]
         set date [lindex $grbs(date) $k]
         set obsoptic [lindex $grbs(obsoptic) $k]
         set redshift [lindex $grbs(redshift) $k]
         set err [catch {format %f $redshift} msg]
         if {$err==1} {
            set nr [string length $redshift]
            set redshift2 ""
            for {set kr 0} {$kr<$nr} {incr kr} {
               set car [string index $redshift $kr]
               if {($car=="0")||($car=="1")||($car=="2")||($car=="3")||($car=="4")||($car=="5")||($car=="6")||($car=="7")||($car=="8")||($car=="9")||($car==".")} {
                  append redshift2 $car
               }
            }
            set redshift -1
            set err [catch {format %f $redshift2} msg]
            if {$err==1} {
               set redshift2 $redshift
            }
         } else {
            set redshift2 $redshift
         }
         set ligne [format "%9s %12s %20s %08.4f %+08.4f %1d %+07.3f %+07.3f" $name $satellite $date $ra $dec $obsoptic $redshift $redshift2]
         append lignes "${ligne}\n"
      }
      set f [open ${grbpath}/grboptic.txt w]
      puts -nonewline $f $lignes
      close $f
      ::console::affiche_resultat "GRB Greiner file ${grbpath}/grboptic.txt\n"

   } elseif {$methode=="prompt_map"} {

      set err [catch {open ${grbpath}/grboptic.txt r} f]
      if {$err==1} {
         error "File ${grbpath}/grboptic.txt not found. Please use the function \"grb_greiner update\" before"
      }
      set lignes [split [read $f] \n]
      close $f
      set satellites ""
      set tsatellites ""
      set grbs ""
      set tgrbs ""
      foreach ligne $lignes {
         set grb [lindex $ligne 0]
         if {$grb==""} { continue }
         lappend grbs $grb
         append tgrbs "$grb "
         set satellite [lindex $ligne 1]
         set k [lsearch -exact $satellites $satellite]
         if {$k==-1} {
            lappend satellites $satellite
            append tsatellites "$satellite "
         }
      }

      set onesatellite [lindex $args 1]
      if {$onesatellite==""} {
         set onesatellite Swift
      } elseif {$onesatellite=="?"} {
         ::console::affiche_resultat "Available satellites are: $tsatellites.\n\nAvailable GRBs are: $tgrbs\n"
         return
      }
      set onegrb ""
      set onegrb [lindex $args 2]
      set k [lsearch -exact $satellites $onesatellite]
      if {$k==-1} {
         # - l'argument est un numero de GRB
         set onegrb $onesatellite
         set k [lsearch -exact $grbs $onegrb]
         if {$k==-1} {
            set onegrb [string range $onesatellite 3 end]
            set k [lsearch -exact $grbs $onegrb]
            if {$k==-1} {
               ::console::affiche_resultat "$onesatellite not found. Available satellites are: $tsatellites\n\nAvailable GRBs are: $tgrbs\n"
               return
            }
         }
      }

      #::console::affiche_resultat "onesatellite=$onesatellite\n"
      #::console::affiche_resultat "onegrb=$onegrb\n"
      set n 0
      set tgrbs ""
      set jdlim [mc_date2jd 1900-01-01T00:00:00]
      foreach ligne $lignes {
         set grb [lindex $ligne 0]
         set satellite [lindex $ligne 1]
         if {$onegrb!=""} {
            if {$onegrb!=$grb} {
               continue
            }
         } else {
            if {$satellite!=$onesatellite} {
               continue
            }
         }
         set jd [mc_date2jd [lindex $ligne 2]]
         if {$jd<$jdlim} {
            continue
         }
         set optic [lindex $ligne 5]
         append tgrbs "$grb "
         lappend jds $jd
         lappend ras [lindex $ligne 3]
         lappend decs [lindex $ligne 4]
         lappend equinoxs J2000
         incr n
      }
      ::console::affiche_resultat "$n GRB found: $tgrbs\n"
      if {$n==0} {
         return
      }
      set t0 [clock seconds]

      set fname "$audace(rep_images)/tmp[buf$audace(bufNo) extension]"
      set method 0
      set minobjelev 10
      set maxsunelev -10
      set minmoondist 5
      #::console::affiche_resultat "mc_lightmap $jds $ras $decs $equinoxs $fname 1 1 $method $minobjelev $maxsunelev $minmoondist\n"
      mc_lightmap $jds $ras $decs $equinoxs $fname 1 1 $method $minobjelev $maxsunelev $minmoondist
      loadima $fname

      set t [expr [clock seconds]-$t0]
      ::console::affiche_resultat "Map computed in $t seconds for $n GRBs.\n"

   } else {

      error "Error: First element must be a method amongst update, prompt_map"

   }
}

# Update GCNC files in AudeLA
# Valid header since GCNC 31
proc grb_gcnc { args } {
   global audace

   set methode [lindex $args 0]
   set t0 [clock seconds]

   set sats {\
   {"ASM" "Beppo-SAX"} \
   {"BAT" "Swift-BAT"} \
   {"BATSE" "BATSE"} \
   {"BEPPO" "Beppo-SAX"} \
   {"CHANDRA" "Chandra"} \
   {"FERMI" "Fermi"} \
   {"FREGATE" "HETE-Fregate"} \
   {"GRBM" "GRBM"} \
   {"HERSCHEL" "Herschel"} \
   {"HETE" "HETE"} \
   {"IBAS" "Integral-IBAS"} \
   {"INTEGRAL" "Integral"} \
   {"IPN" "IPN"} \
   {"KONUS" "KONUS-Wind"} \
   {"KONUS-WIND" "KONUS-Wind"} \
   {"MAXI" "MAXI-GSC"} \
   {"NFI" "Beppo-SAX"} \
   {"ROSAT" "ROSAT"} \
   {"SAX" "Beppo-SAX"} \
   {"SPITZER" "Spitzer"} \
   {"SuperAGILE" "AGILE"} \
   {"SUZAKU" "Suzaku"} \
   {"SWIFT" "Swift"} \
   {"TEST " ""} \
   {"UVOT" "Swift-UVOT"} \
   {"WAM" "Suzaku-WAM"} \
   {"WIND" "KONUS-Wind"} \
   {"XMM" "XMM-Newton"} \
   {"XRT" "Swift-XRT"} \
   {"XRTE" "XRTE"} \   
   }

   set miscs {\
   {"APEX" "APEX"} \
   {"ATCA" "ATCA"} \
   {"CORRECTION" ""} \
   {"EVLA" "VLA"} \
   {"IRAM" "IRAM"} \
   {"MAMBO" "MAMBO"} \
   {"MILAGRO" "MILAGRO"} \
   {"PSEUDO" "Pseudo-redshift"} \
   {"RHESSI" "RHESSI"} \
   {"SDSS" "SDSS"} \
   {"SMA" "SMA"} \
   {"VLA" "VLA"} \
   {"WSRT" "WSRT"} \
   }

   set tels {\
   {"ANU " "ANU_2.3m"} \
   {"APO " "ARC_3.5m"} \
   {" ARC " "ARC_3.5m"} \
   {"AROMA" "AROMA"} \
   {"ART-" "ART-3"} \
   {"AZT-33IK" "AZT-33IK"} \
   {"BART " "BART"} \
   {"BOOTES" "BOOTES*"} \
   {"BOOTES1A" "BOOTES1A"} \
   {"BOOTES1B" "BOOTES1B"} \
   {"BOOTES2" "BOOTES2"} \
   {"BOOTES3" "BOOTES3"} \
   {"BOOTES-3" "BOOTES3"} \
   {"BTA" "BTA"} \
   {"CASSINI" "CASSINI"} \
   {"CAHA" "CAHA-1.23m"} \
   {"CFHT" "CFHT"} \
   {"CONCAM" "CONCAM"} \
   {"CQUEAN" "McDonald-2.1m"} \
   {"CRAO" "Shajn"} \
   {"CRNI VRH" "PIKA"} \
   {"D50" "D50"} \
   {"DANISH" "ESO/Danish"} \
   {"DANISH/DFOSC" "ESO/Danish"} \
   {"DFOSC" "ESO/Danish"} \
   {" EST " "EST"} \
   {"FAULKES" "FT*"} \
   {"FRAM " "FRAM"} \
   {"FTN" "FTN"} \
   {"FTS" "FTS"} \
   {"GAO" "GAO"} \
   {"GEMINI" "Gemini-*"} \
   {"GETS " "GETS"} \
   {"GMOS" "Gemini-*"} \
   {"GMG" "GMG_240"} \
   {"GORT " "GORT"} \
   {"GROND" "GROND"} \
   {"GTC" "GTC"} \
   {"IAC " "IAC-80"} \
   {"IAC80" "IAC-80"} \
   {" INT " "INT"} \
   {"ISAS " "ISAS"} \
   {"K-380" "K-380"} \
   {"KAIT" "KAIT"} \
   {"KANAZAWA" "Kanazawa"} \
   {"KECK" "Keck"} \
   {"KISO" "Kiso"} \
   {"KONKOLY" "Konkoly"} \
   {"LCO" "LCO_40"} \
   {"LICK OBSERV" "Lick_Shane"} \
   {"LICK 3m" "Lick_Shane"} \
   {"LIVERPOOL" "Liverpool"} \
   {" LT " "Liverpool"} \
   {"LNA" "LNA_60"} \
   {" LOT " "LOT"} \
   {"LOTIS" "*LOTIS"} \
   {"LULIN" "LOT"} \
   {"MAGELLAN" "Magellan"} \
   {"MAGIC" "Magellan"} \
   {"MAIDANAK" "Maidanak"} \
   {"MARGE" "MARGE_AEOS"} \
   {"MASCOT" "MASCOT"} \
   {"MASTER" "MASTER"} \
   {"MDM" "MDM_*"} \
   {"MIKE " "Gemini-*"} \
   {"MINITAO" "MiniTAO"} \
   {"MIRO" "MIRO"} \
   {"MITSUME" "MITSuME"} \
   {"MIYAZAKI" "Miyazaki"} \
   {"MONDY" "SAYAN-1.5m"} \
   {" MOA " "MOA_61"} \   
   {"NAYUTA" "NAYUTA"} \
   {" NOT " "NOT"} \
   {"NTT" "NTT"} \
   {"OHP" "OHP"} \
   {"OPTIMA" "OPTIMA"} \
   {" OSN " "OSN_150"} \
   {"PAIRITEL" "PAIRITEL"} \
   {"P200" "P200"} \
   {"P60" "P60"} \
   {"PIKA" "PIKA"} \
   {"PI OF THE SKY" "PI-OF-THE-SKY"} \
   {"PI-OF-THE-SKY" "PI-OF-THE-SKY"} \
   {" PROMPT " "PROMPT"} \
   {"RAPTOR" "RAPTOR"} \
   {" REM " "REM"} \
   {"ROTSE" "ROTSE"} \
   {"RTT150" "RTT150"} \
   {"SALT" "SALT"} \
   {"SAO RAS" "SAO-1m"} \
   {" SARA " "SARA"} \
   {"SHAJN" "Shajn"} \
   {"SHANE " "Lick_Shane"} \
   {"SMARTS" "SMARTS_130"} \
   {" SOAR " "SOAR"} \
   {" SSO " "SSO_1m"} \
   {"SUBARU" "Subaru"} \
   {"TAROT" "TAROT"} \
   {"TAUTENBURG" "Tautenburg"} \
   {"TERSKOL" "Terskol_200"} \
   {" THO " "THO"} \
   {"TNG" "TNG"} \
   {"TNT" "TNT"} \
   {"TORTORA" "TORTORA"} \
   {"TTT" "TTT"} \
   {"UKIRT" "UKIRT"} \
   {"VATICAN" "VATT"} \
   {" VATT " "VATT"} \
   {"VERY LARGE TELESCOPE" "VLT"} \
   {"VLT" "VLT"} \
   {"WATCHER" "Watcher"} \
   {"WHT" "WHT"} \
   {"WIDGET" "WIDGET"} \
   {"WIYN" "WIYN"} \
   {"XINGLONG" "TNT"} \
   {"ZADKO" "Zadko"} \
   }

   set sat0s ""
   set sat1s ""
   foreach sat $sats {
      lappend sat0s [lindex $sat 0]
      lappend sat1s [lindex $sat 1]
   }
   set misc0s ""
   set misc1s ""
   foreach misc $miscs {
      lappend misc0s [lindex $misc 0]
      lappend misc1s [lindex $misc 1]
   }
   set tel0s ""
   set tel1s ""
   foreach tel $tels {
      lappend tel0s [lindex $tel 0]
      lappend tel1s [lindex $tel 1]
   }

   if {$methode=="update"} {

      set gcncpath [ file join $::audace(rep_userCatalog) grb gcnc]
      file mkdir "$gcncpath"
      # --- rechercher l'indice du plus grand GCNC deja telecharge
      set gcncfolders [lsort [ glob -nocomplain [ file join $gcncpath * ] ]]
      set gcncdeb 0
      set gcncfolder [lindex $gcncfolders end]
      if {$gcncfolder!=""} {
         set gcncfiles [lsort [ glob -nocomplain [ file join $gcncfolder *.gcn3 ] ]]
         set gcncfile [lindex $gcncfiles end]
         if {$gcncfile!=""} {
            set gcncdeb [string trimleft [file rootname [file tail $gcncfile]] 0]
         }
      }
      ::console::affiche_resultat "GCN circulars ever downloaded until $gcncdeb\n"
      incr gcncdeb
      if {[llength $args]>1} {
         set nc [lindex $args 1]
         set gcncfin [expr $gcncdeb+$nc]
         ::console::affiche_resultat "Download GCN circulars from $gcncdeb to $gcncfin\n"
      } else {
         set nc 0
         ::console::affiche_resultat "Download GCN circulars from $gcncdeb\n"
      }
      # --- download GCN circulars
      set url0 "http://gcn.gsfc.nasa.gov/gcn3"
      set sortie 0
      set kl $gcncdeb
      while {$sortie==0} {
         set kll [format %03d ${kl}]
         set url1 "${url0}/${kll}.gcn3"
         set found 0
         for {set k 0} {$k<10} {incr k} {
            set err [ catch {
               set texte [grb_read_url_contents "$url1"]
            } msg ]
            set t [expr [clock seconds]-$t0]
            if {$err==0} {
               set msg2 [string first "<title>404 Not Found</title>" $texte]
               # --- Test if the (kl) GCNC exists and is not a 404
               if {$msg2==-1} {
                  set found 1
                  break
               }
               # --- The (kl) does not exists. Test if the (kl+1) GCNC exists.
               set kl2 [expr $kl+1]
               set kll2 [format %03d ${kl2}]
               set url2 "${url0}/${kll2}.gcn3"
               set err [ catch {
                  set texte [grb_read_url_contents "$url2"]
               } msg ]
               if {$err==0} {
                  set msg2 [string first "<title>404 Not Found</title>" $texte]
                  if {$msg2==-1} {
                     set found 2
                     break
                  }
               }
            }
            ::console::affiche_resultat "$t sec.: GCNC $url1 retry $k times\n"
         }
         if {$found==0} {
            ::console::affiche_resultat "$t sec.: GCNC $url1 not found. Exit update.\n"
            break
         }
         if {$found==2} {
            ::console::affiche_resultat "$t sec.: GCNC $url1 was not edited. Skip it.\n"
            incr kl
            continue
         }
         set gcncfolder [ file join $gcncpath gcnc[format %04d [expr $kl/100]]]
         file mkdir "$gcncfolder"
         set f [open "${gcncfolder}/${kll}.gcn3" w]
         puts -nonewline $f "$texte"
         close $f
         ::console::affiche_resultat "$t sec.: GCNC $url1 downloaded\n"
         if {$nc>0} {
            if {$kl>=$gcncfin} {
               break
            }
         }
         incr kl
      }

   } elseif {$methode=="id_telescope"} {

      set gcncpath [ file join $::audace(rep_userCatalog) grb gcnc]
      file mkdir "$gcncpath"
      # --- rechercher l'indice du plus grand GCNC deja telecharge
      set gcncfolders [lsort [ glob -nocomplain [ file join $gcncpath * ] ]]
      set gcncfin 0
      set gcncfolder [lindex $gcncfolders end]
      if {$gcncfolder!=""} {
         set gcncfiles [lsort [ glob -nocomplain [ file join $gcncfolder *.gcn3 ] ]]
         set gcncfile [lindex $gcncfiles end]
         if {$gcncfile!=""} {
            set gcncfin [string trimleft [file rootname [file tail $gcncfile]] 0]
         }
      }
      ::console::affiche_resultat "GCN circulars ever downloaded until $gcncfin\n"
      set gcncdeb 1
      #set gcncdeb 12000
      #set gcncfin 12100
      #
      set textes ""
      for {set kl $gcncdeb} {$kl<=$gcncfin} {incr kl} {
         set kll [format %03d ${kl}]
         set gcncfolder [ file join $gcncpath gcnc[format %04d [expr $kl/100]]]
         file mkdir "$gcncfolder"
         if {[file exists "${gcncfolder}/${kll}.gcn3"]==0} {
            continue
         }
         set f [open "${gcncfolder}/${kll}.gcn3" r]
         set lignes [split [read $f] \n]
         close $f
         set texte "GCNC [format %5d $kl] : "
         set kk 0
         set subject nonpassed
         foreach ligne $lignes {
            set ligne [regsub -all \" "$ligne" " "]
            set ligne [regsub -all \{ "$ligne" " "]
            set ligne [regsub -all \} "$ligne" " "]
            set ligne [regsub -all / "$ligne" " "]
            set ligne [regsub -all , "$ligne" " "]
            set ligneup [string toupper $ligne]
            set keyword [lindex $ligneup 0]
            if {($keyword=="SUBJECT:")} {
               set ligne2 [regsub -all : "$ligne" " "]
               set ligneup2 [string toupper $ligne2]
               set k [string first "GRB" $ligneup2]
               set grb ------
               if {$k>=0} {
                  set k1 [expr $k+3]
                  set l [string range $ligneup2 $k1 end]
                  set k [string first " " $l 3]
                  if {$k==-1} {
                     set k 1
                  }
                  set grb [string trim [string range $l 0 [expr $k-1]]]
               }
               append texte "$grb : "
            }
            if {($keyword=="SUBJECT:")||($subject=="passed")} {
               set ls $sat0s
               set ls1 $sat1s
               set k1 -1 ; foreach l $ls { incr k1 ; set k [string first " $l " $ligneup]; if {$k>=0} { incr kk ; append texte "[lindex $ls1 $k1] : " } }
               set ls $misc0s
               set ls1 $misc1s
               set k1 -1 ; foreach l $ls { incr k1 ; set k [string first " $l " $ligneup]; if {$k>=0} { incr kk ; append texte "[lindex $ls1 $k1] : " } }
               set ls $tel0s
               set ls1 $tel1s
               #::console::affiche_resultat "ligneup=$ligneup\n"
               set k1 -1 ; foreach l $ls { incr k1 ; set k [string first "$l" $ligneup]; if {$k>=0} { incr kk ; append texte "[lindex $ls1 $k1] : " } }
               #::console::affiche_resultat "texte=$texte\n"
            }
            if {($keyword=="SUBJECT:")&&($kk>0)} {
               break
            }
            if {($keyword=="SUBJECT:")&&($kk==0)} {
               #append texte "<$ligne>"
            }
            if {($keyword=="SUBJECT:")} {
               set subject "passed"
            }
            #::console::affiche_resultat " ligne=$ligne\n"
         }
         append texte "\n"
         ::console::affiche_resultat "$kl / $gcncfin : $texte"
         append textes "$texte"
      }
      set f [open "${gcncpath}/../gcncs.txt" w]
      puts -nonewline $f "$textes"
      close $f

   } elseif {$methode=="list_telescopes"} {

      set gcncpath [ file join $::audace(rep_userCatalog) grb gcnc]
      file mkdir "$gcncpath"
      #
      set textes ""
      catch {unset obss}
      #
      set f [open "${gcncpath}/../gcncs.txt" r]
      set lignes [split [read $f] \n]
      close $f
      #set lignes [lrange $lignes 12088 12088]
      foreach ligne $lignes {
         set gcnc [lindex $ligne 1]
         set k1 [string first : $ligne]
         set k2 [string first : $ligne [expr $k1+1]]
         if {($k1==-1)||($k2==-1)} {
            continue
         }
         set grb [string range $ligne [expr $k1+1] [expr $k2-1]]
         set grb [regsub -all \[()\] "$grb" " "]
         set grb [string trim [lindex $grb 0]]
         set valid1 0
         set valid2 0
         if {[string length $grb]>=6} { set valid1 1 }
         if {[string index $grb 0]=="9"} { set valid2 1 }
         if {[string index $grb 0]=="0"} { set valid2 1 }
         if {[string index $grb 0]=="1"} { set valid2 1 }
         if {($valid1==0)||($valid2==0)} {
            set grb ------
         }
         set k3 $k2
         set k4 [string first : $ligne [expr $k3+1]]
         if {($k3==-1)||($k4==-1)} {
            continue
         }
         set obs [string trim [string range $ligne [expr $k3+1] [expr $k4-1]]]
         lappend obss($obs) [list $gcnc $grb]
         ::console::affiche_resultat "$gcnc $grb $obs >>>>> $ligne\n"
      }
      set names [array names obss]
      set ordres ""
      set k 0
      foreach name $names {
         set n [llength $obss($name)]
         lappend ordres [list [format %06d $n] $k]
         incr k
      }
      set ordres [lsort -decreasing $ordres]
      set nn [llength $names]
      for {set kk 0} {$kk<$nn} {incr kk} {
         set kkk [lindex [lindex $ordres $kk] 1]
         set name [lindex $names $kkk]
         set texte "[format %15s $name] : "
         set n [llength $obss($name)]
         append texte "[format %4d $n] : "
         set telname [regsub -all \[*/\] "$name" "_"]
         catch {file delete ${path}/tel_${telname}.txt}
         for {set k 0} {$k<$n} {incr k} {
            set res [lindex $obss($name) $k]
            set gcnc [lindex $res 0]
            set grb  [lindex $res 1]
            append texte "GCNC$gcnc GRB$grb : "
            #
            set kll [format %03d ${gcnc}]
            set gcncfolder [ file join $gcncpath gcnc[format %04d [expr $gcnc/100]]]
            set f [open "${gcncfolder}/${kll}.gcn3" r]
            set textegcnc [read $f]
            close $f
            set f [open "${gcncpath}/../tel_${telname}.txt" a]
            puts -nonewline $f "$textegcnc"
            close $f
         }
         append textes "$texte\n"
      }
      set f [open "${gcncpath}/../observatories.txt" w]
      puts -nonewline $f "$textes"
      close $f
      set f [open "${gcncpath}/../observatories.txt" r]
      set lignes [split [read $f] \n]
      close $f
      set textes ""
      foreach ligne $lignes {
         set k1 0
         set k2 [string first : $ligne $k1]
         set telname [string range $ligne $k1 $k2]
         set k1 [expr $k2+1]
         set k2 [string first : $ligne $k1]
         set telno [string range $ligne $k1 $k2]
         set k1 [expr $k2+1]
         set k2 [string first : $ligne $k1]
         set telgcn1 [string range $ligne $k1 $k2]
         set k1 [string last GCNC $ligne]
         set telgcn2 [string range $ligne $k1 end]
         set texte "${telname}${telno}${telgcn1} ${telgcn2}"
         append textes "$texte\n"
      }
      set f [open "${gcncpath}/../observatories_short.txt" w]
      puts -nonewline $f "$textes"
      close $f

   } else {

      ::console::affiche_resultat "Error: First element must be a method amongst update, id_telescope, list_telescopes\n"

   }

}

# Please copy your input file in $::audace(rep_userCatalog)/grb/antares
proc grb_antares { args } {
   global audace

   set methode [lindex $args 0]
   set t0 [clock seconds]

   if {$methode=="update"} {

      set finp [lindex $args 1]
      if {$finp==""} {
         set finp list_coordonnees_radec_alerts_tatoo.txt
      }
      set antarespath [ file join $::audace(rep_userCatalog) grb antares]
      set fichier ${antarespath}/${finp}
      if {[file exists $fichier]==0} {
         error "Input file $fichier not found."
      }

      set f [open $fichier r]
      set lignes [split [read $f] \n]
      close $f
      set ras ""
      set decs ""
      set jds ""
      set equinoxs ""
      set textes ""
      foreach ligne $lignes {
         set d1 [string range $ligne 0 9]
         if {[string length $d1]<5} {
            continue
         }
         set d2 [string range $ligne 12 19]
         set d2 [regsub -all " " $d2 0]
         set date ${d1}T${d2}
         set jd [mc_date2jd $date]
         set k [string first "ra=" $ligne]
         set dk 3
         if {$k==-1} {
            set k [string first "ra =" $ligne]
            set dk 4
         }
         set k1 [expr $k+$dk]
         set lig [string range $ligne $k1 end]
         set lig [regsub -all [format %c 160] $lig " "]
         set ra [string trim [lindex $lig 0]]
         set ligne $lig
         set k [string first "dec=" $ligne]
         set dk 4
         if {$k==-1} {
            set k [string first "dec =" $ligne]
            set dk 5
         }
         set k1 [expr $k+$dk]
         set lig [string range $ligne $k1 end]
         set lig [regsub -all [format %c 160] $lig " "]
         set dec [string trim [lindex $lig 0]]

         lappend ras $ra
         lappend decs $dec
         lappend jds $jd
         lappend equinoxs J2000
         set texte "$date [format %8.4f $ra] [format %+8.4f $dec]\n"
         append textes $texte
         ::console::affiche_resultat $texte

      }

      set n [llength $jds]
      set mult [expr 100./$n]

      ::console::affiche_resultat "$n Antares alerts\n"
      set fname "$audace(rep_images)/tmp[buf$audace(bufNo) extension]"
      set method 0
      set minobjelev 5
      set maxsunelev -10
      set minmoondist 5
      mc_lightmap $jds $ras $decs $equinoxs $fname 1 1 $method $minobjelev $maxsunelev $minmoondist
      loadima $fname
      mult $mult
      ::console::affiche_resultat "Map is displayed in percents\n"
      set sites ""
      lappend sites [list GFT 31.05 -115.45]
      lappend sites [list TAROT-Chili -29.259917 -70.7326]
      lappend sites [list TAROT-Calern 43.75203 6.92353]
      lappend sites [list Zadko -31.356667 115.713611]
      foreach site $sites {
         set obs [lindex $site 0]
         set lat [lindex $site 1]
         set lon [lindex $site 2]
         set y [expr 90+$lat]
         if {$lon<0} {
            set x [expr 360+$lon]
         } else {
            set x $lon
         }
         set res [lindex [buf$audace(bufNo) getpix [list [expr round($x)] [expr round($y)]]] 1]
         ::console::affiche_resultat "Telescope ${obs}: $x $y => $res %\n"
      }

      set fichier ${antarespath}/antares_triggers.txt
      set f [open $fichier w]
      puts -nonewline $f $textes
      close $f
      set fname "${antarespath}/antares_triggers[buf$audace(bufNo) extension]"
      buf$audace(bufNo) save $fname

   } elseif {$methode=="html"} {

      set finp [lindex $args 1]
      if {$finp==""} {
         set finp antares_triggers.txt
      }
      set antarespath [ file join $::audace(rep_userCatalog) grb antares]
      set fichier ${antarespath}/${finp}
      if {[file exists $fichier]==0} {
         error "Input file $fichier not found. Use grb_antares update before."
      }

      set antarespath [ file join $::audace(rep_userCatalog) grb antares html]
      file mkdir $antarespath

      set f [open $fichier r]
      set lignes [split [read $f] \n]
      close $f

      set htmltextes ""
      append htmltextes "<!DOCTYPE html PUBLIC \"-//W3C//DTD HTML 4.01 Transitional//EN\">\n"
      append htmltextes "<html>\n"
      append htmltextes "<head>\n"
      append htmltextes "  <meta content=\"text/html; charset=ISO-8859-1\" http-equiv=\"content-type\">\n"
      append htmltextes "  <title>Antares Trigger prompt maps</title>\n"
      append htmltextes "</head>\n"
      append htmltextes "<body>\n"
      append htmltextes "<div style=\"text-align: center;\"><big style=\"font-weight: bold;\"><big>Antares Trigger prompt maps</big></big><br></div>\n"

      # --- map parameters
      set method 0
      set minobjelev 5
      set maxsunelev -10
      set minmoondist 5
      set dlon 1
      set dlat 1

      # --- global map
      set ras ""
      set decs ""
      set jds ""
      set equinoxs ""
      append htmltextes "<pre>\n"
      append htmltextes "Date_of_trigger      RA      DEC\n"
      foreach ligne $lignes {
         set date [lindex $ligne 0]
         set ra [lindex $ligne 1]
         set dec [lindex $ligne 2]
         if {$dec==""} {
            continue
         }
         set equinox J2000
         set jd [mc_date2jd $date]
         lappend ras $ra
         lappend decs $dec
         lappend jds $jd
         lappend equinoxs J2000
         set texte "$date [format %8.4f $ra] [format %+8.4f $dec]\n"
         ::console::affiche_resultat $texte
         append htmltextes "$texte"
      }
      set n [llength $jds]
      set mult [expr 100./$n]
      append htmltextes "</pre>\n"
      set fname "$antarespath/pmap[buf$audace(bufNo) extension]"
      set method 0
      set minobjelev 5
      set maxsunelev -10
      set minmoondist 5
      mc_lightmap $jds $ras $decs $equinoxs $fname 1 1 $method $minobjelev $maxsunelev $minmoondist
      buf$audace(bufNo) load $fname
      mult $mult
      buf$audace(bufNo) save $fname
      set px [expr 2*(1+360/$dlon)]
      set py [expr 2*(1+180/$dlat)]
      append htmltextes "<img style=\"width: ${px}px; height: ${py}px;\" alt=\"\" src=\"pmap.jpg\"><br>\n"
      append htmltextes "This map displays the percents of trigger prompt visibility from gound.<br>\n"

      # --- individual maps
      set km 0
      foreach ligne $lignes {
         set date [lindex $ligne 0]
         set ra [lindex $ligne 1]
         set dec [lindex $ligne 2]
         if {$dec==""} {
            continue
         }
         incr km
         set equinox J2000
         set jd [mc_date2jd $date]
         append htmltextes "<br>\n"
         append htmltextes "<hr style=\"width: 100%; height: 2px;\">\n"
         append htmltextes "Trigger date : $date<br>\n"
         append htmltextes "Coordinates : ${ra} ${dec} ${equinox}<br>\n"
         ::console::affiche_resultat "$ligne ...\n"
         set fname "$antarespath/map${km}[buf$audace(bufNo) extension]"
         mc_lightmap $jd $ra $dec $equinox $fname $dlon $dlat $method $minobjelev $maxsunelev $minmoondist
         set px [expr 2*(1+360/$dlon)]
         set py [expr 2*(1+180/$dlat)]
         append htmltextes "<img style=\"width: ${px}px; height: ${py}px;\" alt=\"\" src=\"map${km}.jpg\">\n"
      }
      append htmltextes "</body>\n"
      append htmltextes "</html>\n"

      set fichier ${antarespath}/index.html
      set f [open $fichier w]
      puts -nonewline $f $htmltextes
      close $f

   } else {

      ::console::affiche_resultat "Error: First element must be a method amongst update, html\n"

   }
}

