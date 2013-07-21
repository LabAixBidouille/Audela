#
# Fichier : ftp.tcl
# Description : Tool functions for an FTP Client access
# Auteur : Alain KLOTZ
# Mise à jour $Id$
#

# ==============================================================
# to get the list of file names in ftptoto.free.fr
# with user=tata and password=tutu
#
# ftpglob "dir" ftptoto.free.fr tata tutu
# ==============================================================
# to get the list of file names in ftptoto.free.fr/subdir
# with user=tata and password=tutu
#
# ftpglob "cd subdir\n dir" ftptoto.free.fr tata tutu
# ==============================================================
# to get (=copy to local disk) the file named titi.txt in
# ftptoto.free.fr/subdir with user=tata and password=tutu
#
# ftpscript ftptoto.free.fr "cd subdir\n prompt\n bin\n get titi.txt" tata tutu
# ==============================================================
# to get the list of folders in ftptoto.free.fr
# with user=tata and password=tutu
#
# ftpdirdecode [ftpscript ftptoto.free.fr "dir" tata tutu] dirs
# ==============================================================

proc ftpdirdecode { var {mode files} {size no} } {
   # input : var is a string returned by a DIR from ftpscript.
   # ftpdirdecode return a Tcl list of the filenames.
   # mode=files to return only the list of the file names
   # mode=dirs  to return only the list of the directory names
   # size=no|yes  adds size (in byte) for names
   set var [split "$var" \n"]
   set filenames ""
   set id0 "-r"
   if {$mode=="dirs"} {
      set id0 "dr"
   }
   foreach ligne $var {
      set n [string length $ligne]
      if {$n>10} {
         set id [string range $ligne 0 1]
         if {$id==$id0} {
            set lig "$ligne"
            set p2 -1
            for {set k 1} {$k<=8} {incr k} {
               set p1 [expr $p2+1]
               set lig [string range $lig $p1 end]
               set lig [string trimleft "$lig"]
               set p2 [string first " " $lig]
               set decode($k) [string range $lig 0 [expr $p2-1]]
            }
            set p1 [expr $p2+1]
            set lig [string range $lig $p1 end]
            set lig [string trimleft "$lig"]
            set name [string range $lig 0 end]
            if {$size=="no"} {
               lappend filenames "$name"
            } else {
               lappend filenames [list "$name" "$decode(5)"]
            }
         }
      }
   }
   return $filenames
}

proc ftpscript { hostname script {user anonymous} {passw software.audela@free.fr} } {
   # THIS FUNTION USE THE exec TCL FUNTION TO CALL FTP
   # IT CAN BLOCK THE TCL INTERPRETER IN CASE OF NET BREAKING.
   #
   # hostname : IP or ascii address
   # script : some FTP functions separated by \n
   # user : login username
   # passw : login password
   #
   # ftpscript 127.0.0.1 "pwd" toto tutu
   set win "" ; set os $::tcl_platform(os) ; catch {set win [string range $os 0 6]}
   # --- test the hostname connection
   set res [::audace_ping $hostname]
   if {[lindex $res 0]==0} {
      set result "address $hostname does not respond"
      return $result
   }
   # --- generate the script file
   set texte ""
   if {$os=="Linux"} {
      append texte "ftp -n -i $hostname <<LAPIN\n"
      append texte "user $user $passw\n"
   } elseif {$win=="Windows"} {
      append texte "open $hostname\n"
      append texte "$user\n"
      append texte "$passw\n"
   }
   append texte "$script\n"
   append texte "quit\n"
   if {$os=="Linux"} {
      append texte "LAPIN\n"
   }
   set filename "[clock seconds]_[clock clicks].ftp"
   set f [open $filename w]
   puts $f "$texte"
   close $f
   # --- execute FTP
   if {$os=="Linux"} {
      set errnum [catch {exec sh $filename} result]
   } elseif {$win=="Windows"} {
      set errnum [catch {exec ftp.exe -s:$filename} result]
   } else {
      set errnum 1
      set result "ftpscript not supported for operating system $os"
   }
   catch {file delete $filename}
   return $result
}

proc ftpglob { filtre {hostname none} {user anonymous} {passw software.audela@free.fr} } {
   # THIS FUNTION USE THE exec TCL FUNTION TO CALL FTP
   # IT CAN BLOCK THE TCL INTERPRETER IN CASE OF NET BREAKING.
   #
   # ex: set filtre "cd d/toto\n dir *.gz"
   #
   # outputs :
   # {1} { {file1 bytes1} {file2 bytes2} ...}
   # {0} { error_message }
   if {$hostname=="none"} {
      set errnum [catch {glob $filtre} result]
   } else {
      set result [ftpscript $hostname $filtre $user $passw]
      set res [ftpdirdecode $result files yes]
      set result [list [llength $res] $res ]
      # il faudra
   }
   return $result
}

proc ftpfileopen { path filtre timeoutmax {hostname none} {user anonymous} {passw software.audela@free.fr} } {
   # THIS FUNTION USE THE open TCL FUNTION TO CALL FTP
   # TO PREVENT BLOCKAGES OF THE TCL INTERPRETER IN CASE OF NET BREAKING.
   #
   # ex: set path c/toto
   #     set filtre dir ; # or delete tutu.txt
   #     set timeoutmax 30 ; # en secondes
   #     ftpfileopen $path $filtre ...
   #
   # outputs :
   # {1} { {file1 bytes1} {file2 bytes2} ...}
   # {0} { error_message }
   set win "" ; set os $::tcl_platform(os) ; catch {set win [string range $os 0 6]}
   set result ""
   if {$hostname=="none"} {
      set errnum [catch {glob $filtre} result]
   } else {
      # --- generate the script file
      set texte ""
      if {$os=="Linux"} {
         append texte "ftp -n -i $hostname <<LAPIN\n"
         append texte "user $user $passw\n"
      } elseif {$win=="Windows"} {
         append texte "open $hostname\n"
         append texte "$user\n"
         append texte "$passw\n"
      }
      if {$path!="."} {
         append texte "cd $path\n"
      }
      append texte "$filtre\n"
      append texte "quit\n"
      if {$os=="Linux"} {
         append texte "LAPIN\n"
      }
      set filename "[clock seconds]_[clock clicks].ftp"
      set f [open $filename w]
      puts $f "$texte"
      close $f
      # --- execute FTP
      if {$os=="Linux"} {
         set f [open "|sh $filename" w+]
      } elseif {$win=="Windows"} {
         set f [open "|ftp.exe -s:$filename" w+]
      } else {
         set result "ftp not supported for operating system $os"
      }
      #
      catch {
         fconfigure $f -blocking 0
         #
         set sortie no
         set loopout 0
         set loopoutmax 500
         set timeout0 [clock seconds]
         #::console::affiche_resultat "entree dans boucle\n"
         while {$sortie=="no"} {
            catch {update}
            set res [read $f 1000]
            if {$res==""} {
               incr loopout
               after 1
            } else {
               append result "$res"
            }
            if {($loopout>$loopoutmax)} {
               set sortie loopout
               break
            }
            set timeout [expr [clock seconds]-$timeout0]
            if {($timeout>$timeoutmax)&&($res==0)} {
               set sortie timeout
               break
            }
         }
         #puts -nonewline $f "quit"
      }
      #::console::affiche_resultat "sortie=$sortie\n"
      #::console::affiche_resultat "loopout=$loopout\n"
      #::console::affiche_resultat "timeout=$timeout\n"
      #
      set errnum [catch {close $f} res]
      #::console::affiche_resultat "errnum=$errnum\n"
      #
      #set f [open "ftpfileopen.txt" w]
      #puts $f "$result"
      #close $f
      #
      if {$errnum==0} {
         set result [list 1 [ftpdirdecode "$result" files yes]]
      } else {
         set result [list 0 "$res"]
      }
   }
   catch {file delete $filename}
   return $result
}

proc ftpscriptopen { script timeoutmax {hostname none} {user anonymous} {passw software.audela@free.fr} } {
   # THIS FUNTION USE THE open TCL FUNTION TO CALL FTP
   # TO PREVENT BLOCKAGES OF THE TCL INTERPRETER IN CASE OF NET BREAKING.
   #
   # ex: set script "cd c/toto\ndelete tutu.txt"
   #     set timeoutmax 30 ; # en secondes
   #     ftpscriptopen "$script" $filtre ...
   #
   # outputs :
   # {1} { returned_message }
   # {0} { error_message }
   set win "" ; set os $::tcl_platform(os) ; catch {set win [string range $os 0 6]}
   set result ""
   if {$hostname=="none"} {
      set errnum [catch {glob $filtre} result]
   } else {
      # --- generate the script file
      set texte ""
      if {$os=="Linux"} {
         append texte "ftp -n -i $hostname <<LAPIN\n"
         append texte "user $user $passw\n"
      } elseif {$win=="Windows"} {
         append texte "open $hostname\n"
         append texte "$user\n"
         append texte "$passw\n"
      }
      append texte "$script\n"
      append texte "quit\n"
      if {$os=="Linux"} {
         append texte "LAPIN\n"
      }
      set filename "[clock seconds]_[clock clicks].ftp"
      set f [open $filename w]
      puts $f "$texte"
      close $f
      # --- execute FTP
      if {$os=="Linux"} {
         set f [open "|sh $filename" w+]
      } elseif {$win=="Windows"} {
         set f [open "|ftp.exe -s:$filename" w+]
      } else {
         set result "ftp not supported for operating system $os"
      }
      #
      catch {
         fconfigure $f -blocking 0
         #
         set sortie no
         set loopout 0
         set loopoutmax 500
         set timeout0 [clock seconds]
         #::console::affiche_resultat "entree dans boucle\n"
         while {$sortie=="no"} {
            catch {update}
            set res [read $f 1000]
            if {$res==""} {
               incr loopout
               after 1
            } else {
               append result "$res"
            }
            if {($loopout>$loopoutmax)} {
               set sortie loopout
               break
            }
            set timeout [expr [clock seconds]-$timeout0]
            if {($timeout>$timeoutmax)&&($res==0)} {
               set sortie timeout
               break
            }
         }
      }
      #
      set errnum [catch {close $f} res]
      #
      if {$errnum==0} {
         set result [list 1 "$result"]
      } else {
         set result [list 0 "$res"]
      }
   }
   catch {file delete $filename}
   return $result
}

proc ftpgetopen { path fname timeoutmax {hostname none} {user anonymous} {passw software.audela@free.fr} } {
# THIS FUNTION USE THE open TCL FUNTION TO CALL FTP
# TO PREVENT BLOCKAGES OF THE TCL INTERPRETER IN CASE OF NET BREAKING.
# ex: set path d/toto
#     set fname tata.txt
#     set timeoutmax 30 ; # en secondes
#     ftpgetopen $path $fname $timeoutmax ...
# retourne le nombre d'octets du fichier tranferes et le nombre d'octets qui doivent etre transferes
# ( les deux valeurs doivent etre egales >0 )
   set win "" ; set os $::tcl_platform(os) ; catch {set win [string range $os 0 6]}
   set result 0
   # --- get the size of the desired file
   set res [ftpfileopen "$path" "dir $fname" 5 $hostname $user $passw]
   set n [lindex $res 0]
   if {$n<=0} {
      return ""
   }
   set res [lindex $res 1]
   #::console::affiche_resultat "   => res=$res\n"
   set sizemax 0
   catch {set sizemax [expr [lindex [lindex $res 0] 1]]}
   #::console::affiche_resultat "sizemax=$sizemax\n"
   #
   # --- generate the script file
   set texte ""
   if {$os=="Linux"} {
      append texte "ftp -n -i $hostname <<LAPIN\n"
      append texte "user $user $passw\n"
   } elseif {$win=="Windows"} {
      append texte "open $hostname\n"
      append texte "$user\n"
      append texte "$passw\n"
   }
   if {$path!="."} {
      append texte "cd $path\n"
   }
   append texte "bin\n"
   append texte "get $fname\n"
   append texte "quit\n"
   if {$os=="Linux"} {
      append texte "LAPIN\n"
   }
   set filename "[clock seconds]_[clock clicks].ftp"
   set f [open $filename w]
   puts $f "$texte"
   close $f
   #
   set ff [open ftp.log w]
   puts $ff $texte
   close $ff
   # --- execute FTP
   if {$os=="Linux"} {
      set f [open "|sh $filename" w+]
   } elseif {$win=="Windows"} {
      set f [open "|ftp.exe -s:$filename" w+]
   } else {
      set result "ftp not supported for operating system $os"
   }
   #
   catch {
      fconfigure $f -blocking 0
      #
      set sortie no
      set size0 0
      set timeout0 [clock seconds]
      set timeout 0
      #::console::affiche_resultat "entree dans boucle\n"
      set result ""
      while {$sortie=="no"} {
         catch {update}
         set res [read $f 100]
         if {$res==""} {
            after 1
         } else {
            append result "$res"
         }
         #
         set size $size0
         catch {set size [file size $fname]}
         #
         set ff [open ftp.log a]
         puts $ff $size
         close $ff
         #
         if {($size>=$sizemax)} {
            set sortie eof
            break
         }
         set dsize [expr $size-$size0]
         #::console::affiche_resultat "size=$size dsize=$dsize\n"
         after 1000
         set timeout [expr [clock seconds]-$timeout0]
         if {($timeout>$timeoutmax)&&($dsize==0)} {
            set sortie timeout
            break
         }
         set size0 $size
      }
   }
   #::console::affiche_resultat "result=$result\n"
   #::console::affiche_resultat "sortie=$sortie\n"
   #::console::affiche_resultat "timeout=$timeout\n"
   #
   set errnum [catch {close $f} res]
   #::console::affiche_resultat "errnum=$errnum\n"
   #::console::affiche_resultat "size=$size\n"
   #
   if {($sortie=="timeout")||($size==0)||($sizemax=="")} {
      set result [list 0 $sizemax]
   } else {
      set result [list $size $sizemax]
   }
   catch {file delete $filename}
   return $result
}

