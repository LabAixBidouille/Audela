#--------------------------------------------------
# source bdi_tools_synchro.tcl
#--------------------------------------------------
#
# Fichier        : bdi_tools_synchro.tcl
# Description    : Environnement de synchronisation des bases
# Auteur         : Frederic Vachier
# Mise Ã  jour $Id: bdi_tools_synchro.tcl 6858 2011-03-06 14:19:15Z fredvachier $
#
namespace eval bdi_tools_synchro {

      package require md5 

      variable port 80

}






   # recupere une ligne sur le channel
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




   # vide le channel de son contenu
   # ::bdi_tools_synchro::free_channel $::bdi_tools_synchro::channel
   proc ::bdi_tools_synchro::free_channel { channel } {

      flush $channel
      set cpt 0
      while {[gets $channel]!=""} {
         incr cpt
         if {$cpt > 100} {break}
      }
      flush $channel
 
   }





   # Reception d une variable
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
     
   }




   # Envoi d une variable
   proc ::bdi_tools_synchro::I_send_var { channel var val} {
  
      puts $channel $var
      puts $channel $val
      flush $channel
      #puts "S: $var = $val"

   }



  
   # Recpetion d un fichier
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



  
   # Envoi d un fichier
   proc ::bdi_tools_synchro::I_send_file { channel filename filesize { file "" } } {

      #set flog [open "/tmp/synchro.send.log" a]
      #puts $flog "I_send_file"

      if {$file == "file"} { 
         #puts $flog "send : var = file to server"
         #gren_info "** send file to server\n"
         #puts "** send file to server"
         puts $channel "file" 
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



   # nouvelle ligne de log a la GUI
   proc ::bdi_tools_synchro::log { channel msg {cend ""} } {
      set entete "[mc_date2iso8601 now]:"
      $::bdi_tools_synchro::rapport insert end "$entete ${msg}${cend}"
   }




   # ajoute une ligne de log a la GUI
   proc ::bdi_tools_synchro::addlog { msg {cend ""} {cbeg "\n"}} {
       if {$cbeg == ""} {
          set entete ""
       } else {
          set entete "${cbeg}[mc_date2iso8601 now]:"
       }

       $::bdi_tools_synchro::rapport insert end "$entete ${msg}${cend}"
       $::bdi_tools_synchro::rapport see end
   }




   # construction de la liste des donnees du server sql local avant traitement
   # seulement pour les fits
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
   }





   # construction de la liste des donnees du server sql local avant traitement
   # Fits & Cata
   proc ::bdi_tools_synchro::get_table_fitscata { p_data } {
      
      upvar $p_data data

      global bddconf
      global caption
      
      set passfits 0
      set passcata 0
      
      # check existance table images
      set sqlcmd "show tables like \"images\";"
      set err [catch {set data [::bddimages_sql::sql query $sqlcmd]} msg]
      if {$err} {
         gren_erreur "$msg\n"
         return
      }
      if {$data!="images"} {
         gren_erreur "images not exist\n"
      } else {
         set passfits 1
      }
      
      # check existance table catas
      set sqlcmd "show tables like \"catas\";"
      set err [catch {set data [::bddimages_sql::sql query $sqlcmd]} msg]
      if {$err} {
         gren_erreur "$msg\n"
         return
      }
      if {$data!="catas"} {
         gren_info "catas not exist\n"
      } else {
         incr passcata
      }

      # check existance table cataimage
      set sqlcmd "show tables like \"cataimage\";"
      set err [catch {set data [::bddimages_sql::sql query $sqlcmd]} msg]
      if {$err} {
         gren_erreur "$msg\n"
         return
      }
      if {$data!="cataimage"} {
         gren_info "cataimage not exist\n"
      } else {
         incr passcata
      }

      if {$passfits==0||$passcata==1} {
         return
      }

      if {$passcata==0} {
         gren_info "No CATA\n"
         # On recupere tous les fichiers fits car il n y a pas de tables cata ou cataimages
         set sqlcmd "SELECT images.dirfilename,images.filename,images.sizefich,images.datemodif,"
         set err [catch {set data [::bddimages_sql::sql query $sqlcmd]} msg]
         if {$err} {
            tk_messageBox -message "$caption(bdi_status,consoleErr2) $msg" -type ok
            return
         }
      }

      if {$passcata==2} {
      
         # On commence par recuperer tous les fichiers dont un cata est associé
         set sqlcmd "SELECT images.dirfilename,images.filename,images.sizefich,images.datemodif,
                            catas.dirfilename,catas.filename,catas.sizefich,catas.datemodif
                     FROM images, cataimage, catas 
                     WHERE cataimage.idbddcata=catas.idbddcata
                     AND  cataimage.idbddimg=images.idbddimg;"
         set err [catch {set data [::bddimages_sql::sql query $sqlcmd]} msg]
         if {$err} {
            tk_messageBox -message "$caption(bdi_status,consoleErr2) $msg" -type ok
            return
         }

         # On continu par recuperer tous les fichiers dont un cata n existe pas
         set sqlcmd "SELECT images.dirfilename,images.filename,images.sizefich,images.datemodif
                     FROM images WHERE NOT EXISTS (SELECT * FROM cataimage 
                     WHERE cataimage.idbddimg=images.idbddimg);" 
         set err [catch {set data [concat $data [::bddimages_sql::sql query $sqlcmd]]} msg]
         if {$err} {
            tk_messageBox -message "$caption(bdi_status,consoleErr2) $msg" -type ok
            return
         }

      }

      # correction d erreur de filesize
      #foreach line $data {
      #   set dirfilename [lindex $line 0]
      #   set filename    [lindex $line 1]
      #   set size_sql    [lindex $line 2]
      #   set file [file join $bddconf(dirbase) $dirfilename $filename]
      #   set size_disk [file size $file]
      #   if {$size_disk != $size_sql} {
      #      set sqlcmd "UPDATE images SET sizefich=$size_disk WHERE dirfilename='$dirfilename' AND filename='$filename';"
      #      set err [catch {set data [::bddimages_sql::sql query $sqlcmd]} msg]
      #      if {$err} {
      #      }
      #   }
      #}

      #set filename [file join $bddconf(dirtmp) "table_fitscata.txt"]
      #set h [open $filename "w"]
      #foreach line $data {
      #   
      #   puts $h $line
      #}
      #close $h
      
      return 
   }






   # Get MD5sum for a file
   proc ::bdi_tools_synchro::get_md5 { file } {
   
      set methode 1
      
      if {![file exists $file]} {
         return -code 1 "file not exist : $file"
      }

      if {$methode == 0} { 
         set md5 [::md5::md5 -hex -file $file]
      } else {
         set cmd "/usr/bin/md5sum $file"
         set err [catch { eval exec $cmd } msg ]
         if {$err} {
           return -code -1 $msg
         }
         set md5 [split $msg " "]
         set md5 [lindex $md5 0]
         set md5 [string toupper $md5]
      }
      return $md5
   }

