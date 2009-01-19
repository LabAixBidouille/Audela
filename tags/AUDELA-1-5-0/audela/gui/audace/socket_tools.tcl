#
# Fichier : socket_tools.tcl
# Description : This tool box allow to connect ASCII sockets where messages termination is \n
# Mise a jour $Id: socket_tools.tcl,v 1.2 2007-04-01 21:23:13 robertdelmas Exp $
#

# ==========================================================================================
# socket_server_open : to open a named socket server that calls a proc_accept
# e.g. source audace/socket_tools.tcl ; socket_server_open server1 60000 socket_server_accept
proc socket_server_open { name port {proc_accept socket_server_accept} } {
   global audace
   if {[info exists audace(socket,server,$name)]==1} {
      error "server $name already opened"
   }
   set errno [catch {
      set audace(socket,server,$name) [socket -server $proc_accept $port]
   } msg]
   if {$errno==1} {
      error $msg
   }
}
# ==========================================================================================

# ==========================================================================================
# socket_server_accept : this is the default proc_accept of a socket server
# Please use this proc as a canvas to write those dedicaded to your job.
proc socket_server_accept {fid ip port} {
   global audace
   fconfigure $fid -buffering line
   fileevent $fid readable [list socket_server_respons $fid]
}
# ==========================================================================================

# ==========================================================================================
# socket_server_respons : this is the default proc_accept of a socket server
# Please use this proc as a canvas to write those dedicaded to your job.
proc socket_server_respons {fid} {
   global audace
   set errsoc [ catch {
      if {[eof $fid] || [catch {gets $fid line}]} {
         close $fid
      } else {
         ::console::affiche_resultat "$fid received \"$line\" and returned it to the client\n"
         puts $fid "$line"
      }
   } msgsoc]
   if {$errsoc==1} {
      ::console::affiche_resultat "socket error : $msgsoc\n"
   }
}
# ==========================================================================================

# ==========================================================================================
# socket_server_respons : this is the default proc_accept of a socket server
# Please use this proc as a canvas to write those dedicaded to your job.
proc socket_server_respons_debug {fid} {
   global audace
   set stepsoc 0
   set errsoc [ catch {
      if {[info exists audace(socket,server,connected)]==0} {
         set audace(socket,server,connected) 1
      } else {
         incr audace(socket,server,connected)
      }
      set stepsoc 1
      if {[eof $fid] || [catch {gets $fid line}]} {
         ::console::affiche_resultat "close the connexion : connected=$audace(socket,server,connected)\n"
         incr audace(socket,server,connected) -1
         set stepsoc 2
         close $fid
      } else {
         if {$audace(socket,server,connected)>20} {
            ::console::affiche_resultat " connected=$audace(socket,server,connected) DEPASSE\n"
            #incr audace(socket,server,connected) -1
            ::console::affiche_resultat "connected=$audace(socket,server,connected)\n"
            #set stepsoc 3
            #return
         }
         ::console::affiche_resultat "($audace(socket,server,connected)) $fid received \"$line\" and returned it to the client\n"
         set stepsoc 4
         set errno [catch { puts $fid "$line" } msg ]
         if {$errno==1} {
            ::console::affiche_resultat "socket put error : $msg\n"
         }
      }
      ::console::affiche_resultat "connected=$audace(socket,server,connected)\n"
      incr audace(socket,server,connected) -1
   } msgsoc]
   if {$errsoc==1} {
      ::console::affiche_resultat "socket error $stepsoc : $msgsoc\n"
   }
}
# ==========================================================================================

# ==========================================================================================
# socket_server_close : to close a named socket server
proc socket_server_close { name } {
   global audace
   set errno [catch {
      close $audace(socket,server,$name)
   } msg]
   if {$errno==0} {
      unset audace(socket,server,$name)
      catch {unset audace(socket,server,connected)}
   } else {
      error $msg
   }
}
# ==========================================================================================

# ==========================================================================================
# socket_client_open : to open a named socket client
# e.g. socket_client_open client1 127.0.0.1 60000
#      socket_client_put client1 "Blabla" ; set res [socket_client_get client1]
#      socket_client_close client1
proc socket_client_open { name host port } {
   global audace
   if {[info exists audace(socket,client,$name)]==1} {
      error "client $name already opened"
   }
   set errno [catch {
      set audace(socket,client,$name) [socket $host $port]
      fconfigure $audace(socket,client,$name) -buffering line -blocking 0
   } msg]
   if {$errno==1} {
      error $msg
   }
}
# ==========================================================================================

# ==========================================================================================
# socket_client_put : send msg from the named socket client
proc socket_client_put { name msg } {
   global audace
   if {[info exists audace(socket,client,$name)]==0} {
      error "client $name does not exists"
   }
   set errno [catch {
      puts $audace(socket,client,$name) "$msg"
      flush $audace(socket,client,$name)
   } msg]
   if {$errno==1} {
      error $msg
   }
}
# ==========================================================================================

# ==========================================================================================
# socket_client_get : receive msg from the server linked with the named socket client
proc socket_client_get { name } {
   global audace
   if {[info exists audace(socket,client,$name)]==0} {
      error "client $name does not exists"
   }
   set errno [catch {
      gets $audace(socket,client,$name)
   } msg]
   if {$errno==1} {
      error $msg
   } else {
      return $msg
   }
}
# ==========================================================================================

# ==========================================================================================
# socket_client_close : to close a named socket client
proc socket_client_close { name } {
   global audace
   set errno [catch {
      close $audace(socket,client,$name)
   } msg]
   if {$errno==0} {
      unset audace(socket,client,$name)
   } else {
      error $msg
   }
}
# ==========================================================================================

