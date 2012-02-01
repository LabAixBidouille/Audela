#
# Fichier : gcn_tools.tcl
# Description : These scripts allow to read informations from GRB Coordinate Network (GCN)
#               For more details, see http://gcn.gsfc.nasa.gov
#               The entry point is socket_server_open_gcn but you must contact GCN admin
#               to obtain a port number for a GCN connection.
#
# Connected sites are found in http://gcn.gsfc.nasa.gov/sites_cfg.html
# To create a new connected site http://gcn.gsfc.nasa.gov/gcn/config_builder.html
#
# Mise à jour $Id$
#
# source "$audace(rep_install)/gui/audace/gcn_tools.tcl"
#
# ==========================================================================================

# ==========================================================================================
# socket_client_send_gcn : to send a GCN-like packet to a server with a GCN connection
# e.g. source audace/gcn_tools.tcl ; socket_client_send_gcn client_gcn 127.0.0.1 7001 {3 2008 07 07 23 45 21.123 123.4567 -46.4321 1.5 2 600}
proc socket_client_send_gcn { name ipserver portserver {data {3 2008 07 07 23 45 21.123 123.4567 -46.4321 1.5 2 600}} } {
   global audace
   global gcn

   # --- init longs
   set longs ""
   for {set k 0 } {$k<40} {incr k} {
      lappend longs 0
   }
   # --- data
   if {1==0} {
      set data ""
      lappend data 901 ; # packet type = 901
      set date [mc_date2ymdhms now]
      for {set k 0} {$k<6} {incr k} {
         lappend $data [lindex $date $k] ; # date YMDHMS
      }
      lappend data 123.4567 ; # ra J2000.0 (deg)
      lappend data -46.4321 ; # dec J2000.0 (deg)
      lappend data 1.5 ; # boite d'erreur (arcmin)
      lappend data 2 ; # nombre de neutrinos 1=unique mais intense
      lappend data 600. ; # duree d'integration (seconds)
   }
   if {$data=="*"} {
      set now [mc_date2ymdhms now]
      set y  [lindex $now 0]
      set m  [lindex $now 1]
      set d  [lindex $now 2]
      set hh [lindex $now 3]
      set mm [lindex $now 4]
      set ss [lindex $now 5]
      set lst [mc_date2lst now {GPS 115 E -31 50}]
      set ra [mc_angle2deg [lindex $lst 0]h[lindex $lst 1]m[lindex $lst 2]s] ; # meridien
      set dec 5
      set data [list 61 $y $m $d $hh $mm $ss $ra $dec 3. 1 600]
   }
   # --- decodage data -> longs
   #
   #TYPE=901 PACKET CONTENTS:
   #
   #The ANTARES_GRB_POSITION packet consists of 40 four-byte quantities.
   #The order and contents are listed in the table below:
   #
   #Declaration  Index   Item         Units           Comments
   #Type                 Name
   #-----------  -----   ---------    ----------      ----------------
   #long         0       pkt_type     integer         Packet type number (=61)
   #long         1       pkt_sernum   integer         1 thru infinity
   #long         2       pkt_hop_cnt  integer         Incremented by each node
   #long         3       pkt_sod      [centi-sec]     (int)(sssss.sss *100)
   #long         4       trig_obs_num integers        Trigger num & Observation num
   #long         5       burst_tjd    [days]          Truncated Julian Day
   #long         6       burst_sod    [centi-sec]     (int)(sssss.sss *100)
   #long         7       burst_ra     [0.0001-deg]    (int)(0.0 to 359.9999 *10000)
   #long         8       burst_dec    [0.0001-deg]    (int)(-90.0 to +90.0 *10000)
   #long         9       burst_flue   [counts]        Num events during trig window, 0 to inf
   #long         10      burst_ipeak  [cnts*ff]       Counts in image-plane peak, 0 to infinity
   #long         11      burst_error  [0.0001-deg]    (int)(0.0 to 180.0 *10000)
   #long         12      phi          [centi-deg]     (int)(0.0 to 359.9999 *100)
   #long         13      theta        [centi-deg]     (int)(0.0 to +70.0 *100)
   #long         14      integ_time   [4mSec]         Duration of the trigger interval, 1 to inf
   #long         15      spare        integer         4 bytes for the future
   #long         16      lon_lat      2_shorts        (int)(Longitude,Lattitude *100)
   #long         17      trig_index   integer         Rate_Trigger index
   #long         18      soln_status  bits            Type of source/trigger found
   #long         19      misc         bits            Misc stuff packed in here
   #long         20      image_signif [centi-sigma]   (int)(sig2noise *100)
   #long         21      rate_signif  [centi-sigma]   (int)(sig2noise *100)
   #long         22      bkg_flue     [counts]        Num events during the bkg interval, 0 to inf
   #long         23      bkg_start    [centi-sec]     (int)(sssss.sss *100)
   #long         24      bkg_dur      [centi-sec]     (int)(0-80,000 *100)
   #long         25      cat_num      integer         On-board cat match ID number
   #long         26-35   spare[10]    integer         40 bytes for the future
   #long         36      merit_0-3    integers        Merit params 0,1,2,3 (-127 to +127)
   #long         37      merit_4-7    integers        Merit params 4,5,6,7 (-127 to +127)
   #long         38      merit_8-9    integers        Merit params 8,9     (-127 to +127)
   #long         39      pkt_term     integer         Pkt Termination (always = \n)
   set burst_pkt_type [lindex $data 0]
   set longs [lreplace $longs 0 0 $burst_pkt_type]
   set burst_pkt_sernum 1
   set longs [lreplace $longs 1 1 $burst_pkt_sernum]
   set burst_pkt_hop_cnt 1
   set longs [lreplace $longs 2 2 $burst_pkt_hop_cnt]
   set date [mc_date2jd now]
   set sod [expr ($date-0.5-floor($date-0.5))*86400.] ; # -0.5
   set burst_pkt_sod [expr int($sod*100)]
   set longs [lreplace $longs 3 3 $burst_pkt_sod]
   set burst_trig_obs_num 1
   set longs [lreplace $longs 4 4 $burst_trig_obs_num]
   set burst_date_year [lindex $data 1]
   set burst_date_month [lindex $data 2]
   set burst_date_day [lindex $data 3]
   set burst_date_hour [lindex $data 4]
   set burst_date_minute [lindex $data 5]
   set burst_date_seconds [lindex $data 6]
   set jd [mc_date2jd [lrange $data 1 6]]
   set burst_tjd [expr int($jd+13370.+1.-[mc_date2jd {2005 1 1}])]
   set longs [lreplace $longs 5 5 $burst_tjd]
   set sod [expr ($jd-0.5-floor($jd-0.5))*86400.] ; # -0.5
   set burst_sod [expr int($sod*100)]
   set longs [lreplace $longs 6 6 $burst_sod]
   set burst_ra [expr int([lindex $data 7]/0.0001)]
   set longs [lreplace $longs 7 7 $burst_ra]
   set burst_dec [expr int([lindex $data 8]/0.0001)]
   set longs [lreplace $longs 8 8 $burst_dec]
   set burst_flue [lindex $data 10]
   set longs [lreplace $longs 9 9 $burst_flue]
   set burst_error [expr int([lindex $data 9]/60./0.0001)]
   set longs [lreplace $longs 11 11 $burst_error]
   set burst_integ_time [expr int([lindex $data 11]/4e-3)]
   set longs [lreplace $longs 14 14 $burst_integ_time]
   # --- convert longs into the binary stream
   #::console::affiche_resultat "longs=<$longs>\n"
   set line [binary format I* $longs]
   #::console::affiche_resultat "line=<$line>\n"
   # --- open socket connexion
   for {set k 0} {$k<2} {incr k} {
      if {[info exists audace(socket,client,$name)]==0} {
         #::console::affiche_resultat "$ipserver $portserver\n"
         set errno [ catch {
            set fid [socket $ipserver $portserver ]
            #::console::affiche_resultat "fid=$fid\n"
         } msg]
         if {$errno==1} {
            error $msg
         } else {
            set audace(socket,client,$name) $fid
         }
      }
      set fid $audace(socket,client,$name)
      #::console::affiche_resultat "fid=<$fid>\n"
      fconfigure $fid -buffering full -translation binary -encoding binary -buffersize 160
      # --- send packet
      set errsoc [ catch {
         puts -nonewline $fid $line
      } msgsoc ]
      if {$errsoc==1} {
         gcn_print "socket error : $msgsoc"
         catch {
            close $audace(socket,client,$name)
            unset audace(socket,client,$name)
         }
      } else {
         break
      }
   }
}

# ==========================================================================================
# socket_client_send_gcn_native : to send a GCN-like packet to a server with a GCN connection
# e.g. source audace/gcn_tools.tcl ; socket_client_send_gcn client_gcn 127.0.0.1 7001
proc socket_client_send_gcn_native { name ipserver portserver longs } {
   global audace
   global gcn

   # --- convert longs into the binary stream
   #::console::affiche_resultat "longs=<$longs>\n"
   set line [binary format I* $longs]
   #::console::affiche_resultat "line=<$line>\n"
   # --- open socket connexion
   for {set k 0} {$k<2} {incr k} {
      if {[info exists audace(socket,client,$name)]==0} {
         #::console::affiche_resultat "$ipserver $portserver\n"
         set errno [ catch {
            set fid [socket $ipserver $portserver ]
            #::console::affiche_resultat "fid=$fid\n"
         } msg]
         if {$errno==1} {
            error $msg
         } else {
            set audace(socket,client,$name) $fid
         }
      }
      set fid $audace(socket,client,$name)
      #::console::affiche_resultat "fid=<$fid>\n"
      fconfigure $fid -buffering full -translation binary -encoding binary -buffersize 160
      # --- send packet
      set errsoc [ catch {
         puts -nonewline $fid $line
      } msgsoc ]
      if {$errsoc==1} {
         gcn_print "socket error : $msgsoc"
         catch {
            close $audace(socket,client,$name)
            unset audace(socket,client,$name)
         }
      } else {
         break
      }
   }
}
# ==========================================================================================

proc socket_client_close_gcn { name } {
   global audace
   global gcn

   if {[info exists audace(socket,client,$name)]==1} {
      close $audace(socket,client,$name)
      unset audace(socket,client,$name)
   }
}

# ==========================================================================================
# socket_server_open_gcn : to open a named socket server for a GCN connection
# e.g. source audace/gcn_tools.tcl ; socket_server_open_gcn server1 5269 60000 "C:/Program Files/Apache Group/Apache2/htdocs/grb.txt"
#      source audace/socket_tools.tcl ; socket_client_open client1 localhost 60000 ; after 100 ; socket_client_put client1 z ; after 800 ; set res [socket_client_get client1] ; socket_client_close client1
#      source audace/socket_tools.tcl ; socket_server_open server1 60000
proc socket_server_open_gcn { name portgcn {portout 0} {index_html ""} {redir_hosts ""} {redir_ports 0} } {
   global audace
   global gcn

   set proc_accept socket_server_accept_gcn_${name}
   if {[info exists audace(socket,server,$name)]==1} {
      error "server $name already opened"
   }
   set errno [catch {
      set audace(socket,server,$name) [socket -server $proc_accept $portgcn]
   } msg]
   if {$errno==1} {
      error $msg
   }
   set sockname $name
   # ==========================================================================================
   # socket_server_accept_gcn : this is called by  the GCN socket server
   set ligne "proc ::socket_server_accept_gcn_${name} {fid ip port} { global audace ; fconfigure \$fid -buffering full -translation binary -encoding binary -buffersize 160 ; fileevent \$fid readable \[list socket_server_respons_gcn \$fid \"$name\" $redir_hosts $redir_ports\] ; }"
   gcn_print "ligne=$ligne"
   eval $ligne
   # ==========================================================================================
   if {$portout!=0} {
      set name x$name
      set proc_accept socket_server_accept_out_${name}
      if {[info exists audace(socket,server,$name)]==1} {
         error "server $name already opened"
      }
      set errno [catch {
         set audace(socket,server,$name) [socket -server $proc_accept $portout]
      } msg]
      if {$errno==1} {
         error $msg
      }
      # ==========================================================================================
      # socket_server_accept_out : this is called by a client who want to get informations
      set ligne "proc ::socket_server_accept_out_${name} {fid ip port} { global audace ; fconfigure \$fid -buffering full -translation binary -encoding binary -buffersize 160 ; fileevent \$fid readable \[list socket_server_respons_out \$fid $name\] ; }"
      eval $ligne
      # ==========================================================================================
   }
   set gcn($sockname,index_html) $index_html
   #::console::affiche_resultat "gcn($sockname,index_html)=$gcn($sockname,index_html)\n"
   if {$index_html!=""} {
      set errno [catch {
         set f [open $index_html r]
         set lignes [split [read $f] \n]
         close $f
         set n [llength $lignes]
         for {set k 1} {$k<[expr $n-1]} {incr k} {
            set ligne [lindex $lignes $k]
            set texte "set gcn($sockname,status,[lindex $ligne 0],[lindex $ligne 1],[lindex $ligne 2]) [lindex $ligne 3]"
            eval $texte
         }
      } msg]
      if {$errno==1} {
         gcn_print "Error: $msg"
      }
   }
   return ""
}
# ==========================================================================================

# ==========================================================================================
# socket_server_accept_gcn : this is called by  the GCN socket server
#proc socket_server_accept_gcn {fid ip port} {
#   global audace
#   fconfigure $fid -buffering full -translation binary -encoding binary -buffersize 160
#   fileevent $fid readable [list socket_server_respons_gcn $fid ""]
#}
# ==========================================================================================

# ==========================================================================================
# socket_server_respons_gcn : decode the GCN stream
proc socket_server_respons_gcn {fid {sockname dummy} {redir_hosts ""} {redir_ports 0} } {
   global gcn audace

   set gcn(gcn_${sockname},redir_msg) ""
   set errsoc [ catch {
      set line [read $fid 160]
      if {[eof $fid]} {
         close $fid
      } elseif {![fblocked $fid]} {
         # --- redir if needed
         set kredir 0
         set gcn(gcn_${sockname},redir_msg) ""
         foreach redir_host $redir_hosts {
            set ipserver [lindex $redir_hosts $kredir]
            set portserver [lindex $redir_ports $kredir]
            #gcn_print "ETAPE 1 ipserver=$ipserver portserver=$portserver"
            #catch {gren_info "ETAPE 1 ipserver=$ipserver portserver=$portserver"}
            incr kredir
            set name redir${kredir}_${sockname}
            # --- open socket connexion
            catch {
               # --- open socket connexion
               for {set k 0} {$k<2} {incr k} {
                  if {[info exists audace(socket,client,$name)]==0} {
                     #::console::affiche_resultat "$ipserver $portserver\n"
                     set errno [ catch {
                        set fid [socket $ipserver $portserver ]
                        #::console::affiche_resultat "fid=$fid\n"
                     } msg]
                     if {$errno==1} {
                        error $msg
                     } else {
                        set audace(socket,client,$name) $fid
                     }
                  }
                  set fid $audace(socket,client,$name)
                  #::console::affiche_resultat "fid=<$fid>\n"
                  fconfigure $fid -buffering full -translation binary -encoding binary -buffersize 160
                  # --- send packet
                  set errsoc [ catch {
                     puts -nonewline $fid $line
                     flush $fid
                  } msgsoc ]
                  #catch {gren_info "ETAPE 2 errsoc=$errsoc msgsoc=$msgsoc line=<$line>"}
                  if {$errsoc==1} {
                     #gcn_print "socket error : $msgsoc"
                     catch {
                        close $audace(socket,client,$name)
                     }
                     catch {
                        unset audace(socket,client,$name)
                     }
                  } else {
                     set texte "REDIR OK for ipserver=$ipserver portserver=$portserver"
                     append gcn(gcn_${sockname},redir_msg) "$texte. "
                     #catch {gren_info "ETAPE 3 gcn(gcn_${sockname},redir_msg)=$gcn(gcn_${sockname},redir_msg)"}
                     gcn_print "$texte"
                     break
                  }
               }
            }
         }
         #::console::affiche_resultat "$fid received \"$line\"\n"
         # --- convert the binary stream into longs
         binary scan $line I* longs
         gcn_decode $longs $sockname
      }
   } msgsoc ]
   if {$errsoc==1} {
      gcn_print "socket error : $msgsoc"
   }
}
# ==========================================================================================

# ==========================================================================================
# socket_server_close_gcn : to close a named socket server
proc socket_server_close_gcn { name } {
   global audace

   set errno [catch {
      catch {close $audace(socket,server,$name)}
      catch {close $audace(socket,server,x$name)}
   } msg]
   if {$errno==0} {
      catch {unset audace(socket,server,$name)}
      catch {unset audace(socket,server,x$name)}
      catch {unset audace(socket,server,connected)}
   } else {
      error $msg
   }
}
# ==========================================================================================

# ==========================================================================================
# socket_server_accept : this is the default proc_accept of a socket server
# Please use this proc as a canvas to write those dedicaded to your job.
#proc socket_server_accept_out {fid ip port} {
#   global audace
#   fconfigure $fid -buffering line
#   fileevent $fid readable [list socket_server_respons_out $fid]
#}
# ==========================================================================================

# ==========================================================================================
# socket_server_respons : this is the default proc_accept of a socket server
# Please use this proc as a canvas to write those dedicaded to your job.
proc socket_server_respons_out {fid {$sockname dummy} } {
   global audace
   global gcn

   set errsoc [ catch {
      set line [read $fid 160]
      if {[eof $fid]} {
         close $fid
      } elseif {![fblocked $fid]} {
         set lignes ""
         if {[info commands ::audace::date_sys2ut]=="::audace::date_sys2ut"} {
            set date [mc_date2iso8601 [::audace::date_sys2ut now]]
         } else {
            set date [mc_date2iso8601 now]
         }
         gcn_print " Ask from $fid at $date ($line)"
         append lignes "{ $date }"
         set names [lsort [array names gcn]]
         foreach name $names {
            set res [regsub -all , $name " "]
            if {([lindex $res 0]=="$sockname")&&([lindex $res 1]=="status")} {
               set res [lrange $res 2 end]
               append lignes "\{ $res $gcn($name) \} "
            }
         }
         gcn_print " Answer to $fid: $lignes"
         puts $fid " $lignes"
      }
   } msgsoc]
   if {$errsoc==1} {
      gcn_print "socket error : $msgsoc\n"
   }
}
# ==========================================================================================

proc gcn_print { msg } {
   global gcn
   global audace

   if {[info commands ::console::affiche_resultat]=="::console::affiche_resultat"} {
      ::console::affiche_resultat "$msg\n"
   } else {
      #gren_info "$msg"
   }
}

proc gcn_decode { longs sockname } {
   global gcn
   global ros

   set errno [catch {
      # --- reinit gcn array
      set comments ""
      catch {
         set names [lsort [array names gcn]]
         foreach name $names {
            set res [regsub -all , $name " "]
            if {([lindex $res 0]=="$sockname")} {
               if {([string first status $name]==-1)&&([string first index_html $name]==-1)} {
                  set ligne "unset gcn($name)"
                  eval $ligne
               }
            }
         }
      }
      # --- date of receip
      if {[info commands ::audace::date_sys2ut]=="::audace::date_sys2ut"} {
         set date_rec_notice [mc_date2iso8601 [::audace::date_sys2ut now]]
      } else {
         set date_rec_notice [mc_date2iso8601 now]
      }
      # --- extract basic informations
      set pkt_type [lindex $longs 0]
      set res [gcn_pkt_type $pkt_type]
      set gcn($sockname,descr,type) [lindex $res 0]
      set gcn($sockname,descr,satellite) [lindex $res 1]
      set gcn($sockname,descr,prompt) [lindex $res 2]
      gcn_print "$date_rec_notice ($sockname) type $pkt_type: $gcn($sockname,descr,type)"
      #if {$gcn($sockname,descr,type)==""} {
      #   return
      #}
      gcn_print "($sockname) $longs"
      # --- common codes
      for {set k 0} {$k<40} {incr k} {
         set gcn($sockname,long,$k) [string toupper [lindex $longs $k] ]
      }
      set items [gcn_pkt_indices]
      #gcn_print "----"
      foreach item $items {
         set k [lindex $item 0]
         set name [lindex $item 1]
         set gcn($sockname,long,$name) $gcn($sockname,long,$k)
         #gcn_print "gcn($sockname,long,$name)=$gcn($sockname,long,$name)"
      }
      # --- date de l'envoi de la notice
      #gcn_print "----"
      set res [mc_date2ymdhms $date_rec_notice]
      set res [lrange $res 0 2]
      set pkt_date [mc_date2jd $res]
      #gcn_print "gcn($sockname,long,pkt_sod)=$gcn($sockname,long,pkt_sod)"
      set pkt_time [expr $gcn($sockname,long,pkt_sod)/100.]
      set gcn($sockname,descr,jd_pkt) [expr $pkt_date+$pkt_time/86400.] ; # jd de la notice
      if {[expr $gcn($sockname,descr,jd_pkt)-[mc_date2jd $date_rec_notice]]>0.5} {
         set gcn($sockname,descr,jd_pkt) [expr $gcn($sockname,descr,jd_pkt)-1.]
      }
      # --- translations
      if {$gcn($sockname,descr,satellite)=="SWIFT"} {
         set gcn($sockname,descr,burst_ra) [expr $gcn($sockname,long,burst_ra)*0.0001]
         set gcn($sockname,descr,burst_dec) [expr $gcn($sockname,long,burst_dec)*0.0001]
         if {$gcn($sockname,descr,prompt)>0} {
            set gcn($sockname,descr,trigger_num) [expr int($gcn($sockname,long,burst_trig))] ; # identificateur du trigger
            set gcn($sockname,descr,grb_error) [expr 0.0001*$gcn($sockname,long,burst_error)*60.]; # boite d'erreur en arcmin
            set soln_status [gcn_long2bits $gcn($sockname,long,18)]
            set gcn($sockname,descr,soln_status) $soln_status
            set gcn($sockname,descr,point_src) [string index $soln_status 0]
            set gcn($sockname,descr,grb) [string index $soln_status 1]
            set gcn($sockname,descr,image_trig) [string index $soln_status 4]
            set gcn($sockname,descr,def_not_grb) [string index $soln_status 5]
         }
         set grb_date [expr $gcn($sockname,long,burst_tjd)-13370.-1.+[mc_date2jd {2005 1 1}]] ; # TJD=13370 is 01 Jan 2005
         set grb_time [expr $gcn($sockname,long,burst_sod)/100.]
         set gcn($sockname,descr,burst_jd) [expr $grb_date+$grb_time/86400.] ; # jd du trigger
         if {($gcn($sockname,descr,burst_jd)-$gcn($sockname,descr,jd_pkt))>0.5} {
            set gcn($sockname,descr,burst_jd) [expr $gcn($sockname,descr,burst_jd)-1] ; # bug GCN du quart d'heure avant minuit
         }
      }
      if {$gcn($sockname,descr,satellite)=="INTEGRAL"} {
         set grb_date [expr $gcn($sockname,long,burst_tjd)-12640.+[mc_date2jd {2003 1 1}]]
         set grb_time [expr $gcn($sockname,long,burst_sod)/100.]
         set gcn($sockname,descr,grb_jd) [expr $grb_date+$grb_time/86400.] ; # jd0 du trigger
         if {($pkt_type==51)||($pkt_type==52)} {
            set ra [expr $gcn($sockname,long,14)*0.0001]
            set dec [expr $gcn($sockname,long,15)*0.0001]
         } else {
            set ra [expr $gcn($sockname,long,burst_ra)*0.0001]
            set dec [expr $gcn($sockname,long,burst_dec)*0.0001]
         }
         set radec [mc_precessradec [list $ra $dec] $gcn($sockname,descr,grb_jd) J2000.0]
         set gcn($sockname,descr,burst_ra) [lindex $radec 0]
         set gcn($sockname,descr,burst_dec) [lindex $radec 1]
         if {$gcn($sockname,descr,prompt)>0} {
            set trigger_subnum [expr int($gcn($sockname,long,burst_trig)/pow(2,16))]
            set gcn($sockname,descr,trigger_num) [expr int($gcn($sockname,long,burst_trig)-$trigger_subnum*pow(2,16))] ; # identificateur du trigger
            set gcn($sockname,descr,grb_error) [expr $gcn($sockname,long,burst_error)/60.]; # boite d'erreur en arcmin
            set test_mpos [gcn_long2bits $gcn($sockname,long,12)]
            set gcn($sockname,descr,test_mpos) $test_mpos
            if {($pkt_type==53)||($pkt_type==54)||($pkt_type==55)} {
               set gcn($sockname,descr,def_not_grb) [string index $test_mpos 30]
            }
            set gcn($sockname,descr,test) [string index $test_mpos 31]
            if {$gcn($sockname,descr,test)==1} {
               set gcn($sockname,descr,prompt) -1
            }
         }
      }
      if {$gcn($sockname,descr,satellite)=="FERMI"} {
         set gcn($sockname,descr,burst_ra) [expr $gcn($sockname,long,burst_ra)*0.0001]
         set gcn($sockname,descr,burst_dec) [expr $gcn($sockname,long,burst_dec)*0.0001]
         if {$gcn($sockname,descr,prompt)>0} {
            set gcn($sockname,descr,trigger_num) [expr int($gcn($sockname,long,burst_trig))] ; # identificateur du trigger
            set gcn($sockname,descr,grb_error) [expr 0.0001*$gcn($sockname,long,burst_error)*60.]; # boite d'erreur en arcmin
            set soln_status [gcn_long2bits $gcn($sockname,long,18)]
            set gcn($sockname,descr,soln_status) $soln_status
            set gcn($sockname,descr,point_src) [string index $soln_status 0]
            set gcn($sockname,descr,grb) [string index $soln_status 1]
            set gcn($sockname,descr,image_trig) [string index $soln_status 4]
            set gcn($sockname,descr,def_not_grb) [string index $soln_status 5]
         }
         set grb_date [expr $gcn($sockname,long,burst_tjd)-13370.-1.+[mc_date2jd {2005 1 1}]] ; # TJD=13370 is 01 Jan 2005
         set grb_time [expr $gcn($sockname,long,burst_sod)/100.]
         set gcn($sockname,descr,burst_jd) [expr $grb_date+$grb_time/86400.] ; # jd du trigger
         #if {($gcn($sockname,descr,burst_jd)-$gcn($sockname,descr,jd_pkt))>0.5} {
         #   set gcn($sockname,descr,burst_jd) [expr $gcn($sockname,descr,burst_jd)-1] ; # bug GCN du quart d'heure avant minuit
         #}
      }
      if {$gcn($sockname,descr,satellite)=="AGILE"} {
         set gcn($sockname,descr,burst_ra) [expr $gcn($sockname,long,burst_ra)*0.0001]
         set gcn($sockname,descr,burst_dec) [expr $gcn($sockname,long,burst_dec)*0.0001]
         if {$gcn($sockname,descr,prompt)>0} {
            set gcn($sockname,descr,trigger_num) [expr int($gcn($sockname,long,burst_trig))] ; # identificateur du trigger
            set gcn($sockname,descr,grb_error) [expr 0.0001*$gcn($sockname,long,burst_error)*60.]; # boite d'erreur en arcmin
            set soln_status [gcn_long2bits $gcn($sockname,long,18)]
            set gcn($sockname,descr,soln_status) $soln_status
            set gcn($sockname,descr,point_src) [string index $soln_status 0]
            set gcn($sockname,descr,grb) [string index $soln_status 1]
            set gcn($sockname,descr,image_trig) [string index $soln_status 4]
            set gcn($sockname,descr,def_not_grb) [string index $soln_status 5]
         }
         set grb_date [expr $gcn($sockname,long,burst_tjd)-13370.-1.+[mc_date2jd {2005 1 1}]] ; # TJD=13370 is 01 Jan 2005
         set grb_time [expr $gcn($sockname,long,burst_sod)/100.]
         set gcn($sockname,descr,burst_jd) [expr $grb_date+$grb_time/86400.] ; # jd du trigger
         #if {($gcn($sockname,descr,burst_jd)-$gcn($sockname,descr,jd_pkt))>0.5} {
         #   set gcn($sockname,descr,burst_jd) [expr $gcn($sockname,descr,burst_jd)-1] ; # bug GCN du quart d'heure avant minuit
         #}
      }
      if {$gcn($sockname,descr,satellite)=="MILAGRO"} {
         set gcn($sockname,descr,burst_ra) [expr $gcn($sockname,long,burst_ra)*0.0001]
         set gcn($sockname,descr,burst_dec) [expr $gcn($sockname,long,burst_dec)*0.0001]
         set gcn($sockname,descr,trigger_num) [expr int($gcn($sockname,long,4))] ; # identificateur du trigger
         set grb_date [expr $gcn($sockname,long,burst_tjd)-12640.-1.+[mc_date2jd {2003 1 1}]] ; # TJD=12640 is 01 Jan 2003
         set grb_time [expr $gcn($sockname,long,burst_sod)/100.]
         set gcn($sockname,descr,burst_jd) [expr $grb_date+$grb_time/86400.] ; # jd du trigger
         set gcn($sockname,descr,grb_error) [expr 0.0001*$gcn($sockname,long,burst_error)*60.]; # boite d'erreur en arcmin
         set gcn($sockname,descr,burst_sig) $gcn($sockname,long,9)
         set gcn($sockname,descr,bkg) [expr 0.0001*$gcn($sockname,long,10)]
         set gcn($sockname,descr,duration) [expr $gcn($sockname,long,13)/100.]
         set trigger_id [gcn_long2bits $gcn($sockname,long,18)]
         set gcn($sockname,descr,trigger_id) $trigger_id
         set gcn($sockname,descr,possible_grb) [string index $trigger_id 0]
         set gcn($sockname,descr,definite_grb) [string index $trigger_id 1]
         set gcn($sockname,descr,def_not_grb) [string index $trigger_id 15]
      }
      if {$gcn($sockname,descr,satellite)=="SNEWS"} {
         set gcn($sockname,descr,burst_ra) [expr $gcn($sockname,long,burst_ra)*0.0001]
         set gcn($sockname,descr,burst_dec) [expr $gcn($sockname,long,burst_dec)*0.0001]
         set gcn($sockname,descr,trigger_num) [expr int($gcn($sockname,long,4))] ; # identificateur du trigger
         set grb_date [expr $gcn($sockname,long,burst_tjd)-12640.-1.+[mc_date2jd {2003 1 1}]] ; # TJD=12640 is 01 Jan 2003
         set grb_time [expr $gcn($sockname,long,burst_sod)/100.]
         set gcn($sockname,descr,burst_jd) [expr $grb_date+$grb_time/86400.] ; # jd du trigger
         set gcn($sockname,descr,grb_error) [expr 0.0001*$gcn($sockname,long,burst_error)*60.]; # boite d'erreur en arcmin
         set gcn($sockname,descr,burst_sig) $gcn($sockname,long,9)
         set gcn($sockname,descr,duration) [expr $gcn($sockname,long,13)/100.]
         set trig_id [gcn_long2bits $gcn($sockname,long,18)]
         set gcn($sockname,descr,trig_id) $trig_id
         set gcn($sockname,descr,Subtype) [string index $trig_id 0]
         set gcn($sockname,descr,test_flag) [string index $trig_id 1]
         set gcn($sockname,descr,radec_undef) [string index $trig_id 2]
         set gcn($sockname,descr,retract) [string index $trig_id 5]
      }
      if {$gcn($sockname,descr,satellite)=="ANTARES"} {
         set gcn($sockname,descr,burst_ra) [expr $gcn($sockname,long,burst_ra)*0.0001]
         set gcn($sockname,descr,burst_dec) [expr $gcn($sockname,long,burst_dec)*0.0001]
         set gcn($sockname,descr,trigger_num) [expr int($gcn($sockname,long,4))] ; # identificateur du trigger
         set grb_date [expr $gcn($sockname,long,burst_tjd)-13370.-1.+[mc_date2jd {2005 1 1}]] ; # TJD=13370 is 01 Jan 2005
         set grb_time [expr $gcn($sockname,long,burst_sod)/100.]
         set gcn($sockname,descr,burst_jd) [expr $grb_date+$grb_time/86400.] ; # jd du trigger
         set gcn($sockname,descr,grb_error) [expr 0.0001*$gcn($sockname,long,burst_error)*60.]; # boite d'erreur en arcmin
         set gcn($sockname,descr,burst_flue) $gcn($sockname,long,9)
         set gcn($sockname,descr,integ_time) [expr $gcn($sockname,long,14)*4e-3]
         set gcn($sockname,descr,follow_up) $gcn($sockname,long,18) ; # =1 pour follow-up
         set gcn($sockname,descr,def_not_grb) 1
         if {($pkt_type=="901")||($pkt_type=="903")} {
            set gcn($sockname,descr,def_not_grb) 0
         }
      }
      if {$gcn($sockname,descr,satellite)=="LOOCUP"} {
         set gcn($sockname,descr,burst_ra) [expr $gcn($sockname,long,burst_ra)*0.0001]
         set gcn($sockname,descr,burst_dec) [expr $gcn($sockname,long,burst_dec)*0.0001]
         set gcn($sockname,descr,trigger_num) [expr int($gcn($sockname,long,4))] ; # identificateur du trigger
         set grb_date [expr $gcn($sockname,long,burst_tjd)-13370.-1.+[mc_date2jd {2005 1 1}]] ; # TJD=13370 is 01 Jan 2005
         set grb_time [expr $gcn($sockname,long,burst_sod)/10000.]
         #gren_info "grb_date" $grb_date , grb_time: $grb_time "
         set gcn($sockname,descr,burst_jd) [expr $grb_date+$grb_time/86400.] ; # jd du trigger
         set gcn($sockname,descr,grb_error) [expr 0.0001*$gcn($sockname,long,burst_error)*60.]; # boite d'erreur en arcmin
         set gcn($sockname,descr,burst_flue) $gcn($sockname,long,9)
         set gcn($sockname,descr,integ_time) [expr $gcn($sockname,long,14)*4e-3]
         set gcn($sockname,descr,burst_ra_2) [expr $gcn($sockname,long,10)*0.0001]
         set gcn($sockname,descr,burst_dec_2) [expr $gcn($sockname,long,11)*0.0001]
         set gcn($sockname,descr,burst_ra_3) [expr $gcn($sockname,long,12)*0.0001]
         set gcn($sockname,descr,burst_dec_3) [expr $gcn($sockname,long,13)*0.0001]
         set gcn($sockname,descr,burst_ra_4) [expr $gcn($sockname,long,14)*0.0001]
         set gcn($sockname,descr,burst_dec_4) [expr $gcn($sockname,long,15)*0.0001]
         set gcn($sockname,descr,burst_ra_5) [expr $gcn($sockname,long,16)*0.0001]
         set gcn($sockname,descr,burst_dec_5) [expr $gcn($sockname,long,17)*0.0001]
         set gcn($sockname,descr,time_burst) [expr int($gcn($sockname,long,18))]
         set gcn($sockname,descr,def_not_grb) 1
         if {($pkt_type=="905")||($pkt_type=="907")} {
            set gcn($sockname,descr,def_not_grb) 0
         }
      }
      # --- update status
      set gcn($sockname,status,last,last,jd_send) "$gcn($sockname,descr,jd_pkt)"
      set gcn($sockname,status,last,last,jd_received) "[mc_date2jd $date_rec_notice]"
      set gcn($sockname,status,last,last,type) $gcn($sockname,descr,type)
      set gcn($sockname,status,last,last,prompt) $gcn($sockname,descr,prompt)
      set gcn($sockname,status,last,last,satellite) $gcn($sockname,descr,satellite)
      if {$gcn($sockname,descr,prompt)>=0} {
         set gcn($sockname,status,$gcn($sockname,descr,prompt),$gcn($sockname,descr,satellite),jd_send) $gcn($sockname,status,last,last,jd_send)
         set gcn($sockname,status,$gcn($sockname,descr,prompt),$gcn($sockname,descr,satellite),jd_received) $gcn($sockname,status,last,last,jd_received)
         set gcn($sockname,status,$gcn($sockname,descr,prompt),$gcn($sockname,descr,satellite),type) $gcn($sockname,status,last,last,type)
         set names [lsort [array names gcn]]
         foreach name $names {
            set res [regsub -all , $name " "]
            #gren_info ">>>> GCN name=$name => res=$res"
            if {([lindex $res 1]=="descr")} {
               set re [lindex $res 2]
               if {($re=="type")||($re=="prompt")||($re=="satellite")} {
                  continue
               }
               set gcn($sockname,status,$gcn($sockname,descr,prompt),$gcn($sockname,descr,satellite),$re) $gcn($name)
            }
         }
      }
      set lignes ""
      set names [lsort [array names gcn]]
      foreach name $names {
         set res [regsub -all , $name " "]
         if {[lindex $res 1]=="status"} {
            set res [lrange $res 2 end]
            append lignes "$sockname $res $gcn($name)\n"
         }
      }
      gcn_print "$lignes"
      if {[info exist gcn($sockname,index_html)]>=1} {
         catch {
            set f [open $gcn($sockname,index_html) w]
            puts -nonewline $f "[mc_date2iso8601 $date_rec_notice]\n$lignes"
            close $f
         }
      }
      # --- new decode
      catch {
         gcn_definition_from_sock_pkt_def_doc
         set gcn($sockname,textlists) [gcn_longs2textlists $longs]
      }
      # --- use by ROS
      catch { source $ros(root,ros)/src/majordome/gcn.tcl }
      # --- infos
      set items [lsort [array names gcn]]
      set comments ""
      append comments " ---------------\n"
      foreach item $items {
         set ident [regsub -all , "$item" " "]
         if {([lindex $ident 0]=="$sockname")&&([lindex $ident 1]=="descr")} {
            set name [lindex $ident 2]
            append comments " gcn($sockname,descr,$name) = $gcn($sockname,descr,$name)\n"
         }
      }
      append comments " ---------------\n"
      #gcn_print "$comments"
   } msg]
   if {$errno==1} {
      append comments "PB: $msg\n"
      gcn_print "PB: $msg"
   }
   #
   catch {
      set f [open $ros(root,htdocs)/htdocs/gcn.txt a]
      puts -nonewline $f "[mc_date2iso8601 $date_rec_notice] : ($sockname) $longs \n$comments"
      close $f
   }
}

proc gcn_long2bits { long } {
   set hs [format %08x $long]
   set h1 [string range $hs 6 7]
   set h2 [string range $hs 4 5]
   set h3 [string range $hs 2 3]
   set h4 [string range $hs 0 1]
   set ligne "binary scan \\x$h1 b8 b1"
   eval $ligne
   set ligne "binary scan \\x$h2 b8 b2"
   eval $ligne
   set ligne "binary scan \\x$h3 b8 b3"
   eval $ligne
   set ligne "binary scan \\x$h4 b8 b4"
   eval $ligne
   set b ${b1}${b2}${b3}${b4}
   return $b
}

proc gcn_pkt_indices { } {
   set lignes {
#define PKT_TYPE      0   /* Packet type number */
#define PKT_SERNUM    1   /* Packet serial number */
#define PKT_HOP_CNT   2   /* Packet hop counter */
#define PKT_SOD       3   /* Packet Sec-Of-Day [centi-sec] (sssss.sss*100) */
#define BURST_TRIG    4   /* BATSE Trigger number */
#define BURST_TJD     5   /* Truncated Julian Day */
#define BURST_SOD     6   /* Sec-of-Day [centi-secs] (sssss.sss*100) */
#define BURST_RA      7   /* RA  [centi-deg] (0.0 to 359.999 *100) */
#define BURST_DEC     8   /* Dec [centi-deg] (-90.0 to +90.0 *100) */
#define BURST_INTEN   9   /* Intensity [cnts] */
#define BURST_PEAK   10   /* Peak Intensity [cnts/1.024sec] */
#define BURST_ERROR  11   /* Location uncertainty [centi-deg] */
#define SC_AZ        12   /* Burst SC Az [centi-deg] (0.0 to 359.999 *100) */
#define SC_EL        13   /* Burst SC El [centi-deg] (-90.0 to +90.0 *100) */
#define SC_X_RA      14   /* SC X-axis RA [centi-deg] (0.0 to 359.999 *100) */
#define SC_X_DEC     15   /* SC X-axis Dec [centi-deg] (-90.0 to +90.0 *100) */
#define SC_Z_RA      16   /* SC Z-axis RA [centi-deg] (0.0 to 359.999 *100) */
#define SC_Z_DEC     17   /* SC Z-axis Dec [centi-deg] (-90.0 to +90.0 *100) */
#define TRIGGER_ID   18   /* Flag bits that identify the trigger type */
#define MISC         19   /* Misc indicator flag bits */
#define E_SC_AZ      20   /* Earth's center in SC Az */
#define E_SC_EL      21   /* Earth's center in SC El */
#define SC_RADIUS    22   /* Orbital radius of the GRO SC [km] */
#define BURST_T_PEAK 23   /* Time of Peak intensity [centi-sec] (sssss.ss*100) */
#define PKT_SPARE24  24   /* Begining of spare section */
#define PKT_SPARE38  38   /* End of the spare section */
#define PKT_TERM     39   /* Packet termination character */
   }
   set lignes [split $lignes \n]
   set textes ""
   foreach ligne $lignes {
      if {[llength $ligne]<2} {
         continue
      }
      set texte [list [lindex $ligne 2] [string tolower [lindex $ligne 1]]]
      lappend textes $texte
   }
   return $textes
}

proc gcn_pkt_type { pkt_type } {
   # http://gcn.gsfc.nasa.gov/sock_pkt_def_doc.html
   set lignes {
      1       BATSE_ORIGINAL     NO LONGER AVAILABLE
      2       Test
      3       Imalive
      4       Kill
     11       BATSE_MAXBC        NO LONGER AVAILABLE
     21       Bradford_TEST      NO LONGER AVAILABLE
     22       BATSE_FINAL        NO LONGER AVAILABLE
     24       BATSE_LOCBURST     NO LONGER AVAILABLE
     25       ALEXIS             NO LONGER AVAILABLE
     26       RXTE-PCA_ALERT     NO LONGER AVAILABLE
     27       RXTE-PCA           NO LONGER AVAILABLE
     28       RXTE-ASM_ALERT     NO LONGER AVAILABLE
     29       RXTE-ASM           NO LONGER AVAILABLE
     30       COMPTEL            NO LONGER AVAILABLE
     31       IPN_RAW
     32       IPN_SEGMENT        MAY BE RE-AVAILABLE
     33       SAX-WFC_ALERT      NOT AVAILABLE
     34       SAX-WFC            NO LONGER AVAILABLE
     35       SAX-NFI_ALERT      NOT AVAILABLE
     36       SAX-NFI            NO LONGER AVAILABLE
     37       RXTE-ASM_XTRANS    NO LONGER AVAILABLE
     38       spare/testing
     39       IPN_POSITION
     40       HETE_S/C_ALERT     NO LONGER AVAILABLE
     41       HETE_S/C_UPDATE    NO LONGER AVAILABLE
     42       HETE_S/C_LAST      NO LONGER AVAILABLE
     43       HETE_GNDANA        NO LONGER AVAILABLE
     44       HETE_Test
     45       GRB_COUNTERPART
     46       SWIFT_TOO_FOM_OBSERVE
     47       SWIFT_TOO_SC_SLEW
     48       DOW_TOD_TEST
     51       INTEGRAL_POINTDIR
     52       INTEGRAL_SPIACS
     53       INTEGRAL_WAKEUP
     54       INTEGRAL_REFINED
     55       INTEGRAL_OFFLINE
     56       INTEGRAL_WEAK
     57       AAVSO                            NOT YET AVAILABLE
     58       MILAGRO                          NO LONGER AVAILABLE
     59       KONUS_LIGHTCURVE                 NOT YET AVAILABLE
     60       SWIFT_BAT_GRB_ALERT
     61       SWIFT_BAT_GRB_POSITION
     62       SWIFT_BAT_GRB_NACK_POSITION
     63       SWIFT_BAT_GRB_LIGHTCURVE
     64       SWIFT_BAT_SCALED_MAP             NOT PUBLIC, SWIFT TEAM ONLY
     65       SWIFT_FOM_OBSERVE
     66       SWIFT_SC_SLEW
     67       SWIFT_XRT_POSITION
     68       SWIFT_XRT_SPECTRUM
     69       SWIFT_XRT_IMAGE
     70       SWIFT_XRT_LIGHTCURVE
     71       SWIFT_XRT_NACK_POSITION
     72       SWIFT_UVOT_IMAGE
     73       SWIFT_UVOT_SRC_LIST
     76       SWIFT_BAT_GRB_PROC_LIGHTCURVE    NOT YET AVAILABLE
     77       SWIFT_XRT_PROC_SPECTRUM
     78       SWIFT_XRT_PROC_IMAGE
     79       SWIFT_UVOT_PROC_IMAGE
     80       SWIFT_UVOT_PROC_SRC_LIST
     81       SWIFT_UVOT_POSITION
     82       SWIFT_BAT_GRB_POS_TEST
     83       SWIFT_POINTDIR
     84       SWIFT_BAT_TRANS
     85       SWIFT_XRT_THRESHPIX              NOT PUBLIC, SWIFT TEAM ONLY
     86       SWIFT_XRT_THRESHPIX_PROC         NOT PUBLIC, SWIFT TEAM ONLY
     87       SWIFT_XRT_SPER                   NOT PUBLIC, SWIFT TEAM ONLY
     88       SWIFT_XRT_SPER_PROC              NOT PUBLIC, SWIFT TEAM ONLY
     89       SWIFT_UVOT_NACK_POSITION
     97       SWIFT_BAT_QUICKLOOK_POSITION
     98       SWIFT_BAT_SUBTHRESHOLD_POSITION
     99       SWIFT_BAT_SLEW_GRB_POSITION
     100      SuperAGILE_GRB_POS_WAKEUP
     101      SuperAGILE_GRB_POS_GROUND
     102      SuperAGILE_GRB_POS_REFINED
     107      AGILE_POINTDIR
     109      SuperAGILE_GRB_POS_TEST
     110      FERMI_GBM_ALERT
     111      FERMI_GBM_FLT_POS
     112      FERMI_GBM_GND_POS
     114      FERMI_GBM_GND_INTERNAL           NOT PUBLIC, FERMI TEAM ONLY
     115      FERMI_GBM_FIN_POS
     119      FERMI_GBM_POS_TEST
     120      FERMI_LAT_GRB_POS_INI            NOT PUBLIC, FERMI TEAM ONLY
     121      FERMI_LAT_GRB_POS_UPD
     122      FERMI_LAT_GRB_POS_DIAG           NOT PUBLIC, FERMI TEAM ONLY
     123      FERMI_LAT_TRANS
     124      FERMI_LAT_GRB_POS_TEST
     125      FERMI_LAT_MONITOR
     126      FERMI_SC_SLEW
     127      FERMI_LAT_GND
     128      FERMI_LAT_OFFLINE
     129      FERMI_POINTDIR
     130      SIMBAD/NED_SEARCH_RESULTS
     131      PIOTS_OT_POS                     NOT YET AVAILABLE TO THE PUBLIC
     133      SWIFT_BAT_MONITOR
     134      MAXI_UNKNOWN_SOURCE
     135      MAXI_KNOWN_SOURCE
     136      MAXI_TEST
     137      OGLE                             Soon to be AVAILABLE
     139      MOA
     140      SWIFT_BAT_SUB_SUB_THRESH_POS     NOT YET AVAILABLE
     141      SWIFT_BAT_KNOWN_SRC_POS          NOT YET AVAILABLE
     901      ANTARES_GRB_POSITION             AVAILABLE ONLY FOR TAROT COLLABORATION
     902      ANTARES_GRB_POS_TEST             AVAILABLE ONLY FOR TAROT COLLABORATION
     903      ANTARES_GRB_POS_REFINED          AVAILABLE ONLY FOR TAROT COLLABORATION
     905      LOOCUP_GRB_POSITION              AVAILABLE ONLY FOR TAROT COLLABORATION
     906      LOOCUP_GRB_POS_TEST              AVAILABLE ONLY FOR TAROT COLLABORATION
     907      LOOCUP_GRB_POS_REFINED           AVAILABLE ONLY FOR TAROT COLLABORATION
   }
   set lignes [split $lignes \n]
   set textes ""
   set n [llength $lignes]
   set msg "UNKNOWN"
   set k 0
   foreach ligne $lignes {
      set type [lindex $ligne 0]
      if {$pkt_type==$type} {
         set msg [lindex $ligne 1]
         break
      }
      incr k
   }
   lappend textes $msg
   # --- satellite identification
   set satellite UNKNOWN
   if {($pkt_type>=11)&&($pkt_type<=24)} {
      set satellite BATSE
   }
   if {($pkt_type>=25)&&($pkt_type<=25)} {
      set satellite ALEXIS
   }
   if {($pkt_type>=26)&&($pkt_type<=29)} {
      set satellite RXTE
   }
   if {($pkt_type>=30)&&($pkt_type<=30)} {
      set satellite COMPTEL
   }
   if {($pkt_type>=31)&&($pkt_type<=32)} {
      set satellite IPN
   }
   if {($pkt_type>=33)&&($pkt_type<=36)} {
      set satellite SAX
   }
   if {($pkt_type>=37)&&($pkt_type<=37)} {
      set satellite RXTE
   }
   if {($pkt_type>=39)&&($pkt_type<=39)} {
      set satellite IPN
   }
   if {($pkt_type>=40)&&($pkt_type<=44)} {
      set satellite HETE
   }
   if {($pkt_type>=45)&&($pkt_type<=45)} {
      set satellite COUNTERPART
   }
   if {($pkt_type>=51)&&($pkt_type<=55)} {
      set satellite INTEGRAL
   }
   if {($pkt_type>=57)&&($pkt_type<=57)} {
      set satellite SNEWS
   }
   if {($pkt_type>=58)&&($pkt_type<=58)} {
      set satellite MILAGRO
   }
   if {($pkt_type>=59)&&($pkt_type<=59)} {
      set satellite KONUS
   }
   if {($pkt_type>=60)&&($pkt_type<=89)} {
      set satellite SWIFT
   }
   if {($pkt_type>=46)&&($pkt_type<=47)} {
      set satellite SWIFT
   }
   if {($pkt_type>=100)&&($pkt_type<=109)} {
      set satellite AGILE
   }
   if {($pkt_type>=110)&&($pkt_type<=129)} {
      set satellite FERMI
   }
   if {($pkt_type>=901)&&($pkt_type<=903)} {
      set satellite ANTARES
   }
   if {($pkt_type>=905)&&($pkt_type<=907)} {
      set satellite LOOCUP
   }
   lappend textes $satellite
   # --- prompt identification
   # =-1 informations only, =0 pointdir, =1 prompt, =2 refined
   set prompt -1
   if {($pkt_type==107)||($pkt_type==129)||($pkt_type==83)||($pkt_type==51)||($pkt_type==902)||($pkt_type==906)||($pkt_type==46)||($pkt_type==47)} {
      set prompt 0
   }
   # obsolete prompts ($pkt_type==53)||($pkt_type==40)||($pkt_type==33)||($pkt_type==35)||($pkt_type==30)||($pkt_type==26)||($pkt_type==28)||($pkt_type==1)
   # $pkt_type==111
   if {($pkt_type==100)||($pkt_type==121)||($pkt_type==61)||($pkt_type==58)||($pkt_type==901)||($pkt_type==905)||($pkt_type==98)} {
      set prompt 1
   }
   # obsolete refined ($pkt_type==41)||($pkt_type==42)||($pkt_type==43)||($pkt_type==39)
   if {($pkt_type==101)||($pkt_type==102)||($pkt_type==67)||($pkt_type==54)||($pkt_type==55)||($pkt_type==903)||($pkt_type==907)} {
      set prompt 2
   }
   lappend textes $prompt
   return $textes
}

# ===================================
# ===================================
# ===================================

# ===========================================================================================
# Lecture d'une page HTML via http
#
proc gcn_read_url_contents { url {fullfile_out ""} } {
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

# ----------------------------------------------------------
# Use gcn_definition_from_sock_pkt_def_doc to read the file
# sock_pkt_def_doc.html and to initialize the definition
# of the alert numbers.
#
# Use this proc before using the folling procs:
#
# Input: the fullname of the file sock_pkt_def_doc.html
# downloaded from URL http://gcn.gsfc.nasa.gov/sock_pkt_def_doc.html
#
# Output:
# Return none
# Two global variables are set:
# gcn(sock_pkt_def_doc,number_names)
# gcn(sock_pkt_def_doc,item_descriptions)
# ----------------------------------------------------------
proc gcn_definition_from_sock_pkt_def_doc { {fsock ""} } {
   global gcn ros

   # INTERNET  SOCKET  PACKET  DEFINITION  DOC
   if {$fsock==""} {
      if {[info exists ::audace(rep_userCatalog)]==1} {
         set path [ file join $::audace(rep_userCatalog) gcn ]
         catch {file mkdir $path}
      } elseif {[info exists ros(root,ressources)]==1} {
         set path [ file join $ros(root,ressources) ressources gcn ]
         catch {file mkdir $path}
      } else {
         set path [pwd]
      }
      set fsock ${path}/sock_pkt_def_doc.html
      if {[file exists $fsock]==0} {
         gcn_read_url_contents http://gcn.gsfc.nasa.gov/sock_pkt_def_doc.html $fsock
      }
   }

   # --- lecture du fichier en memoire
   set f [open $fsock r]
   set lignes [split [read $f] \n]
   close $f

   # --- recherche la table de relation entre number et name
   # gcn(sock_pkt_def_doc,number_names)
   set gcn(sock_pkt_def_doc,number_names) ""
   set nl [llength $lignes]
   set kl 0
   while {$kl<=$nl} {
      set ligne [lindex $lignes $kl]
      set kkey1 [string first "This table lists all the currently valid notices (by their name)" $ligne]
      if {$kkey1>=0} {
         incr kl ; set ligne [lindex $lignes $kl]
         incr kl ; set ligne [lindex $lignes $kl]
         incr kl ; set ligne [lindex $lignes $kl]
         incr kl ; set ligne [lindex $lignes $kl]
         incr kl ; set ligne [lindex $lignes $kl]
         for {set kl2 $kl} {$kl2<$nl} {incr kl2} {
            set ligne [lindex $lignes $kl2]
            set number [lindex $ligne 0]
            set name   [lindex $ligne 1]
            if {$number==""} { break }
            lappend gcn(sock_pkt_def_doc,number_names) [list $number $name]
         }
      }
      incr kl
   }
   lappend gcn(sock_pkt_def_doc,number_names) [list 901 ANTARES_GRB_POSITION]
   lappend gcn(sock_pkt_def_doc,number_names) [list 902 ANTARES_GRB_POS_TEST]
   lappend gcn(sock_pkt_def_doc,number_names) [list 903 ANTARES_GRB_POS_REFINED]
   lappend gcn(sock_pkt_def_doc,number_names) [list 905 LOOCUP_GRB_POSITION]
   lappend gcn(sock_pkt_def_doc,number_names) [list 906 LOOCUP_GRB_POS_TEST]
   lappend gcn(sock_pkt_def_doc,number_names) [list 907 LOOCUP_GRB_POS_REFINED]

   # --- Transforme le fichier sock_pkt_def_doc.html
   # en une liste qui definit les records pour chaque
   # type de notice
   set gcn(sock_pkt_def_doc,item_descriptions) ""
   set sock_pkt_def_docs ""
   set nl [llength $lignes]
   set kl 0
   while {$kl<=$nl} {
      set ligne [lindex $lignes $kl]
      set kkey1 [string first " PACKET CONTENTS:</b>" $ligne]
      set kkey2 [string first "PACKET ITEM DESCRIPTIONS for type=" $ligne]
      if {$kkey1>=0} {
         set k1 [string first =   $ligne]
         set k2 [string first " " $ligne $k1]
         set xpkt_type [string trim [string range $ligne [expr 1+$k1] $k2]]
      } elseif {$kkey2>=0} {
         set k1 [string first =   $ligne]
         set k2 [string first ":" $ligne $k1]
         set xpkt_type [string trim [string range $ligne [expr 1+$k1] [expr $k2-1]]]
      } else {
         incr kl
         continue
      }
      #
      set kl2 [expr $kl+1]
      set nl2 [expr $kl2+10]
      #::console::affiche_resultat "======== xpkt_type=$xpkt_type ($kkey1,$kkey2)\n"
      while {$kl2<=$nl2} {
         set ligne [lindex $lignes $kl2]
         set kkey [string first "-----------  -----   ---------    ----------      ----------------" $ligne]
         if {$kkey>=0} { break }
         incr kl2
      }
      set records ""
      set kl [expr 1+$kl2]
      set ligne [lindex $lignes $kl]
      #
      set kl2 [expr $kl]
      set nl2 [expr $kl2+41]
      while {$kl2<=$nl2} {
         set ligne [lindex $lignes $kl2]
         set number [lindex $ligne 0]
         set indice [lindex $ligne 1]
         set indices [regsub -all -- - $indice " "]
         set indice1 [lindex $indices 0]
         set indice2 [lindex $indices 1]
         if {$indice2==""} { set indice2 $indice1 }
         set name [lindex $ligne 2]
         if {$name==""} { incr kl2 ; continue }
         set k [string first \[ $name]
         if {$k>=0} { set name [string range $name 0 [expr $k-1]] }
         set unit [lindex $ligne 3]
         set unit2 [regsub -all -- \\\[ $unit ""]
         set unit [regsub -all -- \\\] $unit2 ""]
         set comment [string range $ligne 50 end]
         #if {$xpkt_type==83} {
         #  ::console::affiche_resultat "$number $indice1 $indice2 $name $unit $comment\n"
         #}
         set record "$number $indice1 $indice2 $name $unit \"$comment\""
         lappend records $record
         if {($number!="long")&&($number!="quad_char")} { break }
         if {$indice2==39} { break }
         incr kl2
      }
      lappend gcn(sock_pkt_def_doc,item_descriptions) [list $xpkt_type $records]
      incr kl
   }
   # --- ANTARES et LOCCUP
   set xpkt_types {901 902 903}
   foreach xpkt_type $xpkt_types {
      set records ""
      lappend records "long  0  0 pkt_type     integer         \"Packet type number\""
      lappend records "long  4  4 trig_num     integer         \"Trigger number\""
      lappend records "long  5  5 burst_tjd    days            \"Truncated Julian Day\""
      lappend records "long  6  6 burst_sod    centi-sec       \"(int)(sssss.sss *100)\""
      lappend records "long  7  7 burst_ra     0.0001-deg      \"(int)(0.0 to 359.9999 *10000)\""
      lappend records "long  8  8 burst_dec    0.0001-deg      \"(int)(-90.0 to +90.0 *10000)\""
      lappend records "long  9  9 burst_flue   integer         \"Number of neutrinos for this trigger\""
      lappend records "long 11 11 burst_error  0.0001-deg      \"(int)(0.0 to 180.0 *10000)\""
      lappend records "long 14 14 integ_time   4mSec           \"Time between two neutrinos\""
      lappend records "long 18 18 follow_up    integer         \"=1 if we must have a follow-up after prompt\""
      lappend gcn(sock_pkt_def_doc,item_descriptions) [list $xpkt_type $records]
   }
   set xpkt_types {905 906 907}
   foreach xpkt_type $xpkt_types {
      set records ""
      lappend records "long  0  0 pkt_type     integer         \"Packet type number\""
      lappend records "long  4  4 trig_num     integer         \"Trigger number\""
      lappend records "long  5  5 burst_tjd    days            \"Truncated Julian Day\""
      lappend records "long  6  6 burst_sod    centi-sec       \"(int)(sssss.sss *100)\""
      lappend records "long  7  7 burst_ra     0.0001-deg      \"(int)(0.0 to 359.9999 *10000)\""
      lappend records "long  8  8 burst_dec    0.0001-deg      \"(int)(-90.0 to +90.0 *10000)\""
      lappend records "long  9  9 burst_flue   integer         \"Number of neutrinos for this trigger\""
      lappend records "long 10 10 burst_ra_2   0.0001-deg      \"(int)(0.0 to 359.9999 *10000)\""
      lappend records "long 11 11 burst_dec_2  0.0001-deg      \"(int)(-90.0 to +90.0 *10000)\""
      lappend records "long 12 12 burst_ra_3   0.0001-deg      \"(int)(0.0 to 359.9999 *10000)\""
      lappend records "long 13 13 burst_dec_3  0.0001-deg      \"(int)(-90.0 to +90.0 *10000)\""
      lappend records "long 14 14 burst_ra_4   0.0001-deg      \"(int)(0.0 to 359.9999 *10000)\""
      lappend records "long 15 15 burst_dec_4  0.0001-deg      \"(int)(-90.0 to +90.0 *10000)\""
      lappend records "long 16 16 burst_ra_5   0.0001-deg      \"(int)(0.0 to 359.9999 *10000)\""
      lappend records "long 17 17 burst_dec_5  0.0001-deg      \"(int)(-90.0 to +90.0 *10000)\""
      #lappend records "long 11 11 burst_error  0.0001-deg      \"(int)(0.0 to 180.0 *10000)\""
      lappend records "long 14 14 integ_time   4mSec           \"Time between two neutrinos\""
      lappend records "long 18 18 time_burst   integer         \"Not defined\""
      lappend gcn(sock_pkt_def_doc,item_descriptions) [list $xpkt_type $records]
   }
}

# ----------------------------------------------------------
# Use gcn_get_definition to return the definition of an alert type
# defined by its number.
#
# gcn_definition_from_sock_pkt_def_doc before using this proc.
#
# Input: A GCN alert type number
# as defined in http://gcn.gsfc.nasa.gov/sock_pkt_def_doc.html
#
# Output: Returns the list of the alert type definition.
# ----------------------------------------------------------
proc gcn_get_definition { number } {
   global gcn

   set knumber [lsearch -index 0 -exact $gcn(sock_pkt_def_doc,item_descriptions) $number]
   if {$knumber==-1} { return }
   set records [lindex [lindex $gcn(sock_pkt_def_doc,item_descriptions) $knumber] 1]
   return $records
}

# ----------------------------------------------------------
# Use gcn_number2name to return the name of an alert type
# defined by its number.
#
# gcn_definition_from_sock_pkt_def_doc before using this proc.
#
# Input: A GCN alert type number
# as defined in http://gcn.gsfc.nasa.gov/sock_pkt_def_doc.html
#
# Output: Returns the GCN alert type name
# ----------------------------------------------------------
proc gcn_number2name { number } {
   global gcn

   set k [lsearch -index 0 $gcn(sock_pkt_def_doc,number_names) $number]
   if {$k==-1} {
      error "Number $number not found in gcn(sock_pkt_def_doc,number_names)"
   }
   set name [lindex [lindex $gcn(sock_pkt_def_doc,number_names) $k] 1]
   return $name
}

# ----------------------------------------------------------
# Use gcn_name2number2 to return the number of an alert type
# defined by its name.
#
# gcn_definition_from_sock_pkt_def_doc before using this proc.
#
# Input: A GCN alert type name
# as defined in http://gcn.gsfc.nasa.gov/sock_pkt_def_doc.html
#
# Output: Returns the GCN alert type number
# ----------------------------------------------------------
proc gcn_name2number { name } {
   global gcn

   set k [lsearch -index 1 $gcn(sock_pkt_def_doc,number_names) $name]
   if {$k==-1} {
      error "Name $name not found in gcn(sock_pkt_def_doc,number_names)"
   }
   set number [lindex [lindex $gcn(sock_pkt_def_doc,number_names) $k] 0]
   return $number
}

# ----------------------------------------------------------
# Use gcn_number2infos to return the satellite name and the
# pertienence from the number of an alert type.
#
# Input: A GCN alert type number
# as defined in http://gcn.gsfc.nasa.gov/sock_pkt_def_doc.html
#
# Output: Returns a list of two elements: satellite pertinence
# ----------------------------------------------------------
proc gcn_number2infos { number } {
   set pkt_type $number
   # --- satellite identification
   set satellite UNKNOWN
   if {($pkt_type>=11)&&($pkt_type<=24)} {
      set satellite BATSE
   }
   if {($pkt_type>=25)&&($pkt_type<=25)} {
      set satellite ALEXIS
   }
   if {($pkt_type>=26)&&($pkt_type<=29)} {
      set satellite RXTE
   }
   if {($pkt_type>=30)&&($pkt_type<=30)} {
      set satellite COMPTEL
   }
   if {($pkt_type>=31)&&($pkt_type<=32)} {
      set satellite IPN
   }
   if {($pkt_type>=33)&&($pkt_type<=36)} {
      set satellite SAX
   }
   if {($pkt_type>=37)&&($pkt_type<=37)} {
      set satellite RXTE
   }
   if {($pkt_type>=39)&&($pkt_type<=39)} {
      set satellite IPN
   }
   if {($pkt_type>=40)&&($pkt_type<=44)} {
      set satellite HETE
   }
   if {($pkt_type>=45)&&($pkt_type<=45)} {
      set satellite COUNTERPART
   }
   if {($pkt_type>=51)&&($pkt_type<=55)} {
      set satellite INTEGRAL
   }
   if {($pkt_type>=57)&&($pkt_type<=57)} {
      set satellite SNEWS
   }
   if {($pkt_type>=58)&&($pkt_type<=58)} {
      set satellite MILAGRO
   }
   if {($pkt_type>=59)&&($pkt_type<=59)} {
      set satellite KONUS
   }
   if {($pkt_type>=60)&&($pkt_type<=89)} {
      set satellite SWIFT
   }
   if {($pkt_type>=46)&&($pkt_type<=47)} {
      set satellite SWIFT
   }
   if {($pkt_type>=100)&&($pkt_type<=109)} {
      set satellite AGILE
   }
   if {($pkt_type>=110)&&($pkt_type<=129)} {
      set satellite FERMI
   }
   if {($pkt_type>=901)&&($pkt_type<=903)} {
      set satellite ANTARES
   }
   if {($pkt_type>=905)&&($pkt_type<=907)} {
      set satellite LOOCUP
   }
   # --- prompt identification
   # =-1 informations only, =0 pointdir, =1 prompt, =2 refined
   set prompt INFOS
   if {($pkt_type==107)||($pkt_type==129)||($pkt_type==83)||($pkt_type==51)||($pkt_type==902)||($pkt_type==906)||($pkt_type==46)||($pkt_type==47)} {
      set prompt POINTDIR
   }
   # obsolete prompts ($pkt_type==40)||($pkt_type==33)||($pkt_type==35)||($pkt_type==30)||($pkt_type==26)||($pkt_type==28)||($pkt_type==1)
   # $pkt_type==111
   if {($pkt_type==53)||($pkt_type==100)||($pkt_type==121)||($pkt_type==61)||($pkt_type==58)||($pkt_type==901)||($pkt_type==905)||($pkt_type==98)} {
      set prompt PROMPT
   }
   # obsolete refined ($pkt_type==41)||($pkt_type==42)||($pkt_type==43)||($pkt_type==39)
   if {($pkt_type==101)||($pkt_type==102)||($pkt_type==81)||($pkt_type==67)||($pkt_type==54)||($pkt_type==55)||($pkt_type==903)||($pkt_type==907)} {
      set prompt REFINED
   }
   return [list $satellite $prompt]
}

# ----------------------------------------------------------
# Use gcn_longs2textlists to return a clear list from the longs.
#
# gcn_definition_from_sock_pkt_def_doc before using this proc.
#
# Input: A list constituted by 40 elements (longs)
#        A date to stamp the packet received
#
# Output: A list of records,
# Raw data from longs (key is from sock_pkt_def_doc)
# {raw key value unit comment}
# Processed data
# {processed key value unit comment}
#
# Typically, the usefull records are:
# processed pkt_typename (SWIFT_BAT_GRB_POSITION | ...)
# processed def_not_grb (0|1)
# processed trigger_experiment (SWIFT | ...)
# processed position_type (INFOS | POINTDIR | PROMPT | REFINED)
# processed pkt_jd (2455737.10609 | ...)
# processed pkt_date (2011-06-24T14:32:46.175 | ...)
# processed trigger_num (455967 | ...)
# processed burst_jd (2455737.10214 | ...)
# processed burst_date (2011-06-24T14:27:04.896 | ...)
# processed equinox (J2000 | ...)
# processed ra (280.2655 | ...)
# processed dec (-5.628 | ...)
# processed error (0.05 | ...)
# processed integ_time (320.0 | ...)
# processed burst_mag (20.3 | ...)
# processed mag_error (0.17 | ...)
# ----------------------------------------------------------
proc gcn_longs2textlists { longs {date ""} } {
   global gcn

   if {$date==""} {
      if {[info commands ::audace::date_sys2ut]=="::audace::date_sys2ut"} {
         set date_rec_notice [mc_date2iso8601 [::audace::date_sys2ut now]]
      } else {
         set date_rec_notice [mc_date2iso8601 now]
      }
   } else {
      set date_rec_notice [mc_date2iso8601 $date]
   }
   set textlists ""
   set number [lindex $longs 0]
   set records [gcn_get_definition $number]
   foreach record $records {
      set number [lindex $record 0]
      set indice1 [lindex $record 1]
      set indice2 [lindex $record 2]
      set name [lindex $record 3]
      set unit [lindex $record 4]
      set comment [lindex $record 5]
      #::console::affiche_resultat "$record\n"
      #::console::affiche_resultat "$number $indice1 $indice2 $name <<<$unit>>> $comment\n"
      if {$indice2==$indice1} {
         set val [lindex $longs $indice1]
         lappend textlists "raw $name $val $unit \"$comment\""
         set namep ""
         set valp $val
         set unitp $val
         set commentp $comment
         # --- convert units
         if {$unit=="0.0001-deg"} {
            set valp [expr 0.0001*$valp]
            set unitp "deg"
         }
         if {$unit=="10^-4-deg"} {
            set valp [expr 0.0001*$valp]
            set unitp "deg"
         }
         if {$unit=="centi-sec"} {
            set valp [expr 0.01*$valp]
            set unitp "sec"
         }
         if {$unit=="arcsec"} {
            set valp [expr $valp/3600.]
            set unitp "deg"
         }
         if {$unit=="4mSec"} {
            set valp [expr $valp*0.004]
            set unitp "sec"
         }
         # ---
         if {[lsearch -exact {pkt_type} $name]>=0} {
            set res [gcn_number2name $val]
            lappend textlists "processed pkt_typename $res \"text\" \"Name of the packet\""
            set res [gcn_number2infos $val]
            set satellite [lindex $res 0]
            set prompt [lindex $res 1]
            set def_not_grb ""
            if {$satellite=="INTEGRAL"} {
               set kfound [lsearch -exact -index 3 $records test_mpos]
               if {$kfound>=0} {
                  set ind1 [lindex [lindex $records $kfound] 1]
                  set test_mpos [lindex $longs $ind1]
                  set bits [gcn_long2bits $test_mpos]
                  set bit30 [string index $bits 30] ;
                  lappend textlists "processed def_not_grb $bit30 \"bit\" \"0=No or 1=Yes, it is definitely not a GRB\""
                  set def_not_grb $bit30
                  set bit31 [string index $bits 31] ;
                  lappend textlists "processed test_mpos_test $bit31 \"bit\" \"0=No or 1=Yes, it is a Test_Notice\""
                  if {$bit31==1} {
                     set prompt INFOS
                  }
               }
            }
            if {$satellite=="SWIFT"} {
               set kfound [lsearch -exact -index 3 $records soln_status]
               if {$kfound>=0} {
                  set ind1 [lindex [lindex $records $kfound] 1]
                  set soln_status [lindex $longs $ind1]
                  set bits [gcn_long2bits $soln_status]
                  set bit5 [string index $bits 5] ;
                  lappend textlists "processed def_not_grb $bit5 \"bit\" \"0=No or 1=Yes, it is definitely not a GRB\""
                  set def_not_grb $bit5
                  if {$bit5==1} {
                     set prompt REFINED
                  }
               }
            }
            if {$satellite=="ANTARES"} {
               if {($val=="901")||($val=="903")} {
                  set bit 0
               } else {
                  set bit 1
               }
               lappend textlists "processed def_not_grb $bit \"bit\" \"0=No or 1=Yes, it is definitely not a neutrino\""
            }
            if {$satellite=="LOOCUP"} {
               if {($val=="905")||($val=="907")} {
                  set bit 0
               } else {
                  set bit 1
               }
               lappend textlists "processed def_not_grb $bit \"bit\" \"0=No or 1=Yes, it is definitely not a GW\""
            }
            lappend textlists "processed trigger_experiment $satellite \"text\" \"Name of the trigger experiment\""
            lappend textlists "processed position_type $prompt \"text\" \"INFOS, POINTDIR, PROMPT, REFINED\""
         }
         if {[lsearch -exact {integ_time} $name]>=0} { set namep integ_time ; set commentp "Duration of the trigger interval" }
         if {[lsearch -exact {burst_error} $name]>=0} { set valp [expr abs($valp)] ; set namep error ; set commentp "error box radius" }
         if {[lsearch -exact {point_ra burst_ra src_ra next_sc_ra} $name]>=0} { set namep ra ; set commentp "ra"
            set equinox J2000
            if {$satellite=="INTEGRAL"} { set equinox $date_rec_notice }
            lappend textlists "processed equinox $equinox \"Date\" \"Date of equinox for ra,dec\""
         }
         if {[lsearch -exact {point_dec burst_dec src_dec next_sc_dec} $name]>=0} { set namep dec ; set commentp "dec" }
         if {[lsearch -exact {point_roll} $name]>=0} { set namep roll ; set commentp "" }
         if {[lsearch -exact {obs_time slew_sod} $name]>=0} { set namep $name ; set commentp "" }
         if {[lsearch -exact {pkt_sod} $name]>=0} {
            set res [mc_date2ymdhms $date_rec_notice]
            set res [lrange $res 0 2]
            set pkt_date [mc_date2jd $res]
            set pkt_time [expr $val/100.]
            set pkt_jd [expr $pkt_date+$pkt_time/86400.] ; # jd de la notice
            if {[expr $pkt_jd-[mc_date2jd $date_rec_notice]]>0.5} {
               set pkt_jd [expr $pkt_jd-1.]
            }
            set namep $name
            set commentp ""
            lappend textlists "processed pkt_jd $pkt_jd \"Date\" \"Julian day of the packet\""
            lappend textlists "processed pkt_date [mc_date2iso8601 $pkt_jd] \"Date\" \"ISO 8601 date of the packet\""
         }
         if {[lsearch -exact {burst_tjd} $name]>=0} {
            set kfound [lsearch -exact -index 3 $records burst_sod]
            if {$kfound>=0} {
               set ind1 [lindex [lindex $records $kfound] 1]
               set burst_sod [lindex $longs $ind1]
               if {$satellite=="INTEGRAL"} {
                  set grb_date [expr $val-12640.+[mc_date2jd {2003 1 1}]]
               } else {
                  set grb_date [expr $val-13370.-1.+[mc_date2jd {2005 1 1}]] ; # TJD=13370 is 01 Jan 2005
               }
               set grb_time [expr $burst_sod/100.]
               set burst_jd [expr $grb_date+$grb_time/86400.] ; # jd du trigger
               if {$satellite=="SWIFT"} {
                  if {($burst_jd-$pkt_jd)>0.5} {
                     set $burst_jd [expr $burst_jd-1] ; # bug GCN du quart d'heure avant minuit
                  }
               }
               lappend textlists "processed burst_jd $burst_jd \"Date\" \"Origin Julian day of the trigger\""
               lappend textlists "processed burst_date [mc_date2iso8601 $burst_jd] \"Date\" \"ISO8601 Origin date of the trigger\""
            }
         }
         if {[lsearch -exact {trig_sub_num} $name]>=0} {
            set burst_trig  $val
            if {$satellite=="INTEGRAL"} {
               set trigger_subnum [expr int($burst_trig/pow(2,16))]
               set trigger_num [expr int($burst_trig-$trigger_subnum*pow(2,16))] ; # identificateur du trigger
               lappend textlists "processed trigger_num $trigger_num \"text\" \"Trigger number ID\""
               lappend textlists "processed trigger_subnum $trigger_subnum \"text\" \"Trigger subnumber ID\""
            }
         }
         if {[lsearch -exact {trig_obs_num} $name]>=0} {
            set trigger_num $val
            lappend textlists "processed trigger_num $trigger_num \"text\" \"Trigger number ID\""
         }
         if {[lsearch -exact {burst_mag} $name]>=0} {
            set namep burst_mag
            set valp [expr $val/100.]
            set commentp "UVOT magnitude"
            set unitp mag
         }
         if {[lsearch -exact {mag_error} $name]>=0} {
            set namep mag_error
            set valp [expr $val/100.]
            set commentp "UVOT magnitude error"
            set unitp mag
         }
         # ---
         if {$namep!=""} {
            lappend textlists "processed $namep $valp \"$unitp\" \"$commentp\""
         }
      } else {
         if {$number=="quad_char"} {
            set val [lrange $longs $indice1 $indice2]
            lappend textlists "raw $name \"$val\" $unit \"$comment\""
         }
      }
   }
   return $textlists
}

# ===================================
# ===================================
# ===================================

proc grb_help {} {
   grb_man
}

proc grb_man {} {
   ::console::affiche_resultat " \n"
   ::console::affiche_resultat " ======================================================\n"
   ::console::affiche_resultat " AudeLA Menu -> Configuration -> Repertoires -> Images\n"
   ::console::affiche_resultat " ======================================================\n"
   ::console::affiche_resultat " Vérifier que c'est un vrai GRB (This is a GRB)\n"
   ::console::affiche_resultat " Vérifier la présence d'un afterglow sur image somme\n"
   ::console::affiche_resultat " Vérifier la valeur de l'extinction interstellaire galactique.\n"
   ::console::affiche_resultat " Vérifier l'image traînée et la télécharger\n"
   ::console::affiche_resultat " Vérifier la présence d'un afterglow sur premières images et les télécharger\n"
   ::console::affiche_resultat " ======================================================\n"
   ::console::affiche_resultat " Renommer les images : grb_copy\n"
   ::console::affiche_resultat " Renommer les images : grb_sum ic\n"
   ::console::affiche_resultat " Renommer les images : grb_aladin ic\n"
   ::console::affiche_resultat " ======================================================\n"
   ::console::affiche_resultat " Etoile de reference NOMAD1: (V-R)=+0.4+(Av-Ar)\n"
   ::console::affiche_resultat " Mesurer les magnitudes avec Menu -> Analyse -> Ajuster une gaussienne\n"
   ::console::affiche_resultat " ======================================================\n"
}

proc grb_copy { {first 1} {date_trigger ""} {fov_arcmin ""} } {
   global audace

   set toto [info script]
   set path $audace(rep_images)
   ::console::affiche_resultat " \n"
   ::console::affiche_resultat " ======================================================\n"
   ::console::affiche_resultat " COPY IMAGES OF $path\n"
   ::console::affiche_resultat " ======================================================\n"
   if {$first=="?"} {
      ::console::affiche_resultat "Synatax : grb_copy ?first? ?date_trigger?\n"
      return
   }

   set methods ""
   lappend methods window

   set bufno $audace(bufNo)

   # --- Recherche l'instant du trigger
   set mjd0 2450000.
   if {$date_trigger==""} {
      set err [catch {
         set fichiers [lsort [glob ${path}/GRB*.txt]]
         set fichier [lindex $fichiers 0]
         set f [open $fichier r]
         set lignes [split [read $f] \n]
         close $f
         foreach ligne $lignes {
            set kwd [lindex $ligne 0]
            if {$kwd=="GRB_JD"} {
               set tgrb [lindex $ligne 1]
            }
         }
      } msg ]
      if {$err==1} {
         set tgrb 0
      }
   } else {
      set tgrb [mc_date2jd $date_trigger]
   }
   set jdgrb [mc_date2jd $tgrb]

   # --- recherche les images
   set fichiers [lsort [glob ${path}/*.fits.gz]]

   foreach method $methods {
      if {$method=="window"} {
         set first [expr $first-1]
         set fichier "[lindex $fichiers $first]"
         buf$bufno load "$fichier"
         set naxis1 [lindex [buf$bufno getkwd NAXIS1] 1]
         set naxis2 [lindex [buf$bufno getkwd NAXIS2] 1]
         set cdelt  [expr abs([lindex [buf$bufno getkwd CDELT1] 1])]
         if {$naxis1>1000} {
            set ra [lindex [buf$bufno getkwd RA] 1]
            set dec [lindex [buf$bufno getkwd DEC] 1]
            set xy [buf$bufno radec2xy [list $ra $dec]]
            #set xc [expr $naxis1/2]
            #set yc [expr $naxis2/2]
            set xc [lindex $xy 0]
            set yc [lindex $xy 1]
            set fen 300
            if {$fov_arcmin==""} {
               set fov 7.
            } else {
               set fov $fov_arcmin
            }
            set fen [expr int($fov/60./$cdelt)]
         } else {
            if {$fov_arcmin==""} {
               set fov 7.
            } else {
               set fov $fov_arcmin
            }
            set fen [expr int($fov/60./$cdelt)]
            set xc [expr $naxis1/2]
            set yc [expr $naxis2/2]
         }
         set x1 [expr int($xc-$fen)] ; if {$x1<1} {set x1 1}
         set y1 [expr int($yc-$fen)] ; if {$y1<1} {set y1 1}
         set x2 [expr int($xc+$fen)] ; if {$x2>$naxis1} {set x2 $naxis1}
         set y2 [expr int($yc+$fen)] ; if {$y2>$naxis2} {set y2 $naxis2}
         set box [list $x1 $y1 $x2 $y2]
         set n [llength $fichiers]
         set kkc 0
         set kkv 0
         set kkr 0
         set kki 0

         for {set k $first} {$k<$n} {incr k} {
            set fichier "[lindex $fichiers $k]"
            buf$bufno load "$fichier"
            #set ligne [buf$bufno getkwd CRPIX2]  ; set crpix [expr 0+[lindex $ligne 1]] ; set ligne [lreplace $ligne 1 1 $crpix] ; buf$bufno setkwd $ligne
            set exposure [lindex [buf$bufno getkwd EXPOSURE] 1]
            set nbstars [lindex [buf$bufno getkwd NBSTARS] 1]
            set date_obs [lindex [buf$bufno getkwd DATE-OBS] 1]
            set filter [string trim [lindex [buf$bufno getkwd FILTER] 1]]
            set tempccd [string trim [lindex [buf$bufno getkwd TEMPCCD] 1]]
            set trackspa [string trim [lindex [buf$bufno getkwd TRACKSPA] 1]]
            if {($tgrb==0)&&($k==$first)} {
               set tgrb $date_obs
               set jdgrb [mc_date2jd $tgrb]
            }
            set track ""
            if {$filter=="C"} {
               set series c
               # 0.0041781
               if {$trackspa<0.00417} {
                  set kkc 0
                  set track "(trailed image)"
               } else {
                  incr kkc
               }
               set kk $kkc
            } elseif {$filter=="V"} {
               set series v
               incr kkv
               set kk $kkv
            } elseif {$filter=="R"} {
               set series r
               incr kkr
               set kk $kkr
            } elseif {$filter=="I"} {
               set series i
               incr kki
               set kk $kki
            }
            #::console::affiche_resultat "[file tail $fichier] [expr 86400.*([mc_date2jd $date_obs]-$jdgrb)+$exposure/2] secs $date_obs $exposure $nbstars ${tempccd}°C\n"
            ::console::affiche_resultat "[file tail $fichier] [expr 1440.*([mc_date2jd $date_obs]-$jdgrb)+$exposure/2/60] mins $date_obs $exposure $nbstars ${tempccd}°C\n"
            #::console::affiche_resultat "[file tail $fichier] [expr 24.*([mc_date2jd $date_obs]-$jdgrb)+$exposure/2/3600.] hours $date_obs $exposure $nbstars ${tempccd}°C\n"
            buf$bufno window $box
            buf$bufno save ${path}/i${series}${kk}
            set naxis1 [lindex [buf$bufno getkwd NAXIS1] 1]
            #
            #set res [buf$bufno stat]
            #set fond [lindex $res 6]
            #set sigma [lindex $res 7]
            set res [buf$bufno autocuts]
            visu1 cut [lrange $res 0 1]
            #subsky 10 0.2
            visu1 disp
            buf$bufno save ${path}/i${series}${kk}
            ::console::affiche_resultat " => i${series}${kk} $track\n"
         }
      }
   }
   ::console::affiche_resultat " ======================================================\n"
}

proc grb_register { {name ic} {number 0} } {
   global audace

   set toto [info script]
   set path $audace(rep_images)
   ::console::affiche_resultat " \n"
   ::console::affiche_resultat " ======================================================\n"
   ::console::affiche_resultat " REGISTER IMAGES OF $path\n"
   ::console::affiche_resultat " ======================================================\n"
   if {$name=="?"} {
      ::console::affiche_resultat "Synatax : grb_register ?name? ?number?\n"
      return
   }

   set bufno $audace(bufNo)

   set n 1
   set sortie 0
   while {$sortie==0} {
      if {[file exists "$path/${name}$n.fit"]==0} {
         incr n -1
         set sortie 1
         break
      }
      incr n
   }
   if {($number>0)&&($number<$n)} {
      set n $number
   }
   ::console::affiche_resultat " $n images $name...\n"

   registerfine $name $name $n 1 10 1 bitpix=-32

   ::console::affiche_resultat " ======================================================\n"
}

proc grb_sum { {name ic} {first 1} {number 0} } {
   global audace

   set toto [info script]
   set path $audace(rep_images)
   ::console::affiche_resultat " \n"
   ::console::affiche_resultat " ======================================================\n"
   ::console::affiche_resultat " SUM IMAGES OF $path\n"
   ::console::affiche_resultat " ======================================================\n"
   if {$name=="?"} {
      ::console::affiche_resultat "Synatax : grb_sum ?name? ?first? ?number?\n"
      return
   }

   set bufno $audace(bufNo)

   set n $first
   set sortie 0
   while {$sortie==0} {
      if {[file exists "$path/${name}$n.fit"]==0} {
         incr n -1
         set sortie 1
         break
      }
      incr n
   }
   if {($number>0)&&($number<$n)} {
      set n $number
   }
   ::console::affiche_resultat " $n images $name...\n"

   sadd $name $name $n $first bitpix=-32

   ::console::affiche_resultat " ======================================================\n"
}

proc grb_aladin { {name ic} {catalogs "VizieR(NOMAD1)"} } {
   global audace

   set toto [info script]
   set path $audace(rep_images)
   ::console::affiche_resultat " \n"
   ::console::affiche_resultat " ======================================================\n"
   ::console::affiche_resultat " ALADIN OF $path\n"
   ::console::affiche_resultat " ======================================================\n"
   if {$name=="?"} {
      ::console::affiche_resultat "Synatax : grb_aladin ?name? ?catalogs?\n"
      return
   }

   set bufno $audace(bufNo)

   vo_aladin load $name $catalogs

   ::console::affiche_resultat " ======================================================\n"
}

