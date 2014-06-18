# Fichier        : bdi_tools_synchro.server.tcl
# Description    : fonctions destinees au server
# Auteur         : Frederic Vachier
# Mise Ã  jour $Id: bdi_tools_synchro.server.tcl 6858 2011-03-06 14:19:15Z fredvachier $


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




   proc ::bdi_tools_synchro::input_server { channel } {
 

      global message
      global bddconf


      if {[eof $channel]} {
        # client closed -> log & close
        log $channel <closeda>
        catch { ::bdi_tools_synchro::close_socket $channel}
      } else {


         set err [catch { set var [::bdi_tools_synchro::getline $channel] } msg ]
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
            set err [catch { set val [::bdi_tools_synchro::getline $channel] } msg ]
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
               #puts "R : $val"
               ::bdi_tools_synchro::I_send_var $channel status "PENDING"
            }
            "filetype" {
               set message(filetype) $val
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


               # TEST existance des variables
               if {![info exists message(synchro)] } {
                     set txt "Unknown synchro"
                     addlog $txt ; ::bdi_tools_synchro::I_send_var $channel status $txt
                     flush $channel ; return
               }
               if {![info exists message(filename)] } {
                     set txt "Unknown filename"
                     addlog $txt ; ::bdi_tools_synchro::I_send_var $channel status $txt
                     flush $channel ; return
               }
               if {![info exists message(filetype)] } {
                     set txt "Unknown filetype"
                     addlog $txt ; ::bdi_tools_synchro::I_send_var $channel status $txt
                     flush $channel ; return
               }






               if {$message(synchro)=="S->C"} {
                  #gren_info "work      : $val \n"

                  #gren_info "File      : $message(filename) \n"
                  set dirfilename [file dirname $message(filename)]
                  set filename [file tail $message(filename)]


                  switch $message(filetype) {

                     "FITS" {
                        set sqlcmd "SELECT sizefich,datemodif FROM images WHERE filename='$filename' AND dirfilename='$dirfilename';"
                     }
                     "CATA" {
                        set sqlcmd "SELECT sizefich,datemodif FROM catas WHERE filename='$filename' AND dirfilename='$dirfilename';"
                     }
                     default {
                        set txt "Unknown filetype : $filetype"
                        addlog $txt
                        ::bdi_tools_synchro::I_send_var $channel status $txt
                        flush $channel
                        return
                     }               
                  }
                     
                  set err [catch {set data [::bddimages_sql::sql query $sqlcmd]} msg]
                  if {$err} {
                     set txt "Erreur : find sizefich & datemodif - err = $err\nsql = $sqlcmd\nmsg = $msg"
                     addlog $txt
                     ::bdi_tools_synchro::I_send_var $channel status $txt
                     flush $channel
                     return
                  }
                  set data [lindex $data 0]
                  set filesize_sql [lindex $data 0]
                  set modifdate    [lindex $data 1]
                  
                  #puts "filesize_sql = $filesize_sql\n"
                  #puts "modifdate = $modifdate\n"
                  
                  #puts "dirbase = $bddconf(dirbase)\n"
                  #puts "filename = $message(filename)\n"
                  
                  set file [file join $bddconf(dirbase) $message(filename)]
                  
                  if {![file exists $file]} {
                     set txt "Erreur : file not exist : $file"
                     addlog $txt
                     ::bdi_tools_synchro::I_send_var $channel status $txt
                     flush $channel
                     return
                  }
                  
                  set filesize_disk [file size $file]
                  
                  if {$filesize_disk!=$filesize_sql} {
                     set txt "Bad file size on serveur $filesize_disk!=$filesize_sql"
                     addlog $txt
                     ::bdi_tools_synchro::I_send_var $channel status $txt
                     flush $channel
                     return
                  }

                  set md5 [::bdi_tools_synchro::get_md5 $file]
                  set filesize $filesize_sql

                  ::bdi_tools_synchro::I_send_var $channel status "FILEOK"
                  
                  ::bdi_tools_synchro::I_send_var  $channel md5       $md5
                  
                  #puts "filesize = $filesize"
                  ::bdi_tools_synchro::I_send_var  $channel filesize  $filesize
                  ::bdi_tools_synchro::I_send_var  $channel modifdate $modifdate
                  ::bdi_tools_synchro::I_send_file $channel $file     $filesize
               }
               



               if {$message(synchro)=="C->S"} {


                  # TEST existance des variables
                  if {![info exists message(filesize)] } {
                        set txt "Unknown filesize"
                        addlog $txt ; ::bdi_tools_synchro::I_send_var $channel status $txt
                        flush $channel ; return
                  }
                  if {![info exists message(modifdate)] } {
                        set txt "Unknown modifdate"
                        addlog $txt ; ::bdi_tools_synchro::I_send_var $channel status $txt
                        flush $channel ; return
                  }
                  if {![info exists message(exist)] } {
                        set txt "Unknown exist"
                        addlog $txt ; ::bdi_tools_synchro::I_send_var $channel status $txt
                        flush $channel ; return
                  }
                  if {![info exists message(md5)] } {
                        set txt "Unknown md5"
                        addlog $txt ; ::bdi_tools_synchro::I_send_var $channel status $txt
                        flush $channel ; return
                  }
                  if {![info exists message(tmpfile)] } {
                        set txt "Unknown tmpfile"
                        addlog $txt ; ::bdi_tools_synchro::I_send_var $channel status $txt
                        flush $channel ; return
                  }



                  #gren_info "work      : $val \n"
                  #gren_info "File      : $message(filename)  \n"
                  #gren_info "Filesize  : $message(filesize)  \n"
                  #gren_info "Modifdate : $message(modifdate) \n"
                  #gren_info "Exist     : $message(exist)     \n"
                  #gren_info "MD5       : $message(md5)       \n"
                  #gren_info "tmpfile   : $message(tmpfile)   \n"

                  set md5_r [::bdi_tools_synchro::get_md5 $message(tmpfile)]
                  if {$message(md5) != $md5_r} {
                     set txt "Erreur : Bad MD5"
                     addlog $txt
                     ::bdi_tools_synchro::I_send_var $channel status $txt
                     flush $channel
                     return
                  }

                  set newfile [file join $bddconf(dirtmp) [file tail $message(filename)] ]
                  set err [catch {file rename -force $message(tmpfile) $newfile} msg]
                  if {$err} {
                     set txt "Erreur : rename file : $msg"
                     addlog $txt
                     ::bdi_tools_synchro::I_send_var $channel status $txt
                     flush $channel
                     return
                  }

                  set df [file dirname $message(filename)]
                  set fn [file tail $message(filename)]

                  switch $message(filetype) {

                     "FITS" {

                        # recuperation de idbddimg
                        set sqlcmd "SELECT idbddimg FROM images WHERE filename='$fn' AND dirfilename='$df';"
                        set err [catch {set data [::bddimages_sql::sql query $sqlcmd]} msg]
                        if {$err} {
                           set txt "Erreur : find idbddimg - err = $err\nsql = $sqlcmd\nmsg = $msg"
                           addlog $txt
                           ::bdi_tools_synchro::I_send_var $channel status $txt
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
                           set txt "Erreur : le fichier existe et ne devrait pas."
                           addlog $txt
                           ::bdi_tools_synchro::I_send_var $channel status $txt
                           flush $channel
                           return
                        }

                        if {$message(exist) && !$exist} { 
                           set txt "Erreur : le fichier n'existe pas alors qu'il devrait."
                           addlog $txt
                           ::bdi_tools_synchro::I_send_var $channel status $txt
                           flush $channel
                           return
                        }

                        if {$message(exist) && $exist} {
                           bddimages_image_delete $idbddimg
                        }

                        set err [catch {set idbddimg [insertion_solo $newfile]} msg]
                        if {$err} {
                           set txt "Erreur : insertion file : $msg"
                           addlog $txt
                           ::bdi_tools_synchro::I_send_var $channel status $txt
                           flush $channel
                           return
                        }
                        # modif la datemodif de $idbddimg
                        set sqlcmd "UPDATE images SET datemodif='$message(modifdate)' WHERE idbddimg=$idbddimg;"
                        set err [catch {set data [::bddimages_sql::sql query $sqlcmd]} msg]
                        if {$err} {
                           set txt  "Erreur : UPDATE IMAGES - err = $err\nsql = $sqlcmd\nmsg = $msg"
                           addlog $txt
                           ::bdi_tools_synchro::I_send_var $channel status $txt
                           flush $channel
                           return
                        }

                     }
                     "CATA" {

                        set err [catch {set idbddcata [insertion_solo $newfile]} msg]
                        if {$err} {
                           set txt "Erreur : insertion file : $msg"
                           addlog $txt
                           ::bdi_tools_synchro::I_send_var $channel status $txt
                           flush $channel
                           return
                        }
                        # modif la datemodif de $idbddimg
                        set sqlcmd "UPDATE catas SET datemodif='$message(modifdate)' WHERE idbddcata=$idbddcata;"
                        set err [catch {set data [::bddimages_sql::sql query $sqlcmd]} msg]
                        if {$err} {
                           set txt  "Erreur : UPDATE CATAS - err = $err\nsql = $sqlcmd\nmsg = $msg"
                           addlog $txt
                           ::bdi_tools_synchro::I_send_var $channel status $txt
                           flush $channel
                           return
                        }

                     }
                     default {
                        set txt "Unknown filetype : $filetype"
                        addlog $txt
                        ::bdi_tools_synchro::I_send_var $channel status $txt
                        flush $channel
                        return
                     }               
                  }


                  ::bdi_tools_synchro::I_send_var $channel status SUCCESS

               }
               
               flush $channel

               set tt [format "%.3f" [expr ([clock clicks -milliseconds] - $::bdi_tools_synchro::tt0)/1000.]]
               
               addlog "Finish in $tt sec" "" ""

            }
         }
      }
   }




   # Construction du fichier de donnee pour etre rapatrié sur le client
   proc ::bdi_tools_synchro::build_file_table_images { } {

      global bddconf

      ::bdi_tools_synchro::get_table_fitscata data
      
      set nb [llength $data]

      set filename [file join $bddconf(dirtmp) "table_images.dat"]
      set h [open $filename "w"]
      set data "set data { $data }"
      puts $h $data
      close $h
      ::bdi_tools::gzip $filename
      set filename "$filename.gz"
      set md5      [::bdi_tools_synchro::get_md5 $filename]
      set filesize [file size $filename]
      
      return [list $md5 $filename $filesize]
   }






