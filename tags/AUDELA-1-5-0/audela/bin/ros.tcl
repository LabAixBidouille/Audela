# Robotic Observatory Control
set err [catch {wm withdraw .} msg]
set ros(withtk) 1
if {$err==1} {
	set ros(withtk) 0
}
set name [file tail [file rootname [info nameofexecutable]]]
set k [string first _ "$name"]
if {$k>0} {
	set k [expr $k-1]
} else {
	set k end
}
set name [string range $name 0 $k]
set ros(ros_install,audelabin) [pwd]
if {$name=="audela"} {
	cd ../ros
	set errno [catch {source ros_install.tcl} msg]
} else {
	cd ../ros/src/$name
	set errno [catch {source $name.tcl} msg]
}
puts "errno=$errno"
if {$errno==1} {
	cd ../..
	set f [open check_error.txt a]
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
	exit
}
