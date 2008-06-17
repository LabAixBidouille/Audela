
package require Tcl 8.3
package require Tk 8.3
#package require Tk 8.3

# to auto load from GiD
catch {
    auto_load msgcat:mc
    msgcat::mc ""
}
package require msgcat
#package require supergrid
package require snit

namespace eval ::dialogwinmsgs {
    ::msgcat::mcload [file join [file dirname [info script]] msgs]

}

if { [info command _] eq "" } {
    proc _ { args } {
	if { [regexp {(.*)\#C\#(.*)} [lindex $args 0] {} str comm] } {
	    set args [lreplace $args 0 0 $str]
	}
	return [uplevel 1 ::msgcat::mc $args]
    }
}

if { [info command tkTabToWindow] == "" } {
    interp alias "" tkTabToWindow "" tk::TabToWindow
    #::tk::unsupported::ExposePrivateCommand tkTabToWindow
}
if { [info command tkButtonInvoke] == "" } {
    interp alias "" tkButtonInvoke "" tk::ButtonInvoke
    #::tk::unsupported::ExposePrivateCommand tkButtonInvoke
}

package provide dialogwin 1.1

################################################################################
#  This software is copyrighted by Ramon Ribó (RAMSAN) ramsan@cimne.upc.es.
#  (http://gid.cimne.upc.es/ramsan) The following terms apply to all files 
#  associated with the software unless explicitly disclaimed in individual files.

#  The authors hereby grant permission to use, copy, modify, distribute,
#  and license this software and its documentation for any purpose, provided
#  that existing copyright notices are retained in all copies and that this
#  notice is included verbatim in any distributions. No written agreement,
#  license, or royalty fee is required for any of the authorized uses.
#  Modifications to this software may be copyrighted by their authors
#  and need not follow the licensing terms described here, provided that
#  the new terms are clearly indicated on the first page of each file where
#  they apply.

#  IN NO EVENT SHALL THE AUTHORS OR DISTRIBUTORS BE LIABLE TO ANY PARTY
#  FOR DIRECT, INDIRECT, SPECIAL, INCIDENTAL, OR CONSEQUENTIAL DAMAGES
#  ARISING OUT OF THE USE OF THIS SOFTWARE, ITS DOCUMENTATION, OR ANY
#  DERIVATIVES THEREOF, EVEN IF THE AUTHORS HAVE BEEN ADVISED OF THE
#  POSSIBILITY OF SUCH DAMAGE.

#  THE AUTHORS AND DISTRIBUTORS SPECIFICALLY DISCLAIM ANY WARRANTIES,
#  INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY,
#  FITNESS FOR A PARTICULAR PURPOSE, AND NON-INFRINGEMENT.  THIS SOFTWARE
#  IS PROVIDED ON AN "AS IS" BASIS, AND THE AUTHORS AND DISTRIBUTORS HAVE
#  NO OBLIGATION TO PROVIDE MAINTENANCE, SUPPORT, UPDATES, ENHANCEMENTS, OR
#  MODIFICATIONS.
################################################################################

proc CCGetRGB { w color} {
    set ret $color
    set n [ scan $color \#%2x%2x%2x r g b]
    if { $n != 3} {
	set rgb [ winfo rgb $w $color]
	set r [ expr int( 0.5 + [ lindex $rgb 0]/256.0)]
	set g [ expr int( 0.5 + [ lindex $rgb 1]/256.0)]
	set b [ expr int( 0.5 + [ lindex $rgb 2]/256.0)]
	set ret [ format \#%2x%2x%2x $r $g $b]
    }
    return $ret
}

proc CCColorActivo { color_usuario { factor 17} } {
    set ret ""
    set color_nuevo [ CCGetRGB . $color_usuario]
    set n [ scan $color_nuevo \#%2x%2x%2x r g b]
    if { $n == 3} {
	set r [ expr $r + $factor]
	if { $r > 255} { set r 255}
	set g [ expr $g + $factor]
	if { $g > 255} { set g 255}
	set b [ expr $b + $factor]
	if { $b > 255} { set b 255}
	set ret [ format \#%2x%2x%2x $r $g $b]
    }
    return $ret
}


namespace eval DialogWin {
    variable w
    variable action
    variable user
    variable oldGrab
    variable grabStatus
    variable grab
}

#current styles are: 
#        ridgeframe
#        separator
#
proc DialogWin::Init { winparent title style { morebuttons "" } { OKname "" } { Cancelname "" } } {
    variable action
    variable w
    variable grab

    set grab 1
    if { [string match *nograb $style] } { set grab 0 }

    if { $winparent == "." } { set winparent "" }
    set w $winparent.__dialogwin

    catch { destroy $w }

#     set i 0
#     while { [winfo exists $w] } {
#         incr i
#         set w $winparent.__dialogwin$i
#     }
    toplevel $w
    wm title $w $title
    wm withdraw $w

    switch $style {
	ridgeframe {
	    frame $w.f -relief ridge -bd 2
	    frame $w.buts
	    grid $w.f -sticky ewns -padx 2 -pady 2
	    grid $w.buts -sticky ew

	}
	separator - separator_nograb {
	    frame $w.f -bd 0
	    frame $w.sep -bd 2 -relief raised -height 2
	    frame $w.buts
	    grid $w.f -sticky ewns -padx 2 -pady 2
	    grid $w.sep -sticky ew
	    grid $w.buts -sticky ew
	    catch { grid anchor $w.buts center }
	}
	default {
	    error "error: only accepted styles ridgeframe, separator_nograb and separator"
	}
    }
    $w.buts conf -bg [CCColorActivo [$w  cget -bg]]

    if { $OKname == "" } {
	set OKname [_ OK]
    } 
    if { $Cancelname != "" } {
	set CancelName $Cancelname
    } elseif { $OKname == "-" } {
	set CancelName [_ Close]
    } else {
	set CancelName [_ Cancel]
    }

    set butwidth 7
    if { [string length $OKname] > $butwidth } { set butwidth [string length $OKname] }
    if { [string length $CancelName] > $butwidth } { set butwidth [string length $CancelName] }
    foreach i $morebuttons {
	if { [string length $i] > $butwidth } { set butwidth [string length $i] }
    }

    set usedletters [string tolower [string index $OKname 0]]
    if { [string tolower [string index $CancelName 0]] != $usedletters } {
	lappend usedletters [string tolower [string index $CancelName 0]]
	set underlinecancel 0
    } else {
	lappend usedletters [string tolower [string index $CancelName 1]]
	set underlinecancel 1
    }

    if { $OKname != "-" } {
	button $w.buts.ok -text $OKname -width $butwidth -und 0 -command \
		[namespace code "set action 1"]
    }

    set togrid ""
    if { $morebuttons != "" } {
	set iaction 2
	foreach i $morebuttons {
	    for { set ipos 0 } { $ipos < [string length $i] } { incr ipos } {
		set letter [string tolower [string index $i $ipos]]
		if { [regexp {[a-zA-Z]} $letter] && [lsearch $usedletters $letter] == -1 } {
		    break
		}
	    }
	    if { $ipos < [string length $i] } {
		button $w.buts.b$iaction -text $i -width $butwidth -und $ipos \
		        -command [namespace code "set action $iaction"]
		bind $w <Alt-$letter> \
		        "tkButtonInvoke $w.buts.b$iaction"
		bind $w.buts.b$iaction <Return> "tkButtonInvoke $w.buts.b$iaction"
		lappend usedletters [string tolower [string index $i $ipos]]
	    } else {
		button $w.buts.b$iaction -text $i -width $butwidth  \
		        -command [namespace code "set action $iaction"]
	    }
	    lappend togrid $w.buts.b$iaction
	    incr iaction
	}
    }
    if { $Cancelname != "-" } {
	button $w.buts.cancel -text $CancelName -width $butwidth -und $underlinecancel -command \
	[namespace code "set action 0"]
    }

    if { $OKname != "-" } {
	set togrid "$w.buts.ok $togrid"
    }
    if { $Cancelname != "-" } {
	set togrid "$togrid $w.buts.cancel"
    }
    eval grid $togrid -padx 2 -pady 4

    if { $OKname != "-" } {
	bind $w.buts.ok <Return> "tkButtonInvoke $w.buts.ok"
	catch {
	    bind $w <Alt-[string tolower [string index $OKname 0]]> "tkButtonInvoke $w.buts.ok"
	}
	focus $w.buts.ok
    } elseif { $Cancelname != "-" } {
	focus $w.buts.cancel
    }

    if { $Cancelname != "-" } {
	bind $w <Escape> "tkButtonInvoke $w.buts.cancel"
	bind $w.buts.cancel <Return> "tkButtonInvoke $w.buts.cancel"
	catch {
	    bind $w <Alt-[string tolower [string index $CancelName $underlinecancel]]> \
		"tkButtonInvoke $w.buts.cancel"
	}
	wm protocol $w WM_DELETE_WINDOW "tkButtonInvoke $w.buts.cancel"
    } else {
	bind $w <Escape> [namespace code "set action -1"]
	wm protocol $w WM_DELETE_WINDOW [namespace code "set action -1"]
    }

    grid columnconf $w 0 -weight 1
    grid rowconf $w 0 -weight 1

    return $w.f
}

proc DialogWin::InvokeOK { { visible 1 } } {
    variable w

    if { ![winfo exists $w.buts.ok] } { return }

    if { $visible } {
	tkButtonInvoke $w.buts.ok
    } else {
	$w.buts.ok invoke
    }
}

proc DialogWin::InvokeCancel { { visible 1 } } {
    variable w

    if { ![winfo exists $w.buts.cancel] } { return }

    if { $visible } {
	tkButtonInvoke $w.buts.cancel
    } else {
	$w.buts.cancel invoke
    }
}

proc DialogWin::FocusCancel {} {
    variable w
    focus $w.buts.cancel
}

proc DialogWin::InvokeButton { num { visible 1 } } {
    variable w

    if { ![winfo exists $w.buts] } { return }

    if { $num < 2 } {
	WarnWin "DialogWin::InvokeButton num>2"
	return
    }
    foreach i [winfo children $w.buts] {
	if { [regexp "\\m$num\\M" [$i cget -command]] } {
	    if { $visible } {
		tkButtonInvoke $i
	    } else {
		$i invoke
	    }
	    return
	}
    }
    WarnWin "DialogWin::InvokeButton num bad"
}

proc DialogWin::FocusButton { num } {
    variable w

    if { $num < 2 } {
	WarnWin "DialogWin::FocusButton num>2"
	return
    }
    foreach i [winfo children $w.buts] {
	if { [regexp "\\m$num\\M" [$i cget -command]] } {
	    focus $i
	    return
	}
    }
    WarnWin "DialogWin::FocusButton num bad"
}

proc DialogWin::CreateWindow { { geom "" } { minwidth "" } { minheight "" } } {
    CreateWindowNoWait $geom $minwidth $minheight
    return [WaitForWindow 0]
}

proc DialogWin::CreateWindowNoWait { { geom "" } { minwidth "" } { minheight "" } } {
    variable w
    variable grab
    variable oldGrab
    variable grabStatus

    set top [winfo toplevel [winfo parent $w]]

    wm withdraw $w
    update idletasks

    if { $geom != "" } {
	wm geom $w $geom
    } else {
	if { $minwidth != "" && [winfo reqwidth $w] < $minwidth } {
	    set width $minwidth
	} else { set width [winfo reqwidth $w] }
	if { $minheight != "" && [winfo reqheight $w] < $minheight } {
	    set height $minheight
	} else { set height [winfo reqheight $w] }

	if { [wm state $top] == "withdrawn" } {
	    set x [expr [winfo screenwidth $top]/2-$width/2]
	    set y [expr [winfo screenheight $top]/2-$height/2]
	} else {
	    set x [expr [winfo x $top]+[winfo width $top]/2-$width/2]
	    set y [expr [winfo y $top]+[winfo height $top]/2-$height/2]
	}
	if { $x < 0 } { set x 0 }
	if { $y < 0 } { set y 0 }

	wm geom $w ${width}x${height}+${x}+$y
    }
    wm deiconify $w
    update idletasks
    wm geom $w [wm geom $w]
    focus $w
    set oldGrab [grab current .]
    if {[string compare $oldGrab ""]} {
	set grabStatus [grab status $oldGrab]
	grab release $oldGrab
    }
    if { $grab } { grab $w }
}

proc DialogWin::WaitForWindow { { raise "" } } {
    variable action
    variable w

    if { $raise == "" } {
	# this is to avoid the 2 second problem in KDE 2
	if { $::tcl_platform(platform) == "windows" } {
	    set raise 1
	} else { set raise 0 }
    }
    if { $raise } {
	raise [winfo toplevel $w]
    }
    vwait [namespace which -variable action]
    return $action
}

proc DialogWin::DestroyWindow {} {
    variable w
    variable oldGrab
    variable grabStatus

    if {[string compare $oldGrab ""]} {
	if {[string compare $grabStatus "global"]} {
	    if { [winfo exists $oldGrab] && [winfo ismapped $oldGrab] } { grab $oldGrab }
	} else {
	    if { [winfo exists $oldGrab] && [winfo ismapped $oldGrab] } { grab -global $oldGrab }
	}
    }
    destroy $w
    set w ""
}

# NOTE: initial value of variables is not transferred
proc CopyNamespace { nfrom nto } {

    set comm "namespace eval $nto {\n"
    foreach i [info vars ${nfrom}::*] {
	append comm "variable [namespace tail $i]\n"
    }
    foreach i [info commands ${nfrom}::*] {
	set args ""
	foreach j [info args $i] {
	    if { [info default $i $j kk] } {
		lappend args [list $j $kk]
	    } else {
		lappend args $j
	    }
	}
	append comm "proc [namespace tail $i] { $args } {\n[info body $i]\n}\n"
    }

    append comm "}"
    eval $comm
}

namespace eval DialogWinTop {
    variable user
    variable nameprefix __
}

proc DialogWinTop::SetNamePrefix { prefix } {
    variable nameprefix $prefix
}

# command for OK is first; for cancel is last
proc DialogWinTop::Init { winparent title style commands { morebuttons "" } { OKname "" } \
    { Cancelname "" } } {
    variable nameprefix

    if { $winparent == "." } { set winparent "" }
    set w $winparent.${nameprefix}dialogwintop
    set i 0
    while { [winfo exists $w] } {
	incr i
	set w $winparent.${nameprefix}dialogwintop$i
    }
    toplevel $w
    wm title $w $title

    switch $style {
	ridgeframe {
	    frame $w.f -relief ridge -bd 2
	    frame $w.buts
	    grid $w.f -sticky ewns -padx 2 -pady 2
	    grid $w.buts -sticky ew

	}
	separator {
	    frame $w.f -bd 0
	    frame $w.sep -bd 2 -relief raised -height 2
	    frame $w.buts
	    grid $w.f -sticky ewns -padx 2 -pady 2
	    grid $w.sep -sticky ew
	    grid $w.buts -sticky ew
	    catch { grid anchor $w.buts center }
	}
	default {
	    error "error: only accepted styles ridgeframe and separator"
	}
    }

    $w.buts conf -bg [CCColorActivo [$w  cget -bg]]

    if { $OKname == "" } {
	set OKname [_ OK]
    }
    if { $Cancelname != "" } {
	set CancelName $Cancelname
    } elseif { $OKname == "-" } {
	set CancelName [_ Close]
    } else {
	set CancelName [_ Cancel]
    }

    set butwidth 7
    if { [string length $OKname] > $butwidth } { set butwidth [string length $OKname] }
    if { [string length $CancelName] > $butwidth } { set butwidth [string length $CancelName] }
    foreach i $morebuttons {
	if { [string length $i] > $butwidth } { set butwidth [string length $i] }
    }

    set usedletters [list [string tolower [string index $OKname 0]]]
    if { [string tolower [string index $CancelName 0]] != $usedletters } {
	lappend usedletters [string tolower [string index $CancelName 0]]
	set underlinecancel 0
    } else {
	lappend usedletters [string tolower [string index $CancelName 1]]
	set underlinecancel 1
    }

    set icomm 0
    if { $OKname != "-" } {
	button $w.buts.ok -text $OKname -width $butwidth -und 0 -command \
	    "[lindex $commands 0] $w.f"
	incr icomm
    }
    set letterbindings ""
    set togrid ""
    if { $morebuttons != "" } {
	foreach i $morebuttons {
	    for { set ipos 0 } { $ipos < [string length $i] } { incr ipos } {
		set letter [string tolower [string index $i $ipos]]
		if { [regexp {[a-zA-Z]} $letter] && [lsearch $usedletters $letter] == -1 } {
		    break
		}
	    }
	    if { $ipos < [string length $i] } {
		button $w.buts.b$icomm -text $i -width $butwidth -und $ipos \
		        -command "[lindex $commands $icomm] $w.f"
		set letter [string tolower [string index $i $ipos]]
		bind $w <Alt-$letter> "tkButtonInvoke $w.buts.b$icomm"
		lappend letterbindings $letter "tkButtonInvoke $w.buts.b$icomm"
		bind $w.buts.b$icomm <Return> "tkButtonInvoke $w.buts.b$icomm"
		lappend usedletters [string tolower [string index $i $ipos]]
	    } else {
		button $w.buts.b$icomm -text $i -width $butwidth  \
		        -command "[lindex $commands $icomm] $w.f"
	    }
	    lappend togrid $w.buts.b$icomm
	    incr icomm
	}
    }
    if { $Cancelname != "-" } {
	button $w.buts.cancel -text $CancelName -width $butwidth -und $underlinecancel -command \
	    "[lindex $commands $icomm] $w.f"
    }
     if { $OKname != "-" } {
	set togrid "$w.buts.ok $togrid"
    }
    if { $Cancelname != "-" } {
	set togrid "$togrid $w.buts.cancel"
    }
    eval grid $togrid -padx 2 -pady 4


    if { $OKname != "-" } {
	bind $w.buts.ok <Return> "tkButtonInvoke $w.buts.ok"
	set letter [string tolower [string index $OKname 0]]
	catch {
	    bind $w <Alt-$letter> "tkButtonInvoke $w.buts.ok"
	    lappend letterbindings $letter "tkButtonInvoke $w.buts.ok"
	}
	focus $w.buts.ok
    } elseif { $Cancelname != "-" } {
	focus $w.buts.cancel
    }

    if { $Cancelname != "-" } {
	bind $w <Escape> "tkButtonInvoke $w.buts.cancel"
	bind $w.buts.cancel <Return> "tkButtonInvoke $w.buts.cancel"

	set letter [string tolower [string index $CancelName $underlinecancel]]
	catch {
	    bind $w <Alt-$letter> "tkButtonInvoke $w.buts.cancel"
	    lappend letterbindings $letter "tkButtonInvoke $w.buts.cancel"
	}
	wm protocol $w WM_DELETE_WINDOW "tkButtonInvoke $w.buts.cancel"
    } elseif { $OKname != "-" } {
	bind $w <Escape> "tkButtonInvoke $w.buts.ok"
	wm protocol $w WM_DELETE_WINDOW "tkButtonInvoke $w.buts.ok"
    } else {
	bind $w <Escape> "tkButtonInvoke $w.buts.b0"
	wm protocol $w WM_DELETE_WINDOW "tkButtonInvoke $w.buts.b0"
    }
    
     bind $w <Destroy> {
	 if { [winfo class %W] == "Toplevel" } {
	      DialogWinTop::DestroyWindow %W
	 }
    }

    foreach but [winfo children $w.buts] {
	foreach "letter command" $letterbindings {
	    bind $but <KeyPress-$letter> $command
	}
    }

    grid columnconf $w 0 -weight 1
    grid rowconf $w 0 -weight 1

    return $w.f
}

proc DialogWinTop::DestroyWindow { w } {
    variable oldGrab
    variable grabStatus
    variable taborder

    if { [info exists taborder($w)] } { unset taborder($w) }

    if {[string compare $oldGrab ""]} {
	if {[string compare $grabStatus "global"]} {
	    if { [winfo exists $oldGrab] && [winfo ismapped $oldGrab] } { grab $oldGrab }
	} else {
	    if { [winfo exists $oldGrab] && [winfo ismapped $oldGrab] } { grab -global $oldGrab }
	}
    }
}

proc lreverse L {
    set res {}
    set i [llength $L]
    while {$i} {lappend res [lindex $L [incr i -1]]}
    set res
 }

proc DialogWinTop::TabOrderPrevNext { w what } {
    variable taborder

    set tabo $taborder([winfo toplevel $w])
    set ipos [lsearch $tabo $w]
    set tabo [concat [lrange $tabo [expr {$ipos+1}] end] [lrange $tabo 0 [expr {$ipos-1}]]]
    if { $what eq "prev" } { set tabo [lreverse $tabo] }
    
    foreach w $tabo {
	if { [tk::FocusOK $w] } {
	    tk::TabToWindow $w
	    return
	}
    }
    return
}

proc DialogWinTop::SetTabOrder { winlist } {
    variable taborder
    
    set top [winfo toplevel [lindex $winlist 0]]
    set taborder($top) $winlist

    foreach w $winlist {
	bind $w <Tab> "DialogWinTop::TabOrderPrevNext $w next; break"
	bind $w <<PrevWindow>> "DialogWinTop::TabOrderPrevNext $w prev; break"
    }
}

proc DialogWinTop::InvokeOK { f } {

    if { ![winfo exists $f] } { return }

    set w [winfo toplevel $f]
    tkButtonInvoke $w.buts.ok
}

proc DialogWinTop::InvokeCancel { f { visible 1 } } {
    variable w

    if { ![winfo exists $f] } { return }

    set w [winfo toplevel $f]
    if { $visible } {
	tkButtonInvoke $w.buts.cancel
    } else {
	$w.buts.cancel invoke
    }
}

proc DialogWinTop::InvokeButton { f num { visible 1 } } {

    if { ![winfo exists $f] } { return }

    set w [winfo toplevel $f]
    if { $num < 2 } {
	WarnWin "DialogWinTop::InvokeButton num>2"
	return
    }
    if { $visible } {
	tkButtonInvoke $w.buts.b[expr $num-1]
    } else {
	$w.buts.b[expr $num-1] invoke
    }
}

proc DialogWinTop::FocusButton { f num } {

    set w [winfo toplevel $f]
    if { $num < 2 } {
	WarnWin "DialogWinTop::FocusButton num>2"
	return
    }
    foreach i [winfo children $w.buts] {
	if { [regexp "\\m$num\\M" [$i cget -command]] } {
	    focus $i
	    return
	}
    }
    WarnWin "DialogWinTop::FocusButton num bad"
}

# what= 0 disable ; =1 enable
proc DialogWinTop::EnableDisableButton { f name what } {
    variable w

    set w [winfo toplevel $f]
    foreach i [winfo children $w.buts] {
	if { $name == [$i cget -text] } {
	    switch $what {
		1 { $i conf -state normal }
		0 { $i conf -state disabled }
	    }
	    return
	}
    }
    WarnWin "DialogWin::EnableDisableButton name bad"
}

proc DialogWinTop::CreateWindow { f { geom "" } { minwidth "" } { minheight "" } { grab 0 } } {
    variable oldGrab
    variable grabStatus


    set w [winfo parent $f]
    set top [winfo toplevel [winfo parent $w]]

    wm withdraw $w
    update idletasks

    if { $geom != "" } {
	wm geom $w $geom
    } else {
	if { $minwidth != "" && [winfo reqwidth $w] < $minwidth } {
	    set width $minwidth
	} else { set width [winfo reqwidth $w] }
	if { $minheight != "" && [winfo reqheight $w] < $minheight } {
	    set height $minheight
	} else { set height [winfo reqheight $w] }

	if { [wm state $top] == "withdrawn" } {
	    set x [expr [winfo screenwidth $top]/2-$width/2]
	    set y [expr [winfo screenheight $top]/2-$height/2]
	} else {
	    set x [expr [winfo x $top]+[winfo width $top]/2-$width/2]
	    set y [expr [winfo y $top]+[winfo height $top]/2-$height/2]
	}
	if { $x < 0 } { set x 0 }
	if { $y < 0 } { set y 0 }
	wm geom $w ${width}x${height}+${x}+$y
    }
    wm deiconify $w
    update idletasks
    #wm geom $w [wm geom $w]
    if {!$grab } {
	set oldGrab ""
	set grabStatus ""
    } else {
	set oldGrab [grab current $w]
	if {[string compare $oldGrab ""]} {
	    set grabStatus [grab status $oldGrab]
	    grab release $oldGrab
	}
	grab $w
    }
    focus $w
}

# proc DialogWin::messageBox { args } {
#     if { [info exists DialogWin2::w] } {
#         after 500 [list DialogWin::messageBox $args]
#         return
#     }
#     CopyNamespace ::DialogWin ::DialogWin2

#     array set opts [list -default "" -icon info -message "" -parent . -title "" \
#         -type ok]

#     for { set i 0 } { $i < [llength $args] } { incr i } {
#         set opt [lindex $args $i]
#         if { ![info exists opts($opt)] } {
#             error "unknown option '$opt' in DialogWin::messageBox"
#         }
#         incr i
#         set opts($opt) [lindex $args $i]
#     }
#     switch -- $opts(-type) {
#         abortretryignore {
#             set buts [list Abort Retry Ignore]
#         }
#         ok {
#             set buts [list OK]
#         }
#         okcancel {
#             set buts [list OK Cancel]
#         }
#         retrycancel {
#             set buts [list Retry Cancel]
#         }
#         yesno {
#             set buts [list Yes No]
#         }
#         yesnocancel {
#             set buts [list Yes No Cancel]
#         }
#         default {
#             error "unknown type: '$opts(-type)' in DialogWin::messageBox"
#         }
#     }
#     if { $opts(-default) == "" } {
#         set opts(-defaultpos) 0
#     } else {
#         set opts(-defaultpos) [lsearch -regexp $buts "(?iq)$opts(-default)"]
#         if { $opts(-defaultpos) == -1 } {
#             error "bad default option: '$opts(-default)' in DialogWin::messageBox"
#         }
#     }

#     set f [DialogWin2::Init $opts(-parent) $opts(-title) separator $buts - -]
#     set w [winfo toplevel $f]

#     label $f.l1 -image dialogwinquestionhead -grid 0
#     label $f.msg -justify left -text $opts(-message) -wraplength 3i -grid "1 px5 py5"

#     supergrid::go $f

#     DialogWin2::FocusButton [expr $opts(-defaultpos)+2]

#     set action [DialogWin2::CreateWindow]
#     while 1 {
#         switch -- $action {
#             -1 {
#                 if { [lsearch $buts Cancel] != -1 } {
#                     catch {
#                         DialogWin2::DestroyWindow
#                         namespace delete ::DialogWin2
#                     }
#                     return cancel
#                 }
#                 if { [lsearch $buts OK] != -1 } {
#                     DialogWin2::DestroyWindow
#                     namespace delete ::DialogWin2
#                     return ok
#                 }
#             }
#             default {
#                 DialogWin2::DestroyWindow
#                 namespace delete ::DialogWin2
#                 return [string tolower [lindex $buts [expr $action-2]]]
#             }
#         }
#         set action [DialogWin2::WaitForWindow]
#     }
# }

# for compatibility
proc DialogWin::messageBox { args } {
    #return [eval DialogWinTop::messageBox $args]
    return [eval snit_messageBox $args]
}

proc DialogWinTop::messageBox { args } {
    return [eval snit_messageBox $args]
}

namespace eval ::dialogwinmsgs {
    namespace export *


proc WarnWin { text { parent .} } {
    if { $parent eq "." } { set parent "" }
    set w [dialogwin_snit $parent.%AUTO% -title [_ Warning] -okname \
	       [_ OK] -cancelname "-"]
    set f [$w giveframe]

    label $f.l1 -image dialogwinquestionhead
    label $f.msg -justify left -text $text -wraplength 3i

    grid $f.l1 $f.msg -sticky nw
    grid configure $f.msg -padx 5 -pady 5

    set action [$w createwindow]
    destroy $w
}

proc WarnWin_hideerror { text errordata { parent .} } {
    if { $parent eq "." } { set parent "" }
    set w [dialogwin_snit $parent.%AUTO% -title [_ Warning] -okname [_ Ok] \
	       -cancelname -]
    set f [$w giveframe]

    label $f.l1 -image dialogwinquestionhead
    label $f.msg -justify left -text $text -wraplength 3i

    grid $f.l1 $f.msg -sticky nw
    grid configure $f.msg -padx 5 -pady 5

    bind $w <2> [list error $text $errordata]

    set action [$w createwindow]
    destroy $w
}

proc snit_messageBox { args } {

    array set opts [list -default "" -icon info -message "" -parent . -title "" \
	-type ok]

    for { set i 0 } { $i < [llength $args] } { incr i } {
	set opt [lindex $args $i]
	if { ![info exists opts($opt)] } {
	    error [_ "unknown option '%s' in snit_messageBox" $opt]
	}
	incr i
	set opts($opt) [lindex $args $i]
    }
    switch -- $opts(-type) {
	abortretryignore {
	    set retbuts [list abort retry ignore]
	    set buts [list [_ Abort] [_ Retry] [_ Ignore]]
	}
	ok {
	    set retbuts [list ok]
	    set buts [list [_ OK]]
	}
	okcancel {
	    set retbuts [list ok cancel]
	    set buts [list [_ OK] [_ Cancel]]
	}
	retrycancel {
	    set retbuts [list retry cancel]
	    set buts [list [_ Retry] [_ Cancel]]
	}
	yesno {
	    set retbuts [list yes no]
	    set buts [list [_ Yes] [_ No]]
	}
	yesnocancel {
	    set retbuts [list yes no cancel]
	    set buts [list [_ Yes] [_ No] [_ Cancel]]
	}
	default {
	    error [_ "unknown type: '%s' in snit_messageBox" $opts(-type)]
	}
    }
    if { $opts(-default) == "" } {
	set opts(-defaultpos) 0
    } else {
	set opts(-defaultpos) [lsearch -regexp $retbuts "(?iq)$opts(-default)"]
	if { $opts(-defaultpos) == -1 } {
	    error [_ "bad default option: '%s' in snit_messageBox" $opts(-default)]
	}
    }

    if { $opts(-parent) eq "." } {
	set w .%AUTO%
    } else {
	set w $opts(-parent).%AUTO%
    }
    set w [dialogwin_snit $w -title $opts(-title) -morebuttons $buts \
	       -okname - -cancelname -]
    set f [$w giveframe]

    if { $opts(-icon) == "info" || [lsearch [image names] $opts(-icon)] == -1 } {
	set opts(-icon) dialogwinquestionhead
    }

    label $f.l1 -image $opts(-icon)
    label $f.msg -justify left -text $opts(-message) -wraplength 3i

    grid $f.l1 $f.msg -sticky nw
    grid configure $f.msg -padx 5 -pady 5

    $w focusbutton [expr $opts(-defaultpos)+2]
    set action [$w createwindow]

    destroy $w

    switch -- $action {
	-1 - 0 {
	    if { [lsearch $buts [_ Cancel]] != -1 } {
		return cancel
	    }
	    if { [lsearch $buts [_ OK]] != -1 } {
		return ok
	    }
	}
	default {
	    set ipos [expr {$action-2}]
	    return [lindex $retbuts $ipos]
	}
    }
}

#--------------------------------------------------------------------------------
#     dialogwin_snit
#--------------------------------------------------------------------------------

# NOTE: examples at the end

# style: ridgeframe or separator
# entrytype: entry or password

snit::widget dialogwin_snit {
    option -title ""
    option -style separator
    option -grab 1
    option -morebuttons ""
    option -okname ""
    option -cancelname ""
    option -geometry ""
    option -minwidth ""
    option -minheight ""
    option -entrytype ""
    option -entrytext ""
    option -entrylabel ""
    option -entrydefault ""
    option -entryvalues ""

    hulltype toplevel

    delegate method * to hull
    delegate option * to hull

    variable action -1
    variable oldGrab ""
    variable grabStatus
    variable entryvalue
    variable uservar
    variable traces ""

    constructor args {
	$self configurelist $args

	wm title $win $options(-title)
	wm withdraw $win

	switch $options(-style) {
	    ridgeframe {
		frame $win.f -relief ridge -bd 2
		frame $win.buts
		grid $win.f -sticky ewns -padx 2 -pady 2
		grid $win.buts -sticky ew

	    }
	    separator {
		frame $win.f -bd 0
		frame $win.sep -bd 2 -relief raised -height 2
		frame $win.buts
		grid $win.f -sticky ewns -padx 2 -pady 2
		grid $win.sep -sticky ew
		grid $win.buts -sticky ew
		catch { grid anchor $win.buts center }
	    }
	    default {
		error "error: only accepted styles ridgeframe, separator_nograb and separator"
	    }
	}
	$win.buts conf -bg [CCColorActivo [$win cget -bg]]

	if { $options(-okname) eq "" } { set options(-okname) [_ "Ok"] }
	if { $options(-cancelname) eq "" } {
	    set options(-cancelname) [_ "Cancel"]
	    
	    if { $options(-okname) eq "-" && $options(-morebuttons) eq "" } {
		set options(-cancelname) [_ "Close"]
	    }
	}
	set butwidth 7
	if { [string length $options(-okname)] > $butwidth } {
	    set butwidth [string length $options(-okname)]
	}
	if { [string length $options(-cancelname)] > $butwidth } {
	    set butwidth [string length $options(-cancelname)]
	}
	foreach i $options(-morebuttons) {
	    if { [string length $i] > $butwidth } { set butwidth [string length $i] }
	}

	set usedletters ""
	if { $options(-okname) != "-" } {
	    for { set ipos 0 } { $ipos < [string length $options(-okname)] } { incr ipos } {
		set letter [string tolower [string index $options(-okname) $ipos]]
		if { [regexp {[a-zA-Z]} $letter] && [lsearch $usedletters $letter] == -1 } {
		    break
		}
	    }
	    if { $ipos < [string length $options(-okname)] } {
		button $win.buts.ok -text $options(-okname) -width $butwidth -und $ipos -command \
		    [list set [varname action] 1]
		bind $win <Alt-$letter> "tkButtonInvoke $win.buts.ok"
		bind $win.buts.ok <Return> "tkButtonInvoke $win.buts.ok"
		lappend usedletters $letter
		set widget($letter) $win.buts.ok
	    } else {
		button $win.buts.ok -text $options(-okname) -width $butwidth -command \
		    [list set [varname action] 1]
	    }
	}
	if { $options(-cancelname) ne "-" } {
	    for { set ipos 0 } { $ipos < [string length $options(-cancelname)] } { incr ipos } {
		set letter [string tolower [string index $options(-cancelname) $ipos]]
		if { [regexp {[a-zA-Z]} $letter] && [lsearch $usedletters $letter] == -1 } {
		    break
		}
	    }
	    if { $ipos < [string length $options(-cancelname)] } {
		set underlinecancel $ipos
		lappend usedletters [string tolower [string index $options(-cancelname) $ipos]]
	    } else { set underlinecancel "" }
	}

	set togrid ""
	set iaction 2
	foreach i $options(-morebuttons) {
	    for { set ipos 0 } { $ipos < [string length $i] } { incr ipos } {
		set letter [string tolower [string index $i $ipos]]
		if { [regexp {[a-zA-Z]} $letter] && [lsearch $usedletters $letter] == -1 } {
		    break
		}
	    }
	    if { $ipos < [string length $i] } {
		button $win.buts.b$iaction -text $i -width $butwidth -und $ipos \
		    -command [list set [varname action] $iaction]
		bind $win <Alt-$letter> "tkButtonInvoke $win.buts.b$iaction"
		bind $win.buts.b$iaction <Return> "tkButtonInvoke $win.buts.b$iaction"
		lappend usedletters $letter
		set widget($letter) $win.buts.b$iaction
	    } else {
		button $win.buts.b$iaction -text $i -width $butwidth  \
		    -command [list set [varname action] $iaction]
	    }
	    lappend togrid $win.buts.b$iaction
	    incr iaction
	}
	if { $options(-cancelname) ne "-" } {
	    if { $underlinecancel != "" } {
		button $win.buts.cancel -text $options(-cancelname) -width $butwidth \
		    -und $underlinecancel -command [list set [varname action] 0]
		set letter [string tolower [string index $options(-cancelname) $underlinecancel]]
		bind $win <Alt-$letter> "tkButtonInvoke $win.buts.cancel"
		bind $win.buts.cancel <Return> "tkButtonInvoke $win.buts.cancel"
		set widget($letter) $win.buts.cancel
	    } else {
		button $win.buts.cancel -text $options(-cancelname) -width $butwidth \
		    -command [list set [varname action] 0]
	    }
	}

	if { $options(-okname) ne "-" } {
	    set togrid "$win.buts.ok $togrid"
	}
	if { $options(-cancelname) ne  "-" } {
	    set togrid "$togrid $win.buts.cancel"
	}
	eval grid $togrid -padx 2 -pady 4

	if { $options(-okname) != "-" } {
	    focus $win.buts.ok
	} elseif { $options(-cancelname) != "-" } {
	    focus $win.buts.cancel
	}

	foreach i $togrid {
	    foreach letter $usedletters {
		bind $i <Key-$letter> [list tkButtonInvoke $widget($letter)]
	    }
	}
	if { $options(-cancelname) ne "-" } {
	    bind $win <Escape> "tkButtonInvoke $win.buts.cancel"
	    bind $win.buts.cancel <Return> "tkButtonInvoke $win.buts.cancel"
	    wm protocol $win WM_DELETE_WINDOW "tkButtonInvoke $win.buts.cancel"
	} else {
	    bind $win <Escape> [list set [varname action] -1]
	    wm protocol $win WM_DELETE_WINDOW [list set [varname action] -1]
	}

	grid columnconf $win 0 -weight 1
	grid rowconf $win 0 -weight 1

	if { $options(-entrytext) ne "" } {
	    label $win.f.l0 -text $options(-entrytext) -wraplength 200 -justify left
	    grid $win.f.l0 - -sticky w -pady "2 5"
	}
	if { $options(-entrytype) ne "" } {
	    label $win.f.l -text $options(-entrylabel)
	    switch $options(-entrytype) {
		entry {
		    if { $options(-entryvalues) eq "" } {
		        entry $win.f.e -textvariable [varname entryvalue] -width 40
		    } else {
		        ComboBox $win.f.e -textvariable [varname entryvalue] -width 40 \
		            -values $options(-entryvalues)
		    }
		}
		password {
		    entry $win.f.e -textvariable [varname entryvalue] -width 40 -show *
		}
	    }
	    set entryvalue $options(-entrydefault)
	    
	    grid $win.f.l $win.f.e -sticky w -padx 3 -pady 3
	    grid configure $win.f.e -sticky ew
	    grid columnconfigure $win.f 1 -weight 1

	    tkTabToWindow $win.f.e
	    bind $win <Return> [mymethod invokeok]
	}
    }
    destructor {
	set action -1

	if { $oldGrab ne "" }  {
	    if { $grabStatus ne "global" } {
		if { [winfo exists $oldGrab] && [winfo ismapped $oldGrab] } { grab $oldGrab }
	    } else {
		if { [winfo exists $oldGrab] && [winfo ismapped $oldGrab] } { grab -global $oldGrab }
	    }
	}
	foreach i $traces {
	    eval trace remove variable $i
	}
    }
    method giveframe {} {
	return $win.f
    }
    method invokeok { { visible 1 } } {
	if { ![winfo exists $win.buts.ok] } { return }
	
	if { $visible } {
	    tkButtonInvoke $win.buts.ok
	} else {
	    $win.buts.ok invoke
	}
    }
    method invokecancel { { visible 1 } } {
	if { ![winfo exists $win.buts.cancel] } { return }
	
	if { $visible } {
	    tkButtonInvoke $win.buts.cancel
	} else {
	    $win.buts.cancel invoke
	}
    }
    method invokebutton { num { visible 1 } } {
	if { ![winfo exists $win.buts] } { return }

	if { $num < 2 } {
	    error "DialogWin::InvokeButton num>2"
	}
	foreach i [winfo children $win.buts] {
	    if { [regexp "\\m$num\\M" [$i cget -command]] } {
		if { $visible } {
		    tkButtonInvoke $i
		} else {
		    $i invoke
		}
		return
	    }
	}
	error "DialogWin::InvokeButton num bad"
    }
    method focusok {} {
	if { ![winfo exists $win.buts.ok] } { return }
	focus $win.buts.ok
    }
    method focuscancel {} {
	if { ![winfo exists $win.buts.cancel] } { return }
	focus $win.buts.cancel
    }
    method focusbutton { num } {
	
	if { $num < 2 } {
	    error "DialogWin::FocusButton num>2"
	}
	foreach i [winfo children $win.buts] {
	    if { [regexp "\\m$num\\M" [$i cget -command]] } {
		focus $i
		return
	    }
	}
	error "DialogWin::FocusButton num bad"
    }
    method createwindow {} {
	$self createwindownowait
	return [$self waitforwindow 0]
    }
    method createwindownowait {} {

	set top [winfo toplevel [winfo parent $win]]

	wm withdraw $win
	update idletasks

	if { $options(-geometry) ne "" } {
	    wm geometry $win $options(-geometry)
	} else {
	    if { $options(-minwidth) != "" && [winfo reqwidth $win] < $options(-minwidth) } {
		set width $minwidth
	    } else { set width [winfo reqwidth $win] }
	    if { $options(-minheight) != "" && [winfo reqheight $win] < $options(-minheight) } {
		set height $minheight
	    } else { set height [winfo reqheight $win] }
	    
	    if { [wm state $top] == "withdrawn" } {
		set x [expr [winfo screenwidth $top]/2-$width/2]
		set y [expr [winfo screenheight $top]/2-$height/2]
	    } else {
		set x [expr [winfo x $top]+[winfo width $top]/2-$width/2]
		set y [expr [winfo y $top]+[winfo height $top]/2-$height/2]
	    }
	    if { $x < 0 } { set x 0 }
	    if { $y < 0 } { set y 0 }

	    wm geometry $win ${width}x${height}+${x}+$y
	}
	update idletasks
	wm deiconify $win
	update idletasks
	wm geometry $win [wm geometry $win]
	focus $win
	set oldGrab [grab current .]
	if { $oldGrab ne "" } {
	    set grabStatus [grab status $oldGrab]
	    grab release $oldGrab
	}
	if { $options(-grab) } { grab $win }
    }
    method waitforwindow { { raise "" } } {

	if { $raise == "" } {
	    # this is to avoid the 2 second problem in KDE 2
	    if { $::tcl_platform(platform) == "windows" } {
		set raise 1
	    } else { set raise 0 }
	}
	if { $raise } {
	    raise [winfo toplevel $win]
	}
	vwait [varname action]
	if { ![info exists action] } { return -1 }
	return $action
    }
    method giveentryvalue {} {
	return $entryvalue
    }
    method give_uservar { args } {
	switch -- [llength $args] {
	    1 {
		#nothing
	    }
	    2 {
		set  uservar([lindex $args 0]) [lindex $args 1]
	    }
	    default {
		error "error in give_uservar"
	    }
	}
	return [varname uservar([lindex $args 0])]
    }
    method set_uservar_value { key newvalue } {
	set uservar($key) $newvalue
    }
    method give_uservar_value { key } {
	return $uservar($key)
    }
    method add_trace_to_uservar { key cmd } {
	trace add variable [varname uservar($key)] write "$cmd;#"
	lappend traces [list [varname uservar($key)] write "$cmd;#"]
    }
}
}
namespace import -force ::dialogwinmsgs::*

image create photo dialogwinquestionhead -data {
    R0lGODlhKAAoAKUAAPHY8+y9+dmX1bxLt7EMprATqsIXtsE0tdaGz+bK2s94yt4UxeUNzNgK
    wcgEscQLsbEDocQjtOElzfEb2PMW1OQczMF5uuOr2dssyfw06vUk3M1ZvsScwMWrttFIwaw2
    qfY86tG4vvLW1uHV1NrExrSSpMw+uPhH79GYwftV+t8zyPXj5bRqqPxo/NxcyPos5cBYsN6j
    zuG42Nw+xMSivNx4xOxC3L8rr8xkvORM0MlrueBkyLxDtP///////////yH+FUNyZWF0ZWQg
    d2l0aCBUaGUgR0lNUAAh+QQBCgA/ACwAAAAAKAAoAAAG/sCfcEgsGo/IpHLJbDqf0Kj0CAhY
    AdOmYEDodguGAyKRNSoM6IWa0Wg4HhDIgFwORAwSyYRSoTAmDAtsDnEWWRcGGBkaExIbFhwd
    HRwKHoJuEB9SFxEgIIwbIQkJIiMiCSQhJSaDmVAJEScnjCgAIre4uAkdA36EA08mJymMCj+3
    tremuCMdGL4QKE0IICkZFCorK8srCSGiuQkse24ETSotJ3sux7c/CR4YGBbbuBwU+A0QhkoC
    Jy0v8JngtkLFHgoe2t0KwcfPgwJLPLRIMWHPBBgdQpDYgK8iB4UrYuDLB0GGkhktQByk0EiF
    HnwqaKzI9aMGvj4MHhhDksAG/sCOI4N6IDET1w8ZfW5SWAAjiYx/GlgmnephxExTK37EkDBy
    T4UFB5IIANGiItCREhIUdYfA4p+RFW4kiWGDGL4/XhEqFFEzKEu8GsIikfGCIsuVe3D8WPbj
    wsGkBzW8SIgEQIQUATu+pTBjGd8ciC1SeJFBcZJOLyoyYMmaAguNJFBM6NMHUMcXIAQo0YH7
    8J7NfDBwDWpxjwZPWZ0aWNS14h5Hlab+vZ2C3ZIDkn8fZKCiAwkSNFgk9U1Bw7ALTGQ8YGT2
    sG5lHUxMP1xthxMcDczirWBVl46OFhVmAxZOfJBfaxOEsNYKONhW0QuyoAfFDQ6s9tYGCWC1
    AiOHTkGYmxQr8FAhAyRSsEFGMczQkWQZqCDhFAgQ0EaJwFXEiAcElrGCDg840EYDbJC4QAMe
    xFDGERfocMAdBdywAQI5HinllFRWaeWVWB4RBAA7
}



#--------------------------------------------------------------------------------
#   dialogwin_snit EXAMPLES
#--------------------------------------------------------------------------------

#     SIMPLE: only text and buttons

if 0 {
    dialogwin_snit $win._ask -title [_ "Action"] -okname [_ "New password"] \
	-morebuttons [list [_ "Uncrypt"]] -entrytext [_ "Choose action to perform:"]
    set action [$win._ask createwindow]
    destroy $win._ask
    if { $action <= 0 } {  return }
    if { $action == 2 } {
	$wordnoter_db enterpage $options(-page) - $data
	return
    }
}

#     MEDIUM: text and buttons and entry

if 0 {
    dialogwin_snit $win._ask -title [_ "Enter password"] -entrytype password \
	-entrylabel [_ "Password:"] -entrytext [_ "Enter password to encrypt:"]
    set action [$win._ask createwindow]
    while 1 {
	if { $action <= 0 } { 
	    destroy $win._ask
	    return
	}
	set pass [string trim [$win._ask giveentryvalue]]
	if { [string length $pass] < 4 } {
	    $self warnwin [_ "Password must have at least 4 characters"]
	} else { break }
	set action [$win._ask waitforwindow]
    }
}

#     COMPLEX: user defined widgets

if 0 {
    dialogwin_snit $win._ask -title [_ "Change page type"] -entrytext \
	[_ "Choose a new page type for page '%s'" $page]
    set f [$win._ask giveframe]
    if { $type eq "" } { set type Normal }
    label $f.l1 -text [_ "Current type: %s" $type]
    label $f.l2 -text [_ "New type:"]
    ComboBox $f.cb1 -textvariable [$win._ask give_uservar newtype $type] -values \
	[list Normal Home] -editable 0
    tk::TabToWindow $f.cb1
    bind $f.cb1 <Return> [list $win._ask invokeok]
    grid $f.l1 - -sticky w -pady 2
    grid $f.l2 $f.cb1 -sticky w -padx 2 -pady "2 4"
    grid configure $f.cb1 -sticky ew
    grid columnconfigure $f 1 -weight 1

    set action [$win._ask createwindow]
    set newtype [$win._ask give_uservar_value newtype]
    destroy $win._ask
    if { $action <= 0 } {  return }
    if { $newtype eq "Normal" } { set newtype "" }
}
