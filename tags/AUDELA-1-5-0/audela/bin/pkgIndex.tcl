#
# Fichier : pkgIndex.tcl
# Description : Definition du point d'entree du package
# Mise a jour $Id: pkgIndex.tcl,v 1.3 2009-01-18 16:50:25 denismarchais Exp $
#
# This file is part of the AudeLA project : <http://www.audela.org>
# Copyright (C) 2008 The AudeLA Core Team
#
# Initial author : Michel PUJOL <michel-pujol@orange.fr>
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

package ifneeded audela 1.5.0 [ list source [ file join $dir version.tcl ] ]
