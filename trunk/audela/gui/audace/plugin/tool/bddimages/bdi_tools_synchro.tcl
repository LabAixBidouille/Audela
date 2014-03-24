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
        log server <exiting>\n***$msg
        exit
      }
      set (server:host) server
      set (server:port) $port


      # enter event loop
      log $channel "Socket Ouvert"
      vwait forever

   }


  proc server {channel host port} {
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




  proc ::bdi_tools_synchro::I_receive_var { channel var } {
     
      set err [catch { set line [::bdi_tools_synchro::getline $channel] } msg ]
      if {$err} {
         log $channel "<error> $msg"
         return -code 1
      }
      return $line
  }

  proc I_receive_var2 { channel var p_val } {
     
      upvar $p_val val

      set rc [catch { set count [gets $channel line] } msg]
      if {$rc == 0 && $count == [ string length $var] && $line==$var} {
         set rc [catch { set count [gets $channel line] } msg]
         if {$rc == 0 && $count >0 } {
            puts "Fin normale de traitement $var"
            return $line
         } else {
            puts "Fin anormale de lecture de $var : 1"
            return -code 1
         }
      } else {
         puts "Fin anormale de lecture de $var : 2"
         return -code 2
      }
     
  }

  proc I_send_var { channel var val } {
  
      puts $channel $var
      puts $channel $val
      flush $channel
      puts "[clock seconds] $var => $val"

  }
  
  proc I_receive_file { channel p_tmpfile filesize } {
  
      upvar $p_tmpfile tmpfile

      gren_info "demarrage du telechargement\n"
      set tmpfile [file join $bddconf(dirtmp) "tmp.[pid].fits.gz"]
      set fd [open $tmpfile w]
      fconfigure $fd -translation binary
      fconfigure $channel -translation binary  -blocking 0
      fcopy $channel $fd -size $filesize
      close $fd
      gren_info "fin du telechargement\n"
  }
  
  proc I_send_file { channel filename filesize } {
  
      puts $channel "file"
      set fd [open $filename]
      fconfigure $fd  -translation binary
      fconfigure $channel  -translation binary
      fcopy $fd $channel -size $filesize
      close $fd
      flush $channel

  }






   proc input_server { channel } {
 
      global message
      global bddconf

      if {[eof $channel]} {
        # client closed -> log & close
        log $channel <closeda>
        catch { ::bdi_tools_synchro::close_socket $channel}
      } else {

         set err [catch { set var [getline $channel] } msg ]
         if {$err} {
            log $channel "<error> $msg"
            return
         }

         if {$var != "file"} { 
            set err [catch { set val [getline $channel] } msg ]
            if {$err} {
               log $channel "<error> $msg"
               return
            }
         }
         
         switch $var {
            "SYNC_BDI" {
               array unset message
               set ::bdi_tools_synchro::tt0 [clock clicks -milliseconds]
               gren_info "-----------------------------------\n"
            }
            "filename" {

               set message(filename) [I_receive_var channel $var]
               log $channel "File : $message(filename) Download..." ""
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
            "file" {
               set message(tmpfile) [file join $bddconf(dirtmp) "tmp.[pid].fits.gz"]
               set fd [open $message(tmpfile) w]
               fconfigure $fd -translation binary
               fconfigure $channel -translation binary  -blocking 0
               fcopy $channel $fd -size $message(filesize)
               close $fd
            }
            "work" {
               update
               after 1000
               addlog " Insert..." ""
               update
               after 1000
               gren_info "File      : $message(filename) \n"
               gren_info "MD5       : $message(md5) \n"
               gren_info "size      : $message(filesize) \n"
               gren_info "tmpfile   : [file tail $message(tmpfile)] \n"
               gren_info "modifdate : $message(modifdate) \n"
               
               # test filesize 
               
               # test MD5
               
               # copie du fichier tmp vers son nom de fichier
               
               # copie reussie ?
               
               # insertion dans la base
               
               # insertion dans la base reussi ?
               
               # modification du champ date
               
               # modification du champ date reussi ?
               puts $channel "end"
               puts $channel "end"
               flush $channel

               set tt [format "%.3f" [expr ([clock clicks -milliseconds] - $::bdi_tools_synchro::tt0)/1000.]]
               
               addlog " Finish in $tt sec"

            }
         }
      }
   }

  # log

  proc log { channel msg {cend ""} } {
  #      $::bdi_tools_synchro::rapport insert end "($::bdi_tools_synchro::host)::($::bdi_tools_synchro::port): $msg\n"
  #     puts "($::bdi_tools_synchro::host)::($::bdi_tools_synchro::port): $msg" 
  #    set entete "[mc_date2iso8601 now]\[$channel\]:"
      set entete "\n[mc_date2iso8601 now]:"
      $::bdi_tools_synchro::rapport insert end "$entete ${msg}${cend}"
#      puts "$entete $msg [fconfigure $channel -sockname]" 

  }
  proc addlog { msg {cend ""} } {
      $::bdi_tools_synchro::rapport insert end "${msg}${cend}"
  }
  proc close_socket { { channel ""} } {
  
     if {$channel == ""} {set channel $::bdi_tools_synchro::channel}
     log $channel "Socket Close "
     set err [catch { close $channel } msg ]
     if {$err} {
        #puts "Fermeture Socket : $err $msg\n"
     }
     
  }

  proc reopen_socket { } {
     ::bddimages::ressource
     gren_erreur "reopen_socket...\n"
     close_socket
     $::bdi_tools_synchro::rapport delete 0.0 end
     
     ::bdi_tools_synchro::launch_socket
     
  }
  
  # ===================
  # start
  # ===================

  # open socket

}

# Dump de la base ...
  #set res [exec mysqldump --user=$user --password=$pwd $database $table]
  #set fout [open dump.sql w]
  #puts $fout $res
  #close $fout
