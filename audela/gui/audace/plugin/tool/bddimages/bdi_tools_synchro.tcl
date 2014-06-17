#--------------------------------------------------
# source bdi_tools_synchro.tcl
#--------------------------------------------------
#
# Fichier        : bdi_tools_synchro.tcl
# Description    : Environnement de synchronisation des bases
# Auteur         : Frederic Vachier
# Mise à jour $Id: bdi_tools_synchro.tcl 6858 2011-03-06 14:19:15Z fredvachier $
#
namespace eval bdi_tools_synchro {

      package require md5 

      variable delay 5
}



   proc ::bdi_tools_synchro::launch_socket {  } {

#      catch { console show }
#      catch { wm protocol . WM_DELETE_WINDOW exit }
      set port 6000 ;# 0 if no known free port
      set rc [catch {
        set channel [socket -server server $port]
        set ::bdi_tools_synchro::channel $channel

        #puts "$channel: [fconfigure $channel -sockname]"

        if {$port == 0} {
          set port [lindex [fconfigure $channel -sockname] end]
          puts "--> server port: $port"
        }
      } msg]
      if {$rc == 1} {
        ::bdi_tools_synchro::log server <exiting>\n***$msg
        exit
      }
      set (server:host) server
      set (server:port) $port


      # enter event loop
      log $channel "Socket Ouvert"
      vwait forever

   }

  proc ::bdi_tools_synchro::close_socket { { channel ""} } {
  
     if {$channel == ""} {set channel $::bdi_tools_synchro::channel}
     log $channel "Socket Close "
     set err [catch { close $channel } msg ]
     if {$err} {
        #puts "Fermeture Socket : $err $msg\n"
     }
     
  }






  proc ::bdi_tools_synchro::reopen_socket { } {
      ::bddimages::ressource
      #gren_erreur "reopen_socket...\n"
      close_socket
      $::bdi_tools_synchro::rapport delete 0.0 end

      ::bdi_tools_synchro::launch_socket
  }




   proc ::bdi_tools_synchro::connect_to_socket {  } {
      
      ::bddimages::ressource
      $::bdi_tools_synchro::rapport delete 0.0 end
      $::bdi_gui_synchro::liste delete 0 end


      set host $::bdi_tools_synchro::address
      set port 6000
      set rc [catch { set ::bdi_tools_synchro::channel [socket $host $port] } msg]
      if {$rc == 1} { 
         ::bdi_tools_synchro::log "" $msg
         return 
      } else {
         ::bdi_tools_synchro::log $::bdi_tools_synchro::channel "Connection reussi sur $host :$port socket=$::bdi_tools_synchro::channel"
         
      }
   }

  proc ::bdi_tools_synchro::server {channel host port} {
    # save client info
    set ::($channel:host) $host
    set ::($channel:port) $port

    #puts "ici $channel $::($channel:host) $::($channel:port)"
    
    set ::bdi_tools_synchro::host $host
    set ::bdi_tools_synchro::port $port

    # log
    #log $channel <opened>
    set rc [catch {
      # set call back on reading
      fileevent $channel readable [list ::bdi_tools_synchro::input_server $channel]
    } msg]
    if {$rc == 1} {
      # i/o error -> log
      log server ***$msg
    }
    
  }

  # client e/s
  proc ::bdi_tools_synchro::getline { channel } {

      set rc [catch { set count [gets $channel line] } msg]
            
      if {$rc == 1} {
        # i/o error -> log & close
        #log $channel "*gl**$msg"
        catch { close $channel }
        return -code 0 ""
      } elseif {$count == -1} {
        # client closed -> log & close
        #::bdi_tools_synchro::log $channel <closedd>
        catch { close $channel}
        return -code 0 ""
      } else {
        # got data -> do some thing
        return -code 0 $line        
      }
   }

# ::bdi_tools_synchro::free_channel $::bdi_tools_synchro::channel
  proc ::bdi_tools_synchro::free_channel { channel } {
      set cpt 0
      while {[gets $channel]!=""} {
         incr cpt
         if {$cpt > 100} {break}
      }
   }

  proc ::bdi_tools_synchro::I_receive_var_old { channel } {
     
      set err [catch { set line [::bdi_tools_synchro::getline $channel] } msg ]
      if {$err} {
         log $channel "<error> $msg"
         return -code 1
      }
      return $line
  }

  proc ::bdi_tools_synchro::I_receive_var { channel var p_val { waiting "inf" }  } {
     
      upvar $p_val val

      
      set cpt 0
      set a 0
      set b 0
      set c 0
      while {!($a && $b && $c)} {

         set rc [catch { set count [gets $channel line] } msg]
#         puts "Rr1($cpt):$line"

         set a [expr $rc == 0]
         set b [expr $count == [ string length $var]]
         set c [string equal $line $var]
         
         if {$waiting!="inf"} {
            if {$cpt > 1000} {
               return -code 1
            }
         }
         after $::bdi_tools_synchro::delay
         incr cpt
      }
      
      #puts "? $a $b $c"
      
      if {$a && $b && $c} {
         set rc [catch { set count [gets $channel line] } msg]
#         puts "Rr2:$line"
         if {$rc == 0 && $count >0 } {
            set val $line
#            puts "R: $var = $val"
            return 0
         } else {
            puts "Fin anormale de lecture de $var : 1"
            return -code 2
         }
      } else {
         puts "Fin anormale de lecture de $var : 2"
         set r [string equal $line $var]
         puts "count = ($count)"
         puts "line = ($line) <> ($var) | $r"
         ::bdi_tools_synchro::free_channel $channel
         return -code 3
      }
      after $::bdi_tools_synchro::delay
     
  }

  proc ::bdi_tools_synchro::I_send_var { channel var val} {
  
      puts $channel $var
      puts $channel $val
      flush $channel
      #puts "S: $var = $val"

  }
  
  proc ::bdi_tools_synchro::I_receive_file { channel p_tmpfile filesize } {
  
      upvar $p_tmpfile tmpfile
      global bddconf

      #set flog [open "/tmp/synchro.receive.log" a]
      #puts $flog "I_receive_file"
      #close $flog

      #set flog [open "/tmp/synchro.receive.log" a]
      #puts $flog "receive: Demarrage du telechargement"

      set tmpfile [file join $bddconf(dirtmp) "tmp.[pid].fits.gz"]

      #puts $flog "receive: tmpfile = $tmpfile"
      #close $flog

      set fd [open $tmpfile w]
      fconfigure $fd -translation binary
      fconfigure $channel -translation binary -blocking 1
      fcopy $channel $fd -size $filesize
      close $fd
      
      #gren_info "fin du telechargement\n"
      #puts "R: Binary file $tmpfile"

      #set flog [open "/tmp/synchro.receive.log" a]
      #puts $flog "receive: end"
      #close $flog

  }
  
  proc ::bdi_tools_synchro::I_send_file { channel filename filesize { file "" } } {
  
      #set flog [open "/tmp/synchro.send.log" a]
      #puts $flog "I_send_file"

      if {$file == "file"} { 
         #puts $flog "send : var = file to server"
         #gren_info "** send file to server\n"
         #puts "** send file to server"
         puts $channel "file" 
         after 100
      }

      #puts $flog "send : filename = $filename"
      
      #puts "S: Binary file $filename"
      set fd [open $filename]
      fconfigure $fd  -translation binary
      fconfigure $channel  -translation binary
      fcopy $fd $channel -size $filesize
      close $fd
      flush $channel

      #puts $flog "send : end"
      #close $flog

  }






   proc ::bdi_tools_synchro::input_server { channel } {
 

      global message
      global bddconf


      if {[eof $channel]} {
        # client closed -> log & close
        log $channel <closeda>
        catch { ::bdi_tools_synchro::close_socket $channel}
      } else {


         set err [catch { set var [getline $channel] } msg ]
         if {$err} {
            puts "<error> $msg"
            log $channel "<error> $msg"
            return
         }

         if {$var == ""} {
            puts "var vide"
            return
         }

         if {$var != "file"} {
            set err [catch { set val [getline $channel] } msg ]
            if {$err} {
               addlog "<error> $msg"
               return
            }
#            set flog [open "/tmp/synchro.server.log" a]
#            puts $flog "[mc_date2iso8601 now] $var=$val"
#            close $flog
#            puts "[mc_date2iso8601 now] $var=$val"
         } else {
            
#            set flog [open "/tmp/synchro.server.log" a]
#            puts $flog "[mc_date2iso8601 now] ($var)"
#            puts $flog "demarrage du telechargement ?" 
#            close $flog
            
            #puts "[mc_date2iso8601 now] ($var)" 
            #gren_info "demarrage du telechargement ?\n"
            #puts "[mc_date2iso8601 now] demarrage du telechargement ?"
         }


#         set flog [open "/tmp/synchro.server.log" a]
#         puts $flog "[mc_date2iso8601 now] RE($var)"
#         close $flog

         switch $var {
            "PING" {
               set ::bdi_tools_synchro::tt0 [clock clicks -milliseconds]
               array unset message
               ::bdi_tools_synchro::I_send_var $channel "PING" 1
               set tt [format "%.3f" [expr ([clock clicks -milliseconds] - $::bdi_tools_synchro::tt0)/1000.]]
               addlog "Ping receive in $tt sec"
            }
            "CHECK_SYNC_BDI" {
               array unset message
               set ::bdi_tools_synchro::tt0 [clock clicks -milliseconds]
               addlog "Analysing Server Database..."

               set r [::bdi_tools_synchro::build_file_table_images]
               set message(md5) [lindex $r 0]
               set message(filename) [lindex $r 1]
               set message(filesize) [lindex $r 2]
               
               ::bdi_tools_synchro::I_send_var $channel md5      $message(md5)
               ::bdi_tools_synchro::I_send_var $channel filesize $message(filesize)
               ::bdi_tools_synchro::I_send_file $channel $message(filename) $message(filesize)
                           
               set tt [format "%.3f" [expr ([clock clicks -milliseconds] - $::bdi_tools_synchro::tt0)/1000.]]
               addlog "Analyse and send data ended in $tt sec"
            }
            "SYNC_BDI" {
               set ::bdi_tools_synchro::tt0 [clock clicks -milliseconds]
               array unset message
               set message(synchro) $val
               puts "R : $val"
               ::bdi_tools_synchro::I_send_var $channel status "PENDING"
            }
            "filename" {
               set message(filename) $val
               addlog "File : $message(filename) Download..."
            }
            "md5" {
               set message(md5) $val
            }
            "modifdate" {
               set message(modifdate) $val
            }
            "filesize" {
               set message(filesize) $val
            }
            "exist" {
               set message(exist) $val
            }
            "fileX" {
               set message(tmpfile) [file join $bddconf(dirtmp) "tmp.[pid].fits.gz"]
               set fd [open $message(tmpfile) w]
               fconfigure $fd -translation binary
               fconfigure $channel -translation binary  -blocking 0
               fcopy $channel $fd -size $message(filesize)
               close $fd
            }
            "file" {
#               set flog [open "/tmp/synchro.server.log" a]
#               puts $flog "reception du fichier"
#               close $flog
               
               ::bdi_tools_synchro::I_receive_file $channel message(tmpfile) $message(filesize)
               #set message(tmpfile) [file join $bddconf(dirtmp) "tmp.[pid].fits.gz"]
#               puts "tmpfile: $message(tmpfile)\n"
               ::bdi_tools_synchro::I_send_var $channel status "UPLOADED"
            }
            "work" {
               
               update
               
               if {$message(synchro)=="S->C"} {
                  #gren_info "work      : $val \n"

                  #gren_info "File      : $message(filename) \n"
                  set dirfilename [file dirname $message(filename)]
                  set filename [file tail $message(filename)]
                  set sqlcmd "SELECT sizefich,datemodif FROM images WHERE filename='$filename' AND dirfilename='$dirfilename';"
             
                  set err [catch {set data [::bddimages_sql::sql query $sqlcmd]} msg]
                  if {$err} {
                     puts "ERROR: sql = $sqlcmd"
                     puts "       err = $err"
                     puts "       msg = $msg"
                  }
                  set data [lindex $data 0]
                  set filesize_sql [lindex $data 0]
                  set modifdate    [lindex $data 1]
                  
                  #puts "filesize_sql = $filesize_sql\n"
                  #puts "modifdate = $modifdate\n"
                  
                  set file [file join $bddconf(dirbase) $message(filename)]
                  
                  set filesize_disk [file size $file]
                  if {$filesize_disk==$filesize_sql} {

                     ::bdi_tools_synchro::I_send_var $channel status "FILEOK"
                     set filesize $filesize_sql

                  } else {

                     ::bdi_tools_synchro::I_send_var $channel status "Bad file size on serveur"
                     addlog "Bad file size on serveur"
                     flush $channel
                     return

                  }
                  
                  set md5 [::md5::md5 -hex -file $file]
                  
                  ::bdi_tools_synchro::I_send_var  $channel md5       $md5
                  ::bdi_tools_synchro::I_send_var  $channel filesize  $filesize
                  ::bdi_tools_synchro::I_send_var  $channel modifdate $modifdate
                  ::bdi_tools_synchro::I_send_file $channel $file     $filesize
               }
               
               if {$message(synchro)=="C->S"} {

                  #gren_info "work      : $val \n"

                  #gren_info "File      : $message(filename) \n"
                  #gren_info "Filesize  : $message(filesize) \n"
                  #gren_info "Modifdate : $message(modifdate) \n"
                  #gren_info "Exist     : $message(exist) \n"
                  #gren_info "MD5       : $message(md5) \n"
                  #gren_info "tmpfile   : $message(tmpfile) \n"

                  set md5_r [::md5::md5 -hex -file $message(tmpfile)]
                  if {$message(md5) != $md5_r} {
                     addlog "Erreur : Bad MD5"
                     flush $channel
                     return
                  }

                  set newfile [file join $bddconf(dirtmp) [file tail $message(filename)] ]
                  set err [catch {file rename -force $message(tmpfile) $newfile} msg]
                  if {$err} {
                     addlog "Erreur : rename file : $msg"
                     flush $channel
                     return
                  }

                  # recuperation de idbddimg
                  set df [file dirname $message(filename)]
                  set fn [file tail $message(filename)]
                  set sqlcmd "SELECT idbddimg FROM images WHERE filename='$fn' AND dirfilename='$df';"
                  set err [catch {set data [::bddimages_sql::sql query $sqlcmd]} msg]
                  if {$err} {
                     addlog "Erreur : find idbddimg - err = $err"
                     addlog "sql = $sqlcmd"
                     addlog "msg = $msg"
                     flush $channel
                     return
                  }
                  
                  if {[llength $data]==0} { 
                     #gren_info "data vide\n"
                     set exist 0
                  } else {
                  
                     catch { unset idbddimg }
                     set err [ catch { 
                                       set data [lindex $data 0]
                                       #gren_info "data = $data\n"
                                       set idbddimg [lindex $data 0] 
                                       #gren_info "idbddimg = $idbddimg\n"
                                     } msg ]
                     if {![info exists idbddimg]} {
                        set exist 0
                     } else {
                        set exist 1
                     }                  
                  }

                  if {!$message(exist) && $exist} {
                     addlog "Erreur : le fichier existe et ne devrait pas."
                     flush $channel
                     return
                  }
                  
                  if {$message(exist) && !$exist} { 
                     addlog "Erreur : le fichier n'existe pas alors qu'il devrait."
                     flush $channel
                     return
                  }
                  
                  if {$message(exist) && $exist} {
                     bddimages_image_delete $idbddimg
                  }

                  set err [catch {set idbddimg [insertion_solo $newfile]} msg]
                  if {$err} {
                     addlog "Erreur : insertion file : $msg"
                     flush $channel
                     return
                  }
                  # modif la datemodif de $idbddimg
                  set sqlcmd "UPDATE images SET datemodif='$message(modifdate)' WHERE idbddimg=$idbddimg;"
                  set err [catch {set data [::bddimages_sql::sql query $sqlcmd]} msg]
                  if {$err} {
                     puts "ERROR: sql = $sqlcmd"
                     puts "       err = $err"
                     puts "       msg = $msg"
                     addlog "Erreur : UPDATE SQL : err = $err"
                     addlog "sql = $sqlcmd"
                     addlog "msg = $msg"
                     flush $channel
                     return
                  }

                  ::bdi_tools_synchro::I_send_var $channel status SUCCESS

               }
               

               flush $channel

               set tt [format "%.3f" [expr ([clock clicks -milliseconds] - $::bdi_tools_synchro::tt0)/1000.]]
               
               addlog "Finish in $tt sec"

            }
         }
      }
   }

  # log

  proc ::bdi_tools_synchro::log { channel msg {cend ""} } {
  #      $::bdi_tools_synchro::rapport insert end "($::bdi_tools_synchro::host)::($::bdi_tools_synchro::port): $msg\n"
  #     puts "($::bdi_tools_synchro::host)::($::bdi_tools_synchro::port): $msg" 
  #    set entete "[mc_date2iso8601 now]\[$channel\]:"
      set entete "[mc_date2iso8601 now]:"
      $::bdi_tools_synchro::rapport insert end "$entete ${msg}${cend}"
  #    puts "$entete $msg [fconfigure $channel -sockname]" 

  }




  proc ::bdi_tools_synchro::addlog { msg {cend ""} } {
      set entete "\n[mc_date2iso8601 now]:"
      $::bdi_tools_synchro::rapport insert end "$entete ${msg}${cend}"
  }




  proc ::bdi_tools_synchro::ping_socket { } {
     
      set ::bdi_tools_synchro::tt0 [clock clicks -milliseconds]
      if {![info exists ::bdi_tools_synchro::channel]} {
         addlog "Socket not connected"
         return -code 3
      }

      ::bdi_tools_synchro::I_send_var $::bdi_tools_synchro::channel "PING" 0
      set err [::bdi_tools_synchro::I_receive_var $::bdi_tools_synchro::channel "PING" val]
      
      if {$err} { 
         addlog "Ping Error."
         ::bdi_tools_synchro::free_channel $::bdi_tools_synchro::channel
         return -code 2
      }

      if {$val==1} {
         set tt [format "%.3f" [expr ([clock clicks -milliseconds] - $::bdi_tools_synchro::tt0)/1000.]]
         addlog "Ping finish $tt sec"
         return 0
      } else {
         addlog "Ping Error."
         ::bdi_tools_synchro::free_channel $::bdi_tools_synchro::channel
         return -code 1
      }
  }








  proc ::bdi_tools_synchro::check_synchro { } {
  
      set ::bdi_tools_synchro::tt0 [clock clicks -milliseconds]
      if {![info exists ::bdi_tools_synchro::channel]} {
         addlog "Socket not connected"
         return
      }

      set tt0 [clock clicks -milliseconds]
 
      #::bdi_tools_synchro::free_channel $::bdi_tools_synchro::channel

      # Envoie de l action sur le serveur
      ::bdi_tools_synchro::I_send_var $::bdi_tools_synchro::channel "CHECK_SYNC_BDI" 0

      # MD5
      set err [catch {::bdi_tools_synchro::I_receive_var $::bdi_tools_synchro::channel md5 md5} msg]
      if {$err} { 
         ::bdi_tools_synchro::free_channel $::bdi_tools_synchro::channel
         return -code 1 
      }
      gren_info "md5 = $md5\n"

      # filesize
      set err [catch {::bdi_tools_synchro::I_receive_var $::bdi_tools_synchro::channel filesize filesize} msg]
      if {$err} { 
         ::bdi_tools_synchro::free_channel $::bdi_tools_synchro::channel
         return -code 1 
      }
      gren_info "filesize = $filesize\n"

      # file
      ::bdi_tools_synchro::I_receive_file $::bdi_tools_synchro::channel tmpfile $filesize

      set md5receive [::md5::md5 -hex -file $tmpfile]
      if {$md5receive!=$md5} {
         addlog "Error : bad file comparison."
         return
      }

      ::bdi_tools::gunzip $tmpfile
      set ext  [file extension $tmpfile]
      set pos  [expr [string last $ext $tmpfile] -1]
      set tmpfile [string range $tmpfile 0 $pos]
      if {[file exists $tmpfile]} {
         gren_info "tmpfile = $tmpfile\n"
         source $tmpfile
         set data_server $data
         unset data
      } else {
         addlog "Erreur durant l'analyse. Mauvais fichier serveur."
         return
      }
      # Recupere les donnees du client
      ::bdi_tools_synchro::get_table_images data_client
      
      set ::bdi_tools_synchro::data_client $data_client
      set ::bdi_tools_synchro::data_server $data_server
      
      ::bdi_tools_synchro::search_todo data_client data_server

      set ::bdi_tools_synchro::data_client $data_client
      set ::bdi_tools_synchro::data_server $data_server

      set nb_maj_client [llength $::bdi_tools_synchro::data_client]
      set nb_maj_server [llength $::bdi_tools_synchro::data_server]
      
      set tt [format "%.3f" [expr ([clock clicks -milliseconds] - $tt0)/1000.]]
      addlog "Analyse finished in $tt sec. $nb_maj_client files on Client and $nb_maj_server on server need update."
  }










   proc ::bdi_tools_synchro::search_todo { p_data_client p_data_server } {
      
      upvar $p_data_client data_client
      upvar $p_data_server data_server

      set tt0 [clock clicks -milliseconds]


      array unset tab_server
      array unset tab_client
      
      gren_info "data serveur \n"
      foreach line $data_server {
         set f [file join [lindex $line 0] [lindex $line 1]]
         set s [lindex $line 2]
         set m [lindex $line 3]
         set tab_server($f)   1
         set tab_server_m($f) $m
         set tab_server_s($f) $s
#         gren_info "$f\n"
      }
      gren_info "data client \n"
      foreach line $data_client {
         set f [file join [lindex $line 0] [lindex $line 1]]
         set s [lindex $line 2]
         set m [lindex $line 3]
         set tab_client($f)   1
         set tab_client_m($f) $m
         set tab_client_s($f) $s
#         gren_info "$f\n"
      }
      set maj_sur_client ""
      set maj_sur_serveur ""

      gren_info "--------------------------\n"
      foreach { f y } [array get tab_client] {
         gren_info "$f\n"
         if {[info exists tab_server($f)]} {
         
            if { [string equal $tab_client_m($f) $tab_server_m($f)]} {
               if {$tab_client_s($f) != $tab_server_s($f)} {
                  gren_erreur "# synchronisation impossible\n"
               } else {
                  gren_info "# fichier identique\n"
                  unset tab_server($f)
               }
            } else {
               set jd_client [mc_date2jd $tab_client_m($f)]
               set jd_server [mc_date2jd $tab_server_m($f)]
               
               if {$jd_client < $jd_server} {
                  gren_info "# fichier plus recent sur serveur $tab_client_m($f) $tab_server_m($f)\n"
                  lappend maj_sur_client [list 1 "S->C" $tab_server_m($f) $tab_server_s($f) $f ]
               } else {
                  gren_info "# fichier plus recent sur client $tab_client_m($f) $tab_server_m($f)\n"
                  lappend maj_sur_serveur [list 1 "C->S" $tab_client_m($f) $tab_client_s($f) $f ]
               }
               unset tab_server($f)
            }
         } else {
            gren_info "# fichier manquant sur serveur\n"
            lappend maj_sur_serveur [list 0 "C->S" $tab_client_m($f) $tab_client_s($f) $f]
         }
      }

      set nb [expr [llength [array get tab_server]] /2]
      gren_info "nb = $nb\n"
      if {$nb!=0} {
         foreach { f y } [array get tab_server] {
#            gren_info "$f\n"
#            gren_info "# fichier manquant sur client\n"
            lappend maj_sur_client [list 0 "S->C" $tab_server_m($f) $tab_server_s($f) $f]
         }
      }

      set nb_maj_client [llength $maj_sur_client]
      set nb_maj_server [llength $maj_sur_serveur]

#      gren_info "------------------------------------------\n"
#      gren_info "nb maj client = $nb_maj_client\n"
#      gren_info "nb maj server = $nb_maj_server\n"
#      gren_info "------------------------------------------\n"
      
      set data_client $maj_sur_client
      set data_server $maj_sur_serveur

      set tt [format "%.3f" [expr ([clock clicks -milliseconds] - $tt0)/1000.]]
      gren_info "analyse du travail a faire finie en $tt sec\n"

  }









   proc ::bdi_tools_synchro::get_table_images { p_data } {
      
      upvar $p_data data

      global bddconf
      global caption

      set sqlcmd "SELECT dirfilename,filename,sizefich,datemodif FROM images;"
      set err [catch {set data [::bddimages_sql::sql query $sqlcmd]} msg]
      if {$err} {
         tk_messageBox -message "$caption(bdi_status,consoleErr2) $msg" -type ok
         return
      }

      return 

#      set nb [llength $data]
#      gren_info "nb data : $nb\n"


#      foreach line $data {
#         set dirfilename [lindex $line 0]
#         set filename    [lindex $line 1]
#         set sizefich    [lindex $line 2]
#         set datemodif   [lindex $line 3]
#         gren_info "$dirfilename $filename $sizefich $datemodif\n"
#      }


   }


   proc ::bdi_tools_synchro::build_file_table_images { } {

      global bddconf

      ::bdi_tools_synchro::get_table_images data
      
      set nb [llength $data]

      set filename [file join $bddconf(dirtmp) "table_images.dat"]
      set h [open $filename "w"]
      set data "set data { $data }"
      puts $h $data
      close $h
      ::bdi_tools::gzip $filename
      set filename "$filename.gz"
      set md5      [::md5::md5 -hex -file $filename]
      set filesize [file size $filename]
      
      return [list $md5 $filename $filesize]
   }



   proc ::bdi_tools_synchro::build_synchro { p_mylist } {

      upvar $p_mylist mylist

      set nb_maj_client [llength $::bdi_tools_synchro::data_client]
      set nb_maj_server [llength $::bdi_tools_synchro::data_server]
      set mylist ""

      if {$nb_maj_client >0 &&  $::bdi_tools_synchro::param_check_maj_client == 1} {
         set mylist $::bdi_tools_synchro::data_client
      }
      
      if {$nb_maj_server >0 &&  $::bdi_tools_synchro::param_check_maj_server == 1} {
         set mylist [concat $mylist $::bdi_tools_synchro::data_server]
      }
      set nb_list [llength $mylist]
      if {$nb_list>0} {
         set i 0
         foreach l $mylist {
            if {$::bdi_tools_synchro::param_check_exist == 1 && [lindex $l 0] ==1 } {
               set mylist [lreplace $mylist $i $i ]
               continue
            }
            incr i
         }
      
      } else {
         gren_info "Nothing to do..\n"
      }


   }

   proc ::bdi_tools_synchro::stop_synchro { } {
      $::bdi_tools_synchro::buttons_synchro configure -state "normal"
      set ::bdi_tools_synchro::stop 1
   }
   
   proc ::bdi_tools_synchro::launch_synchro { } {

      global bddconf

      set tt0 [clock clicks -milliseconds]
      addlog "Synchronisation begin"
      set ::bdi_tools_synchro::stop 0
      $::bdi_tools_synchro::buttons_synchro configure -state "disabled"

      #$::bdi_tools_synchro::param_check_nothing
      #$::bdi_tools_synchro::param_check_maj_client
      #$::bdi_tools_synchro::param_check_maj_server
      #$::bdi_tools_synchro::param_check_exist

      # Constitution de la liste 
      ::bdi_tools_synchro::build_synchro mylist
      catch {::bdi_gui_synchro::affich_synchro mylist}
      # Action
      set nb_list [llength $mylist]

      if {$::bdi_tools_synchro::param_check_nothing==1||$nb_list==0} {
         $::bdi_tools_synchro::buttons_synchro configure -state "normal"
         addlog "Nothing to do ! Check parameters...\n"
         return
      }
      
      
      set err [catch {::bdi_tools_synchro::ping_socket} msg ]
      if {$err} {
         puts "Ping erreur : ($err) $msg"
      }
      

      set id -1

      gren_info "NB img todo = [llength $mylist ]\n"
      
      foreach l $mylist {

         update
         incr id

         set todo [$::bdi_gui_synchro::liste cellcget $id,1  -text]
         
         $::bdi_gui_synchro::liste see $id
         
         if {$todo!="TODO"} {
            continue
         }
         
         if {$::bdi_tools_synchro::stop} {break}
         
         set exist     [lindex $l 0 ]
         set synchro   [lindex $l 1 ]
         set modifdate [lindex $l 2 ]
         set filesize  [lindex $l 3 ]
         set filename  [lindex $l 4 ]

         #gren_info "flush\n"      
         flush $::bdi_tools_synchro::channel
            
         #gren_info "id=$id  E=$exist Sy=$synchro D=$modifdate S=$filesize F=$filename\n"
         
         if {$synchro=="S->C"} {

            #gren_info "ok c est parti $synchro\n"
            catch  {$::bdi_gui_synchro::liste cellconfigure $id,1 -bg white -foreground darkgreen -text PENDING}

            # Envoie de l action sur le serveur
            ::bdi_tools_synchro::I_send_var $::bdi_tools_synchro::channel "SYNC_BDI" $synchro
            #gren_info "SYNC_BDI = $synchro\n"

            # Reception du status
            ::bdi_tools_synchro::I_receive_var $::bdi_tools_synchro::channel status status
            #gren_info "Status = $status\n"

            # Ok le serveur est dispo on passe en PROCESSING
            if {$status=="PENDING"} {
               catch  {$::bdi_gui_synchro::liste cellconfigure $id,1 -bg white -foreground darkgreen -text PROCESSING}
            } else {
               catch  {$::bdi_gui_synchro::liste cellconfigure $id,1 -bg red -foreground white -text ERROR}
               if {$::bdi_tools_synchro::param_check_error} { continue } else { return }
            }
            update
            
            # Envoie le nom du fichier
            ::bdi_tools_synchro::I_send_var $::bdi_tools_synchro::channel filename $filename
            #gren_info "filename send\n"
            ::bdi_tools_synchro::I_send_var $::bdi_tools_synchro::channel work     1
            #gren_info "work send\n"

            ::bdi_tools_synchro::I_receive_var  $::bdi_tools_synchro::channel status status inf
            #gren_info "status       = $status \n"

            if {$status!="FILEOK"} {
               addlog "Erreur : $status"
               catch  {$::bdi_gui_synchro::liste cellconfigure $id,1 -bg red -foreground white -text ERROR}
               if {$::bdi_tools_synchro::param_check_error} { continue } else { return }
            }

            # Reception 
            ::bdi_tools_synchro::I_receive_var  $::bdi_tools_synchro::channel md5 md5_r 
            #gren_info "md5       = $md5_r \n"
            ::bdi_tools_synchro::I_receive_var  $::bdi_tools_synchro::channel filesize  filesize_r
            #gren_info "filesize  = $filesize $filesize_r\n"
            ::bdi_tools_synchro::I_receive_var  $::bdi_tools_synchro::channel modifdate modifdate_r
            #gren_info "modifdate = $modifdate $modifdate_r\n"
            
            if {$filesize!=$filesize_r} {
               gren_info "Erreur : Bad file size\n"
               addlog "Erreur : Bad file size"
               catch  {$::bdi_gui_synchro::liste cellconfigure $id,1 -bg red -foreground white -text ERROR}
               if {$::bdi_tools_synchro::param_check_error} { continue } else { return }
            }
            if {$modifdate!=$modifdate_r} {
               gren_info "Erreur : Bad modif date\n"
               addlog "Erreur : Bad modif date"
               catch  {$::bdi_gui_synchro::liste cellconfigure $id,1 -bg red -foreground white -text ERROR}
               if {$::bdi_tools_synchro::param_check_error} { continue } else { return }
            }

            catch  {$::bdi_gui_synchro::liste cellconfigure $id,1 -bg white -foreground darkgreen -text DOWNLOAD}
            update

            ::bdi_tools_synchro::I_receive_file $::bdi_tools_synchro::channel tmpfile $filesize


            #gren_info "tmpfile   = $tmpfile  \n"
            set md5 [::md5::md5 -hex -file $tmpfile]

            if {$md5 != $md5_r} {
               addlog "Erreur : Bad MD5"
               catch  {$::bdi_gui_synchro::liste cellconfigure $id,1 -bg red -foreground white -text ERROR}
               if {$::bdi_tools_synchro::param_check_error} { continue } else { return }
            }
            
            catch  {$::bdi_gui_synchro::liste cellconfigure $id,1 -bg white -foreground darkgreen -text INSERT}
            set newfile [file join $bddconf(dirtmp) [file tail $filename] ]
            #gren_info "newfile   = $newfile  \n"
            
            set err [catch {file rename -force $tmpfile $newfile} msg]
            if {$err} {
               addlog "Erreur : rename file : $msg"
               catch  {$::bdi_gui_synchro::liste cellconfigure $id,1 -bg red -foreground white -text ERROR}
               if {$::bdi_tools_synchro::param_check_error} { continue } else { return }
            }
            
            if {$exist} {

               set df [file dirname $filename]
               set fn [file tail $filename]
               set sqlcmd "SELECT idbddimg FROM images WHERE filename='$fn' AND dirfilename='$df';"
             
               set err [catch {set data [::bddimages_sql::sql query $sqlcmd]} msg]
               if {$err} {
                  addlog "Erreur : find idbddimg - err = $err"
                  addlog "sql = $sqlcmd"
                  addlog "msg = $msg"
                  catch  {$::bdi_gui_synchro::liste cellconfigure $id,1 -bg red -foreground white -text ERROR}
                  if {$::bdi_tools_synchro::param_check_error} { continue } else { return }
               }
               set data [lindex $data 0]
               set idbddimg [lindex $data 0]
            
               set err [catch {set ident [bddimages_image_identification $idbddimg]} msg ]
               if {$err} {
                  addlog "Erreur : bddimages_image_identification"
                  catch  {$::bdi_gui_synchro::liste cellconfigure $id,1 -bg red -foreground white -text ERROR}
                  if {$::bdi_tools_synchro::param_check_error} { continue } else { return }
               }
               set idbddimg     [lindex $ident 0]
               set fileimg      [lindex $ident 1]
               set idbddcata    [lindex $ident 2]
               set catafilebase [lindex $ident 3]
               set idheader     [lindex $ident 4]

               bddimages_image_delete $idbddimg
               
            } 
            

            set err [catch {set idbddimg [insertion_solo $newfile]} msg]
            #gren_erreur "idbddimg = $idbddimg\n"
            if {$err} {
               addlog "Erreur : insertion file : $msg"
               catch  {$::bdi_gui_synchro::liste cellconfigure $id,1 -bg red -foreground white -text ERROR}
               if {$::bdi_tools_synchro::param_check_error} { continue } else { return }
            }
            # modif la datemodif de $idbddimg
            set sqlcmd "UPDATE images SET datemodif='$modifdate' WHERE idbddimg=$idbddimg;"
            set err [catch {set data [::bddimages_sql::sql query $sqlcmd]} msg]
            if {$err} {
               puts "ERROR: sql = $sqlcmd"
               puts "       err = $err"
               puts "       msg = $msg"
            }

            catch  {$::bdi_gui_synchro::liste cellconfigure $id,1 -bg darkgreen -foreground white -text DONE}
            
         }

         if {$synchro=="C->S"} {

#            gren_info "ok c est parti $synchro\n"
            catch  {$::bdi_gui_synchro::liste cellconfigure $id,1 -bg white -foreground darkgreen -text PENDING}

            # Envoie de l action sur le serveur
            ::bdi_tools_synchro::I_send_var $::bdi_tools_synchro::channel "SYNC_BDI" $synchro
#            gren_info "SYNC_BDI = $synchro\n"

            # Reception du status
            ::bdi_tools_synchro::I_receive_var $::bdi_tools_synchro::channel status status
#            gren_info "Status = $status\n"

            # Ok le serveur est dispo on passe en PROCESSING
            if {$status=="PENDING"} {
               catch  {$::bdi_gui_synchro::liste cellconfigure $id,1 -bg white -foreground darkgreen -text PROCESSING}
            } else {
               catch  {$::bdi_gui_synchro::liste cellconfigure $id,1 -bg red -foreground white -text ERROR}
               if {$::bdi_tools_synchro::param_check_error} { continue } else { return }
            }

            catch  {$::bdi_gui_synchro::liste cellconfigure $id,1 -bg white -foreground darkgreen -text UPLOAD}

            # Envoie le nom du fichier
            ::bdi_tools_synchro::I_send_var $::bdi_tools_synchro::channel filename $filename
#            gren_info "filename send\n"

            # Envoie de la taille
            ::bdi_tools_synchro::I_send_var $::bdi_tools_synchro::channel filesize $filesize
#            gren_info "filesize send\n"

            # Envoie de la date
            ::bdi_tools_synchro::I_send_var $::bdi_tools_synchro::channel modifdate $modifdate
#            gren_info "modifdate send\n"

            # Envoie si le fichier existe ?
            ::bdi_tools_synchro::I_send_var $::bdi_tools_synchro::channel exist $exist
#            gren_info "exist send\n"

            # Envoie du md5
            set file [file join $bddconf(dirbase) $filename]
            set md5 [::md5::md5 -hex -file $file]
            # set md5 "toto"
            ::bdi_tools_synchro::I_send_var $::bdi_tools_synchro::channel md5 $md5
#            gren_info "md5 send\n"

            # Envoie du fichier
            ::bdi_tools_synchro::I_send_file $::bdi_tools_synchro::channel $file $filesize "file"
#            gren_info "file send\n"
            
            # reception fichier recu
            ::bdi_tools_synchro::I_receive_var $::bdi_tools_synchro::channel status status
#            gren_info "Status = $status\n"

            if {$status=="UPLOADED"} {
               catch  {$::bdi_gui_synchro::liste cellconfigure $id,1 -bg white -foreground darkgreen -text UPLOADED}
            } else {
               catch  {$::bdi_gui_synchro::liste cellconfigure $id,1 -bg red -foreground white -text ERROR}
               if {$::bdi_tools_synchro::param_check_error} { continue } else { return }
            }

            # Envoie de l action work
            ::bdi_tools_synchro::I_send_var $::bdi_tools_synchro::channel work 1
#            gren_info "work send\n"

            # Reception du status
            ::bdi_tools_synchro::I_receive_var $::bdi_tools_synchro::channel status status
#            gren_info "Status = $status\n"

            # Ok le serveur est dispo on passe en PROCESSING
            if {$status=="SUCCESS"} {
               catch  {$::bdi_gui_synchro::liste cellconfigure $id,1 -bg darkgreen -foreground white -text DONE}
            } else {
               catch  {$::bdi_gui_synchro::liste cellconfigure $id,1 -bg red -foreground white -text ERROR}
               if {$::bdi_tools_synchro::param_check_error} { continue } else { return }
            }

         }
      }
      
# Status : TODO  PENDING ERROR  PROCESSING DONE
# fond   : blanc blanc   rouge  vert       blanc
# police : noir  vert    blanc  blanc      vert

# $::bdi_gui_synchro::liste cellconfigure 0,1 -bg white -foreground darkgreen -text PENDING
# $::bdi_gui_synchro::liste cellconfigure 0,1 -bg white -foreground darkgreen -text PROCESSING
# $::bdi_gui_synchro::liste cellconfigure 0,1 -bg red -foreground white -text ERROR
# $::bdi_gui_synchro::liste cellconfigure 0,1 -bg darkgreen -foreground white -text DONE

      # Fin
      set tt [format "%.3f" [expr ([clock clicks -milliseconds] - $tt0)/1000.]]
      addlog "Synchronisation finished in $tt sec."
      $::bdi_tools_synchro::buttons_synchro configure -state "normal"
      

   }







  # ===================
  # start
  # ===================

  # open socket

# Dump de la base ...
  #set res [exec mysqldump --user=$user --password=$pwd $database $table]
  #set fout [open dump.sql w]
  #puts $fout $res
  #close $fout
