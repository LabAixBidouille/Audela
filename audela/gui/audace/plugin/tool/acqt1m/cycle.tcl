#
# Fichier : cycle.tcl
# Description : Observation en automatique
# Auteur : Frédéric Vachier
# Mise à jour $Id$
#
# source audace/plugin/tool/acqt1m/cycle.tcl
#

#============================================================
# Declaration du namespace bddimages
#    initialise le namespace
#============================================================
namespace eval ::cycle {
   variable ::cycle::camera

   proc switch_filtre { } {
      variable private

      #::console::affiche_resultat "numfav = $private(idfiltrecourant)\n"
      set nbfiltre [llength $private(roue)]
      #::console::affiche_resultat "nb = $nbfiltre\n"
      if {$private(idfiltrecourant) == $nbfiltre} {
         set private(idfiltrecourant) 1
      } else {
         set private(idfiltrecourant) [incr private(idfiltrecourant)]
      }

      set l [lindex $private(roue) [expr $private(idfiltrecourant) - 1] ]
      set private(filtrecourant)   [lindex $l 0]
      set private(exptime)         [lindex $l 1]

      #::console::affiche_resultat "numfap = $private(idfiltrecourant)\n"
   }

   proc idcourant_to_posfiltre { f } {
      variable private

      for { set i 1 } {$i <= 9} {incr i} {
         if {[lindex $::t1m_roue_a_filtre::private(filtre,$i) 1]==$f} {
            return $i
         }
      }

      #::console::affiche_resultat "numfav = $private(idfiltrecourant)\n"
      set nbfiltre [llength $private(roue)]
      #::console::affiche_resultat "nb = $nbfiltre\n"
      if {$private(idfiltrecourant) == $nbfiltre} {
         set private(idfiltrecourant) 1
      } else {
         set private(idfiltrecourant) [incr private(idfiltrecourant)]
      }

      set l [lindex $private(roue) [expr $private(idfiltrecourant) - 1] ]
      set private(filtrecourant)   [lindex $l 0]
      set private(exptime)         [lindex $l 1]

      #::console::affiche_resultat "numfap = $private(idfiltrecourant)\n"
   }

   # ---------------------------------------
   # createdir_ifnot_exist
   # cree un nouveau repertoire s il n existe pas
   # ---------------------------------------
   proc createdir_ifnot_exist { dirfilename } {
      set direxist [file exists $dirfilename]
      if {$direxist==0} {
         set errnum [catch {file mkdir $dirfilename} msg]
      }
   }

   proc run { visuNo } {
      variable private

      ::console::affiche_resultat "$::caption(cycle,lancement)\n"

      set private(object)         "596_Scheila"
      set private(roue)           [list [list "R" 120] [list "V" 120] [list "B" 120]]
      set private(affbin)         "1x1"
      set private(nbimgparfiltre) 2

      ::console::affiche_resultat "$::caption(cycle,initFiltres)\n"
      ::t1m_roue_a_filtre::initFiltre $visuNo
      set num                      1
      set private(idfiltrecourant) 2
      set private(exptime)         1
      set fichlock                 "/home/t1m/lockcycle"

      #--------
      set private($visuNo,camItem) [ ::confVisu::getCamItem $visuNo ]
      set private($visuNo,camNo)   [ ::confCam::getCamNo $private($visuNo,camItem) ]
      set private($visuNo,bufNo)   [ ::confVisu::getBufNo $visuNo ]
      ::console::affiche_resultat "$::caption(cycle,initCamera)\n"
      catch {set ::cycle::camera cam$private($visuNo,camNo)}
      set err [catch {$::cycle::camera info} msg]
      if { $err == 1 } {
         ::console::affiche_resultat "$::caption(cycle,pasCamera)\n\n"
         return 1
      }
      catch { $::cycle::camera shutter synchro }
      set binctrl [ scan $private(affbin) "%dx%d" binx biny ]
      $::cycle::camera bin [list $binx $biny]
      #--------

      ::console::affiche_resultat "$::caption(cycle,initBuffer)\n"
      set buffer buf$private($visuNo,bufNo)

      while {1==1} {

         if {[file exists $fichlock]==1} {
            break
         }

         switch_filtre

         set pos [idcourant_to_posfiltre $private(filtrecourant)]
         #::console::affiche_resultat "pos = $pos\n"

         #--------
         # Initialise la roue a filtres
         ::console::affiche_resultat "$::caption(cycle,initCom)\n"
         set err [ catch { set tty [open "/dev/ttyS0" r+] } ]
         if { $err == 1 } {
            ::console::affiche_resultat "$::caption(cycle,roueNonInitialise)\n\n"
            return
         }
         fconfigure $tty -mode "19200,n,8,1" -buffering none -blocking 0

         # Initialise la roue a filtres
         ::console::affiche_resultat "$::caption(cycle,initialiseRoue)\n"
         puts -nonewline $tty "WSMODE"
         while {1==1} {
            after 100
            set char [read $tty 10]
           #::console::affiche_resultat "$char"
            if {[lsearch -exact $char "!"] == 0} {
               break
            }
         }
         #--------

         # Changement de filtre
         ::console::affiche_resultat "$::caption(cycle,changeFiltre)\n"
         puts -nonewline $tty "WGOTO$pos"
         while {1==1} {
            after 100
            set char [read $tty 10]
            #::console::affiche_resultat "$char"
            if {[lsearch -exact $char "*"] == 0} {
               break
            }
         }

         puts -nonewline $tty "WFILTR"
         while {1==1} {
            after 100
            set char [read $tty 10]
            #::console::affiche_resultat "$char"
            if {[llength $char] == 1} {
               break
            }
         }

         if {$pos != $char} {
            ::console::affiche_erreur "$::caption(cycle,probleme)\n"
         }

         # clos la connexion avec la roue a filtres
         ::console::affiche_resultat "$::caption(cycle,fermeCom)\n"
         puts -nonewline $tty "WEXITS"
         while {1==1} {
            after 100
            set char [read $tty 10]
            #::console::affiche_resultat "$char"
            if {[lsearch -exact $char "END"] == 0} {
               break
            }
         }
         close $tty
         #--------

         ::console::affiche_resultat "$::caption(cycle,filtre) $private(filtrecourant) exptime = $private(exptime) sec\n"

         for { set i 1 } {$i <= $private(nbimgparfiltre)} {incr i} {

            if {[file exists $fichlock]==1} {
               break
            }

            #--------
            ::console::affiche_resultat "$::caption(cycle,acquisition) $private(exptime) $private(filtrecourant)\n"
            $::cycle::camera exptime $private(exptime)
            $::cycle::camera acq
            vwait status_$::cycle::camera
            ::confVisu::autovisu $visuNo

            set ent      [ mc_date2ymdhms [ ::audace::date_sys2ut now] ]
            set entete   [ format "%04d%02d%02d%02d%02d" [lindex $ent 0] [lindex $ent 1] [lindex $ent 2] [lindex $ent 3] [lindex $ent 4] ]
            set dir      [ format "%04d%02d%02d" [lindex $ent 0] [lindex $ent 1] [lindex $ent 2] ]
            createdir_ifnot_exist [ file join $::conf(rep_images) "$dir" ]
            set file     [ file join $::conf(rep_images) "$dir" "T1M.$entete.$private(object).$private(filtrecourant).$private(affbin).$num" ]
            set filelong "$file$::conf(extension,defaut)"
            if {[file exists $filelong]==0} {
               #--- Rajoute des mots cles dans l'en-tete FITS
               foreach keyword [ ::keyword::getKeywords $visuNo $::conf(acqt1m,keywordConfigName) ] {
                  $buffer setkwd $keyword
               }
               #--- Rajoute d'autres mots cles
               $buffer setkwd [list "OBJECT" $private(object) string "" "" ]
               $buffer setkwd [list "FILTER" $private(filtrecourant) string "" "" ]
               saveima $filelong $visuNo
               ::console::affiche_resultat "$::caption(cycle,energistre) $filelong\n"
               set num [incr num]
            }
            #--------
         }

      }

   }

}

