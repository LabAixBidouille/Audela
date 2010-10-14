#
# $Id: cursors.tcl,v 1.1 2009-02-21 14:04:20 michelpujol Exp $
#
# Ttk package: Symbolic cursor names.
#
# @@@ TODO: Figure out appropriate platform-specific cursors
#	for the various functions.
#

namespace eval ttk {

    variable Cursors

    switch -glob $::tcl_platform(platform) {
	"windows" {
	    array set Cursors {
		hresize 	sb_h_double_arrow
		vresize 	sb_v_double_arrow
		seresize	size_nw_se
	    }
	}

	"unix" -
	* {
	    array set Cursors {
		hresize 	sb_h_double_arrow
		vresize 	sb_v_double_arrow
		seresize	bottom_right_corner
	    }
	}

    }
}

#*EOF*
