#!/usr/bin/tclsh
#lappend auto_path /datacentre/audela/lib
#lappend auto_path /opt/tcl/lib

#package require SOAP

#namespace import -force rpcvar::typedef
#namespace import rpcvar::typedef
package require Tclx

namespace eval Samp {

 package require SOAP
 package require XMLRPC
 package require rpcvar
 namespace import ::rpcvar::typedef

 typedef {
  samp.name string
  samp.description.text string
  dummy.version string
 } declareMetadataStruct

 typedef { } emptymap

 typedef {
  samp.hup.event.shutdown struct
  samp.hup.event.unregister struct
  samp.app.ping struct
  image.load.fits struct
  table.load.votable struct
  table.highlight.row struct
  coord.pointAt.sky struct
  table.select.rowList struct
 } declareSubscriptions

 typedef {
  name string
  image-id string
  url string
 } imageLoadFits

 typedef {
  samp.mtype string
  samp.params imageLoadFits
 } imageLoadFitsWrapper

}

proc ::Samp::build { nsp } {

 namespace eval $nsp {
   variable params
   variable key
 }

 set path [file join $::env(HOME) ".samp"]
 if { ! ([file exists $path] && [file isfile $path]) } { return 0 }
 set chan [open $path]
 while {[gets $chan line] >= 0} {
  if {[string first "#" $line] >= 0} { continue }
  set l [split $line "="]
  puts $l
  set ${nsp}::params([lindex $l 0]) [lindex $l 1]
 }
 close $chan

 XMLRPC::create ${nsp}::m_register \
            -uri [set ${nsp}:::params(samp.hub.xmlrpc.url)] \
            -proxy [set ${nsp}::params(samp.hub.xmlrpc.url)] \
            -params { arg string } \
            -name "samp.hub.register"

 XMLRPC::create ${nsp}::m_unregister \
            -uri [set ${nsp}::params(samp.hub.xmlrpc.url)] \
            -proxy [set ${nsp}::params(samp.hub.xmlrpc.url)] \
            -params { arg string } \
            -name "samp.hub.unregister"

 XMLRPC::create ${nsp}::m_declare \
            -uri [set ${nsp}::params(samp.hub.xmlrpc.url)] \
            -proxy [set ${nsp}::params(samp.hub.xmlrpc.url)] \
            -params { arg1 string arg2 declareMetadataStruct } \
            -name "samp.hub.declareMetadata"

 XMLRPC::create ${nsp}::m_setXmlrpcCallback \
            -uri [set ${nsp}::params(samp.hub.xmlrpc.url)] \
            -proxy [set ${nsp}::params(samp.hub.xmlrpc.url)] \
            -params { arg1 string arg2 string } \
            -name "samp.hub.setXmlrpcCallback"

 XMLRPC::create ${nsp}::m_declareSubscriptions \
            -uri [set ${nsp}::params(samp.hub.xmlrpc.url)] \
            -proxy [set ${nsp}::params(samp.hub.xmlrpc.url)] \
            -params { arg1 string arg2 declareSubscriptions } \
            -name "samp.hub.declareSubscriptions"

 XMLRPC::create ${nsp}::m_imageLoadFits \
            -uri [set ${nsp}::params(samp.hub.xmlrpc.url)] \
            -proxy [set ${nsp}::params(samp.hub.xmlrpc.url)] \
            -params { arg1 string arg2 imageLoadFitsWrapper } \
            -name "samp.hub.notifyAll"


 proc ${nsp}::register {} {
  variable params
  variable key
  set msg [ m_register [set params(samp.secret)] ]
  puts $msg
  array set iparams $msg
  set key $iparams(samp.private-key)
  puts "key: $key"
  m_declare $key { samp.name audela-vo samp.description.text audela_vo dummy.version 0.1 }
 }

 proc ${nsp}::chanreadheader {chan} {
  variable buf
  variable datalen
  variable state
  if { ! [eof $chan] } {
   set line [gets $chan]
 #  puts "HEADER: $line"
   if { $line eq ""} {
 #   puts emptyline
    fileevent $chan readable [list [namespace current]::chanread $chan]
    puts $chan "HTTP/1.1 200 OK\r\n\r"
    return
   }
 #  puts "HEADER: $line"
   if {[regexp -nocase {^content-length:\s*(\d+)\s*$} $line allmatch len]} {
 #   puts "LENGTH $len"
    set datalen($chan) $len
   }
  } else {
   puts "== EOF ON CHANNEL $chan"
  }
 }


 proc ${nsp}::chanread {chan} {
  variable buf
  variable datalen
  variable state
 # puts "#CHANREAD"
  if { ! [eof $chan] } {
   set line [gets $chan]
   set buf($chan) "$buf($chan)\n$line"
   set datalen($chan) [expr $datalen($chan) - [string length $line] - 1]
 #  puts $::chan::datalen($chan)
 #  puts "$chan: $line"
  if {$datalen($chan) == 0} {
 puts $buf($chan)
   set resp [::SOAP::parse_xmlrpc_request $buf($chan)]
 #  puts "\nRESPONSE\n"
 #  puts $resp
   set buf($chan) ""
   set state($chan) 0
   set datalen($chan) 0
 #  fileevent $chan readable [list chanreadheader $chan]
   fileevent $chan readable {}
   close $chan
   handler $resp
  } elseif {$datalen($chan) < 0 } {
   puts "INVALID LEN ON $chan"
  }
  } else {
   puts "== EOF ON CHANNEL $chan"
  }
 }

 proc ${nsp}::handler {msg} {
  variable key
  set evt [lindex $msg 0]
  set a [lindex $msg 1]
  set k [lindex $a 0]
  if { ! ($k eq $key) } {
   puts "Ignoring event : bad key"
   return 0
  }
  set hub [lindex $a 1]
  set b [lindex $a 2]
  array set p [lindex $a 2]
  puts "handler: $msg"
  puts "msg: $p(samp.mtype)"
  set hndlr h_$p(samp.mtype)
  if {[info proc $hndlr] eq $hndlr} {
   $hndlr $p(samp.params)
  }
 }

 proc ${nsp}::Server {channel clientaddr clientport} {
  variable buf
  variable datalen
  variable state
  puts "Connection from $clientaddr registered channel $channel"
  fconfigure $channel -blocking 0 -buffering line
  namespace eval ::chan { }
  set buf($channel) ""
  set state($channel) 0
  set datalen($channel) 0
  fileevent $channel readable [list [namespace current]::chanreadheader $channel]
 #   puts $channel [clock format [clock seconds]]
 #   fconfigure $channel -blocking 0 -buffering line
   #close $channel
 }

 proc ${nsp}::unregister {} {
  variable key
  m_unregister $key
 }

 proc ${nsp}::h_coord.pointAt.sky {args} {
  puts "proc coord.pointAt.sky $args"
 }

 proc ${nsp}::h_image.load.fits {args} {
  puts "proc image.load.fits $args"
  array set p [lindex $args 0]
  set url $p(image-id)
  if {[regexp {^file:(.*)} $url allmatch path]} {
   puts "path= $path"
   if {[ file exists $path]} {
    puts "file exists"
    loadima $path
   }
  }
 }

 namespace eval $nsp {
 variable key
 register
 set sockserver [socket -server [namespace current]::Server 0]
 set port [ lindex [fconfigure $sockserver -sockname] 2 ]
 puts "port for callback = $port"

 set msg [m_setXmlrpcCallback $key "http://benoite.imcce.fr:$port/"]
 puts $msg

 set msg [m_declareSubscriptions $key { samp.hup.event.shutdown {} samp.hup.event.unregister {} samp.app.ping {} image.load.fits {} table.load.votable {} table.highlight.row {} coord.pointAt.sky {} table.select.rowList {}}]
 puts $msg


# set msg [m_imageLoadFits $key { samp.mtype image.load.fits samp.params {name ABC "image-id" ABC url file:/astrodata/bddimages/fits/tarot_calern/2008/01/07/IM_20080107_004103161_080107_00211100.fits.gz} }]
# puts "load: $msg"
 }

 return 1
}


###########################################################################

#proc mysig {} {
# global forever
# set forever 0
#}

if { ! [::Samp::build ::samp] } {
 puts "error building ::samp"
# exit 1
}

#signal trap SIGINT mysig
#vwait forever
#::samp::unregister

