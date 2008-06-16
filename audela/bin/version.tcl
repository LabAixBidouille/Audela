#
# File : version.tcl
#
# This file is part of the AudeLA project : <http://software.audela.free.fr>
# Copyright (C) 1999-2008 The AudeLA Core Team
#
# Initial author : Denis MARCHAIS <denis.marchais@free.fr>
#
# This program is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 2 of the License, or (at
# your option) any later version.
#
# This program is distributed in the hope that it will be useful, but
# WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
# General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program; if not, write to the Free Software
# Foundation, Inc., 675 Mass Ave, Cambridge, MA 02139, USA.
#

global audela

set audela(major) "1"
set audela(minor) "5"
set audela(patch) "0"
set audela(extra) ""

set audela(version) "1.5.0"

set audela(date) "17/06/2008"

package provide audela "$audela(major).$audela(minor).$audela(patch)"

namespace eval ::audela {
   global audela

   package provide audela "${audela(major)}.${audela(minor)}.${audela(patch)}"
}

proc ::audela::getPluginType { } {
   return "audela"
}

proc ::audela::getPluginTitle { } {
   return "AudeLA"
}

