#
# Robotic Observatory Control
# Mise à jour $Id: ros.tcl,v 1.9 2011-02-18 01:39:04 fredvachier Exp $
#
puts "--------------------------------"
puts "- Robotic Observatory Software -"
puts "-       primaries logs"
puts "--------------------------------"

#--- Add audela/lib directory to ::auto_path if it doesn't already exist
set audelaLibPath [file join [file join [file dirname [file dirname [info nameofexecutable]] ] lib]]
puts "audelaLibPath=$audelaLibPath"

if { [lsearch $::auto_path $audelaLibPath] == -1 } {
   lappend ::auto_path $audelaLibPath
}
puts "::auto_path=$::auto_path"

set err [catch {wm withdraw .} msg]
set ros(withtk) 1
if {$err==1} {
   set ros(withtk) 0
   puts "TK: Non actif"
} else {
   puts "TK: Actif"
}

set name [file tail [file rootname [info nameofexecutable]]]
puts "Prog=$name"
set k [string first _ "$name"]
if {$k>0} {
   set k [expr $k-1]
} else {
   set k end
}
set name [string range $name 0 $k]
puts "name=$name"


set ros(ros_install,audelabin) $::audela_start_dir
puts "audelabin=$ros(ros_install,audelabin)"
cd $ros(ros_install,audelabin)

if {$name=="audela"} {
   puts "log= Demarrage de l install automatique"
   puts "pwd= [pwd]"
   puts "Lancement= source [file join $::audela_start_dir ros_install.tcl]"
   set errno [catch {source [file join $::audela_start_dir ros_install.tcl]} msg]
} else {
   puts "log= Demarrage du programme"
   # programme ros en mode console
   cd ../ros/src/$name
   set errno [catch {source $name.tcl} msg]
}

puts "errno=$errno"
puts "msg=$msg"
if {$errno==1} {
   puts "log= Erreur grave"
   # se met dans ros
   cd ../..
   set f [open ros_check_error.txt a]
   puts $f "==============================\n[mc_date2iso8601 now] :"
   puts $f $msg
   close $f
   if {$ros(withtk)==1} {
      tk_messageBox -icon error -message $msg
   } else {
      puts "error : $msg"
   }
}
if {$ros(withtk)==1} {
   #exit
}

