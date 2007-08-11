#
# Fichier : ros.tcl
# Description : Function to launch Robotic Observatory Software installation
# Auteur : Alain KLOTZ
# Mise a jour $Id: ros.tcl,v 1.3 2007-08-11 09:31:13 alainklotz Exp $
#

proc ros { {action install} } {
	global ros
	set err [catch {wm withdraw .} msg]
	set ros(withtk) 1
	if {$action=="install"} {
		if {$err==1} {
			set ros(withtk) 0
		}
		source [pwd]/../ros/ros_install.tcl
	}
}

