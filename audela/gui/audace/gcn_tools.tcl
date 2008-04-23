#
# Fichier : gcn_tools.tcl
# Description : These scripts allow to read informations from GRB Coordinate Network (GCN)
#               For more details, see http://gcn.gsfc.nasa.gov
#               The entry point is socket_server_open_gcn but you must contact GCN admin
#               to obtain a port number for a GCN connection.
# Mise a jour $Id: gcn_tools.tcl,v 1.3 2008-04-23 13:22:25 alainklotz Exp $
#

# ==========================================================================================
# socket_server_open_gcn : to open a named socket server for a GCN connection
# e.g. source audace/gcn_tools.tcl ; socket_server_open_gcn server1 5269 60000 "C:/Program Files/Apache Group/Apache2/htdocs/grb.txt"
#      source audace/socket_tools.tcl ; socket_client_open client1 localhost 60000 ; after 100 ; socket_client_put client1 z ; after 800 ; set res [socket_client_get client1] ; socket_client_close client1
#      source audace/socket_tools.tcl ; socket_server_open server1 60000
proc socket_server_open_gcn { name portgcn {portout 0} {index_html ""}} {
   global audace
   global gcn
   set gcn(index_html) $index_html
   set proc_accept socket_server_accept_gcn
   if {[info exists audace(socket,server,$name)]==1} {
      error "server $name already opened"
   }
   set errno [catch {
      set audace(socket,server,$name) [socket -server $proc_accept $portgcn]
   } msg]
   if {$errno==1} {
      error $msg
   }
   if {$portout!=0} {
      set name x$name
      set proc_accept socket_server_accept_out
      if {[info exists audace(socket,server,$name)]==1} {
         error "server $name already opened"
      }
      set errno [catch {
         set audace(socket,server,$name) [socket -server $proc_accept $portout]
      } msg]
      if {$errno==1} {
         error $msg
      }
   }
   if {$index_html!=""} {
      set errno [catch {
         set f [open $index_html r]
         set lignes [split [read $f] \n]
         close $f
         set n [llength $lignes]
         for {set k 1} {$k<[expr $n-1]} {incr k} {
            set ligne [lindex $lignes $k]
            set texte "set gcn(status,[lindex $ligne 0],[lindex $ligne 1],[lindex $ligne 2]) [lindex $ligne 3]"
            eval $texte
         }
      } msg]
      if {$errno==1} {
         gcn_print "Error: $msg"
      }
   }
}
# ==========================================================================================

# ==========================================================================================
# socket_server_accept_gcn : this is called by  the GCN socket server
proc socket_server_accept_gcn {fid ip port} {
   global audace
   fconfigure $fid -buffering full -translation binary -encoding binary -buffersize 160
   fileevent $fid readable [list socket_server_respons_gcn $fid]
}
# ==========================================================================================

# ==========================================================================================
# socket_server_respons_gcn : decode the GCN stream
proc socket_server_respons_gcn {fid} {
   global gcn
   set errsoc [ catch {
      if {[eof $fid] || [catch {set line [read $fid 160]}] } {
         close $fid
      } else {
         #::console::affiche_resultat "$fid received \"$line\"\n"
         # --- convert the binary stream into longs
         binary scan $line I* longs
         gcn_decode $longs
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
proc socket_server_accept_out {fid ip port} {
   global audace
   fconfigure $fid -buffering line
   fileevent $fid readable [list socket_server_respons_out $fid]
}
# ==========================================================================================

# ==========================================================================================
# socket_server_respons : this is the default proc_accept of a socket server
# Please use this proc as a canvas to write those dedicaded to your job.
proc socket_server_respons_out {fid} {
   global audace
   global gcn
   set errsoc [ catch {
      if {[eof $fid] || [catch {gets $fid line}]} {
         close $fid
      } else {
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
            if {[lindex $res 0]=="status"} {
               set res [lrange $res 1 end]
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

proc gcn_decode { longs } {
   global gcn
   global ros
   set errno [catch {
      # --- reinit gcn array
      set comments ""
      catch {
         set names [array names gcn]
         foreach name $names {
            if {([string first status $name]!=0)&&([string first index_html $name]!=0)} {
               set ligne "unset gcn($name)"
               eval $ligne
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
      set gcn(descr,type) [lindex $res 0]
      set gcn(descr,satellite) [lindex $res 1]
      set gcn(descr,prompt) [lindex $res 2]
      gcn_print "$date_rec_notice type $pkt_type: $gcn(descr,type)"
      gcn_print "$longs"
      # --- common codes
      for {set k 0} {$k<40} {incr k} {
         set gcn(long,$k) [string toupper [lindex $longs $k] ]
      }
      set items [gcn_pkt_indices]
      foreach item $items {
         set k [lindex $item 0]
         set name [lindex $item 1]
         set gcn(long,$name) $gcn(long,$k)
      }
      # --- date de l'envoi de la notice
      set res [mc_date2ymdhms $date_rec_notice]
      set res [lrange $res 0 2]
      set pkt_date [mc_date2jd $res]
      set pkt_time [expr $gcn(long,pkt_sod)/100.]
      set gcn(descr,jd_pkt) [expr $pkt_date+$pkt_time/86400.] ; # jd de la notice
      if {[expr $gcn(descr,jd_pkt)-[mc_date2jd $date_rec_notice]]>0.5} {
         set gcn(descr,jd_pkt) [expr $gcn(descr,jd_pkt)-1.]
      }
      # --- translations
      if {$gcn(descr,satellite)=="SWIFT"} {
         set gcn(descr,burst_ra) [expr $gcn(long,burst_ra)*0.0001]
         set gcn(descr,burst_dec) [expr $gcn(long,burst_dec)*0.0001]
         if {$gcn(descr,prompt)>0} {
            set gcn(descr,trigger_num) [expr int($gcn(long,burst_trig))] ; # identificateur du trigger
            set gcn(descr,grb_error) [expr 0.0001*$gcn(long,burst_error)*60.]; # boite d'erreur en arcmin
            set soln_status [gcn_long2bits $gcn(long,18)]
            set gcn(descr,soln_status) $soln_status
            set gcn(descr,point_src) [string index $soln_status 0]
            set gcn(descr,grb) [string index $soln_status 1]
            set gcn(descr,image_trig) [string index $soln_status 4]
            set gcn(descr,def_not_grb) [string index $soln_status 5]
         }
         set grb_date [expr $gcn(long,burst_tjd)-13370.-1.+[mc_date2jd {2005 1 1}]] ; # TJD=13370 is 01 Jan 2005
         set grb_time [expr $gcn(long,burst_sod)/100.]
         set gcn(descr,burst_jd) [expr $grb_date+$grb_time/86400.] ; # jd du trigger
      }
      if {$gcn(descr,satellite)=="INTEGRAL"} {
         set grb_date [expr $gcn(long,burst_tjd)-12640.+[mc_date2jd {2003 1 1}]]
         set grb_time [expr $gcn(long,burst_sod)/100.]
         set gcn(descr,grb_jd) [expr $grb_date+$grb_time/86400.] ; # jd0 du trigger
         if {($pkt_type==51)||($pkt_type==52)} {
            set ra [expr $gcn(long,14)*0.0001]
            set dec [expr $gcn(long,15)*0.0001]
         } else {
            set ra [expr $gcn(long,burst_ra)*0.0001]
            set dec [expr $gcn(long,burst_dec)*0.0001]
         }
         set radec [mc_precessradec [list $ra $dec] $gcn(descr,grb_jd) J2000.0]
         set gcn(descr,burst_ra) [lindex $radec 0]
         set gcn(descr,burst_dec) [lindex $radec 1]
         if {$gcn(descr,prompt)>0} {
            set trigger_subnum [expr int($gcn(long,burst_trig)/pow(2,16))]
            set gcn(descr,trigger_num) [expr int($gcn(long,burst_trig)-$trigger_subnum*pow(2,16))] ; # identificateur du trigger
            set gcn(descr,grb_error) [expr $gcn(long,burst_error)/60.]; # boite d'erreur en arcmin
            set test_mpos [gcn_long2bits $gcn(long,12)]
            set gcn(descr,test_mpos) $test_mpos
            if {($pkt_type==53)||($pkt_type==54)||($pkt_type==55)} {
               set gcn(descr,def_not_grb) [string index $test_mpos 30]
            }
            set gcn(descr,test) [string index $test_mpos 31]
            if {$gcn(descr,test)==1} {
               set gcn(descr,prompt) -1
            }
         }
      }
      if {$gcn(descr,satellite)=="GLAST"} {
         set gcn(descr,burst_ra) [expr $gcn(long,burst_ra)*0.0001]
         set gcn(descr,burst_dec) [expr $gcn(long,burst_dec)*0.0001]
         if {$gcn(descr,prompt)>0} {
            set gcn(descr,trigger_num) [expr int($gcn(long,burst_trig))] ; # identificateur du trigger
            set gcn(descr,grb_error) [expr 0.0001*$gcn(long,burst_error)*60.]; # boite d'erreur en arcmin
            set soln_status [gcn_long2bits $gcn(long,18)]
            set gcn(descr,soln_status) $soln_status
            set gcn(descr,point_src) [string index $soln_status 0]
            set gcn(descr,grb) [string index $soln_status 1]
            set gcn(descr,image_trig) [string index $soln_status 4]
            set gcn(descr,def_not_grb) [string index $soln_status 5]
         }
         set grb_date [expr $gcn(long,burst_tjd)-13370.-1.+[mc_date2jd {2005 1 1}]] ; # TJD=13370 is 01 Jan 2005
         set grb_time [expr $gcn(long,burst_sod)/100.]
         set gcn(descr,burst_jd) [expr $grb_date+$grb_time/86400.] ; # jd du trigger
      }
      if {$gcn(descr,satellite)=="MILAGRO"} {
         set gcn(descr,burst_ra) [expr $gcn(long,burst_ra)*0.0001]
         set gcn(descr,burst_dec) [expr $gcn(long,burst_dec)*0.0001]
         set gcn(descr,trigger_num) [expr int($gcn(long,4))] ; # identificateur du trigger
         set grb_date [expr $gcn(long,burst_tjd)-12640.-1.+[mc_date2jd {2003 1 1}]] ; # TJD=12640 is 01 Jan 2003
         set grb_time [expr $gcn(long,burst_sod)/100.]
         set gcn(descr,burst_jd) [expr $grb_date+$grb_time/86400.] ; # jd du trigger
         set gcn(descr,grb_error) [expr 0.0001*$gcn(long,burst_error)*60.]; # boite d'erreur en arcmin
         set gcn(descr,burst_sig) $gcn(long,9)
         set gcn(descr,bkg) [expr 0.0001*$gcn(long,10)]
         set gcn(descr,duration) [expr $gcn(long,13)/100.]
         set trigger_id [gcn_long2bits $gcn(long,18)]
         set gcn(descr,trigger_id) $trigger_id
         set gcn(descr,possible_grb) [string index $trigger_id 0]
         set gcn(descr,definite_grb) [string index $trigger_id 1]
         set gcn(descr,def_not_grb) [string index $trigger_id 15]
      }
      if {$gcn(descr,satellite)=="SNEWS"} {
         set gcn(descr,burst_ra) [expr $gcn(long,burst_ra)*0.0001]
         set gcn(descr,burst_dec) [expr $gcn(long,burst_dec)*0.0001]
         set gcn(descr,trigger_num) [expr int($gcn(long,4))] ; # identificateur du trigger
         set grb_date [expr $gcn(long,burst_tjd)-12640.-1.+[mc_date2jd {2003 1 1}]] ; # TJD=12640 is 01 Jan 2003
         set grb_time [expr $gcn(long,burst_sod)/100.]
         set gcn(descr,burst_jd) [expr $grb_date+$grb_time/86400.] ; # jd du trigger
         set gcn(descr,grb_error) [expr 0.0001*$gcn(long,burst_error)*60.]; # boite d'erreur en arcmin
         set gcn(descr,burst_sig) $gcn(long,9)
         set gcn(descr,duration) [expr $gcn(long,13)/100.]
         set trig_id [gcn_long2bits $gcn(long,18)]
         set gcn(descr,trig_id) $trig_id
         set gcn(descr,Subtype) [string index $trig_id 0]
         set gcn(descr,test_flag) [string index $trig_id 1]
         set gcn(descr,radec_undef) [string index $trig_id 2]
         set gcn(descr,retract) [string index $trig_id 5]
      }
      # --- update status
      set gcn(status,last,last,jd_send) "$gcn(descr,jd_pkt)"
      set gcn(status,last,last,jd_received) "[mc_date2jd $date_rec_notice]"
      set gcn(status,last,last,type) $gcn(descr,type)
      set gcn(status,last,last,prompt) $gcn(descr,prompt)
      set gcn(status,last,last,satellite) $gcn(descr,satellite)
      if {$gcn(descr,prompt)>=0} {
         set gcn(status,$gcn(descr,prompt),$gcn(descr,satellite),jd_send) $gcn(status,last,last,jd_send)
         set gcn(status,$gcn(descr,prompt),$gcn(descr,satellite),jd_received) $gcn(status,last,last,jd_received)
         set gcn(status,$gcn(descr,prompt),$gcn(descr,satellite),type) $gcn(status,last,last,type)
         set names [array names gcn]
         foreach name $names {
            set res [regsub -all , $name " "]
            if {([lindex $res 0]=="descr")} {
               set re [lindex $res 1]
               if {($re=="type")||($re=="prompt")||($re=="satellite")} {
                  continue
               }
               set gcn(status,$gcn(descr,prompt),$gcn(descr,satellite),$re) $gcn($name)
            }
         }
      }
      set lignes ""
      set names [lsort [array names gcn]]
      foreach name $names {
         set res [regsub -all , $name " "]
         if {[lindex $res 0]=="status"} {
            set res [lrange $res 1 end]
            append lignes "$res $gcn($name)\n"
         }
      }
      gcn_print "$lignes"
      if {[info exist gcn(index_html)]==1} {
         catch {
            set f [open $gcn(index_html) w]
            puts -nonewline $f "[mc_date2iso8601 $date_rec_notice]\n$lignes"
            close $f
         }
      }
      # --- use by ROS
      catch { source $ros(root,ros)/src/majordome/gcn.tcl }
      # --- infos
      set items [array names gcn]
      set comments ""
      append comments " ---------------\n"
      foreach item $items {
         set ident [regsub -all , "$item" " "]
         if {[lindex $ident 0]=="descr"} {
            set name [lindex $ident 1]
            append comments " gcn(descr,$name) = $gcn(descr,$name)\n"
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
      set f [open c:/d/a/toto.txt a]
      puts -nonewline $f "[mc_date2iso8601 $date_rec_notice] : $longs \n$comments"
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
      1       BATSE_ORIGINAL    NO LONGER AVAILABLE
      2       Test
      3       Imalive
      4       Kill
     11       BATSE_MAXBC       NO LONGER AVAILABLE
     21       Bradford_TEST     NO LONGER AVAILABLE
     22       BATSE_FINAL       NO LONGER AVAILABLE
     24       BATSE_LOCBURST    NO LONGER AVAILABLE
     25       ALEXIS
     26       RXTE-PCA_ALERT
     27       RXTE-PCA
     28       RXTE-ASM_ALERT
     29       RXTE-ASM
     30       COMPTEL           NO LONGER AVAILABLE
     31       IPN_RAW           NOT IMPLEMENTED
     32       IPN_SEGMENT       NO LONGER AVAILABLE
     33       SAX-WFC_ALERT     NOT AVAILABLE
     34       SAX-WFC           NO LONGER AVAILABLE
     35       SAX-NFI_ALERT     NOT AVAILABLE
     36       SAX-NFI           NO LONGER AVAILABLE
     37       RXTE-ASM_XTRANS
     38       spare/unused
     39       IPN_POSITION
     40       HETE_S/C_ALERT
     41       HETE_S/C_UPDATE
     42       HETE_S/C_LAST
     43       HETE_GNDANA
     44       HETE_Test
     45       GRB_COUNTERPART
     51       INTEGRAL_POINTDIR
     52       INTEGRAL_SPIACS
     53       INTEGRAL_WAKEUP
     54       INTEGRAL_REFINED
     55       INTEGRAL_OFFLINE
     57       SNEWS                            NOT YET AVAILABLE
     58       MILAGRO
     59       KONUS_LIGHTCURVE
     60       SWIFT_BAT_GRB_ALERT
     61       SWIFT_BAT_GRB_POSITION
     62       SWIFT_BAT_GRB_NACK_POSITION
     63       SWIFT_BAT_GRB_LIGHTCURVE
     64       SWIFT_BAT_SCALED_MAP             NOT AVAILABLE
     65       SWIFT_FOM_OBSERVE
     66       SWIFT_SC_SLEW
     67       SWIFT_XRT_POSITION
     68       SWIFT_XRT_SPECTRUM
     69       SWIFT_XRT_IMAGE
     70       SWIFT_XRT_LIGHTCURVE
     71       SWIFT_XRT_NACK_POSITION
     72       SWIFT_UVOT_IMAGE
     73       SWIFT_UVOT_SRC_LIST
     74       SWIFT_FULL_DATA_INIT             NOT YET AVAILABLE
     75       SWIFT_FULL_DATA_UPDATE           NOT YET AVAILABLE
     76       SWIFT_BAT_GRB_PROC_LIGHTCURVE    NOT YET AVAILABLE
     77       SWIFT_XRT_PROC_SPECTRUM
     78       SWIFT_XRT_PROC_IMAGE
     79       SWIFT_UVOT_PROC_IMAGE
     80       SWIFT_UVOT_PROC_SRC_LIST
     81       SWIFT_UVOT_POSITION
     82       SWIFT_BAT_GRB_POS_TEST
     83       SWIFT_POINTDIR
     84       SWIFT_BAT_TRANS
     85       SWIFT_XRT_THRESHPIX              NOT AVAILABLE
     86       SWIFT_XRT_THRESHPIX_PROC         NOT AVAILABLE
     87       SWIFT_XRT_SPER                   NOT AVAILABLE
     88       SWIFT_XRT_SPER_PROC              NOT AVAILABLE
     89       SWIFT_UVOT_NACK_POSITION
     110      GLAST_GBM_GRB_ALERT              NOT YET AVAILABLE
     111      GLAST_GBM_GRB_POS_ACK            NOT YET AVAILABLE
     112      GLAST_GBM_LC                     NOT YET AVAILABLE
     118      GLAST_GBM_TRANS                  NOT YET AVAILABLE
     119      GLAST_GBM_GRB_POS_TEST           NOT YET AVAILABLE
     120      GLAST_LAT_GRB_POS_INI            NOT YET AVAILABLE
     121      GLAST_LAT_GRB_POS_UPD            NOT YET AVAILABLE
     122      GLAST_LAT_GRB_POS_FIN            NOT YET AVAILABLE
     123      GLAST_LAT_TRANS                  NOT YET AVAILABLE
     125      GLAST_OBS_REQUEST                NOT YET AVAILABLE
     126      GLAST_SC_SLEW                    NOT YET AVAILABLE
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
   if {($pkt_type>=110)&&($pkt_type<=126)} {
      set satellite GLAST
   }
   lappend textes $satellite
   # --- prompt identification
   # =-1 informations only, =0 pointdir, =1 prompt, =2 refined
   set prompt -1
   if {($pkt_type==126)||($pkt_type==83)||($pkt_type==51)} {
      set prompt 0
   }
   if {($pkt_type==110)||($pkt_type==111)||($pkt_type==61)||($pkt_type==58)||($pkt_type==53)||($pkt_type==40)||($pkt_type==33)||($pkt_type==35)||($pkt_type==30)||($pkt_type==26)||($pkt_type==28)||($pkt_type==1)} {
      set prompt 1
   }
   if {($pkt_type==67)||($pkt_type==54)||($pkt_type==55)||($pkt_type==41)||($pkt_type==42)||($pkt_type==43)||($pkt_type==39)} {
      set prompt 2
   }
   lappend textes $prompt
   return $textes
}

