#
# Fichier : vo_samp.tcl
# Description : SAMP protocol functions
# Auteur : Stephane VAILLANT
# Mise a jour $Id: vo_samp.tcl,v 1.4 2009-10-23 12:52:35 svaillant Exp $
#


namespace eval Samp {

 package require SOAP
 package require XMLRPC
 package require rpcvar
 namespace import ::rpcvar::typedef
 #namespace import -force rpcvar::typedef

 typedef {
  samp.name string
  samp.description.text string
  dummy.version string
 } declareMetadataStruct

 typedef { } emptymap

 typedef {
  samp.hub.event.shutdown struct
  samp.hub.event.unregister struct
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

###########################################################################

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
  array set iparams $msg
  set key $iparams(samp.private-key)
  m_declare $key { samp.name audela-vo samp.description.text audela_vo dummy.version 0.1 }
 }

 proc ${nsp}::chanreadheader {chan} {
  variable buf
  variable datalen
  variable state
  if { ! [eof $chan] } {
   set line [gets $chan]
   if { $line eq ""} {
    fileevent $chan readable [list [namespace current]::chanread $chan]
    puts $chan "HTTP/1.1 200 OK\r\n\r"
    return
   }
   if {[regexp -nocase {^content-length:\s*(\d+)\s*$} $line allmatch len]} {
    set datalen($chan) $len
   }
  } else {
  }
 }


 proc ${nsp}::chanread {chan} {
  variable buf
  variable datalen
  variable state
  if { ! [eof $chan] } {
   set line [gets $chan]
   set buf($chan) "$buf($chan)\n$line"
   set datalen($chan) [expr $datalen($chan) - [string length $line] - 1]
  if {$datalen($chan) == 0} {
   set resp [::SOAP::parse_xmlrpc_request $buf($chan)]
   set buf($chan) ""
   set state($chan) 0
   set datalen($chan) 0
   #fileevent $chan readable [list chanreadheader $chan]
   fileevent $chan readable {}
   close $chan
   handler $resp
  } elseif {$datalen($chan) < 0 } {
  }
  } else {
  }
 }

 proc ${nsp}::handler {msg} {
  variable key
  set evt [lindex $msg 0]
  set a [lindex $msg 1]
  set k [lindex $a 0]
  if { ! ($k eq $key) } {
   return 0
  }
  set hub [lindex $a 1]
  set b [lindex $a 2]
  array set p [lindex $a 2]
  set hndlr h_$p(samp.mtype)
  if {[info proc $hndlr] eq $hndlr} {
   $hndlr $p(samp.params)
  }
 }

 proc ${nsp}::Server {channel clientaddr clientport} {
  variable buf
  variable datalen
  variable state
  fconfigure $channel -blocking 0 -buffering line
  namespace eval ::chan { }
  set buf($channel) ""
  set state($channel) 0
  set datalen($channel) 0
  fileevent $channel readable [list [namespace current]::chanreadheader $channel]
  #puts $channel [clock format [clock seconds]]
  #fconfigure $channel -blocking 0 -buffering line
  #close $channel
 }

 proc ${nsp}::unregister {} {
  variable key
  m_unregister $key
 }

 proc ${nsp}::h_coord.pointAt.sky {args} {
  ::console::disp "#vo_tools::samp received event coord.pointAt.sky $args\n"
 }

 proc ${nsp}::h_image.load.fits {args} {
  #::console::disp "::vo_tools::samp $args"
  array set p [lindex $args 0]
  set url $p(url)
  set imageid $p(image-id)
  set paths {}

  foreach param [list $url $imageid] {
  if {[regexp {^file:/*(/.*)} $param allmatch path]} {
   lappend paths $path
  }
  if {[regexp {^file:/*[^/]+(/.*)} $param allmatch path]} {
   lappend paths $path
  }
  if {[regexp {sampfile:(/.*)} $param allmatch path]} {
   lappend paths $path
  }
  }

  foreach path $paths {
   if {[ file exists $path]} {
    ::console::disp "#vo_tools::samp received image.load.fits event : $path\n"
    loadima $path
     break
   }
  }

 }

 proc ${nsp}::h_samp.hub.event.shutdown {args} {
   set [namespace current]::initialized 0
   close [ set "[namespace current]::sockserver" ]
   ::console::disp "#vo_tools::samp received samp.hub.event.shutdown\n"
 }



 namespace eval $nsp {
  variable key
  variable port sockserver msg initialized
  register
  set sockserver [socket -server [namespace current]::Server 0]
  set port [ lindex [fconfigure $sockserver -sockname] 2 ]
  ::console::disp "#vo_tools::samp TCP port for callback = $port\n"

  set msg [m_setXmlrpcCallback $key "http://127.0.0.1:$port/"]

  set msg [m_declareSubscriptions $key { samp.hub.event.shutdown {} samp.hub.event.unregister {} samp.app.ping {} image.load.fits {} table.load.votable {} table.highlight.row {} coord.pointAt.sky {} table.select.rowList {}}]

  set initialized 1
 }

 return 1
}


###########################################################################

proc ::Samp::check { } {
 if { [info exists ::samp::initialized] && [expr $::samp::initialized == 1]} {
  return 1
 }
 if { ! [::Samp::build ::samp] } {
  #::console::disp "#vo_tools::samp hub not found\n"
  return 0
 }
 return 1
}

###########################################################################

proc ::Samp::destroy { } {
 if { [info exists ::samp::initialized] && [expr $::samp::initialized == 1] } {
   if { [catch { ::samp::unregister } result ] } {
     ::console::disp "#vo_tools::samp destroy error\n"
   } else {
     set ::samp::initialized 0
     close $::samp::sockserver
     ::console::disp "#vo_tools::samp disconnected from hub\n"
   }
 } else {
   ::console::disp "#vo_tools::samp already disconnected\n"
 }
}

