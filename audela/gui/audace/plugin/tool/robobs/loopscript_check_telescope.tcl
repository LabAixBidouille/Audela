# Script check_telescope
# This script will be sourced in the loop
# ---------------------------------------
# Goal of the script :
#
# According to the value of robobs(conf,telescope,telno,value),
# determines if the connection is well established with the
# telescope.
#
# If robobs(conf,telescope,telno,value) = 0, it means that no
# telescope is connected. Then we consider a simulation telescope
# for the next scripts to source.
# 
# ---------------------------------------
# Input variables, other than robobs(conf,*) :
#
# None
#
# ---------------------------------------
# Output variables :
#
# robobs(tel,name) = Name of the telescope
# robobs(tel,connected) = 1 if the connection is OK, else =0
#
# ---------------------------------------

# === Beginning of script
::robobs::log "$caption(robobs,start_script) RobObs [info script]" 10

# === Body of script

# --- Telescope name: simulation or real
set telNo $robobs(conf,telescope,telno,value)
if {$telNo==0} {
   set robobs(tel,name) simulation
   set robobs(tel,connected) 1
} else {
   set robobs(tel,name) [tel$telNo name]
   set robobs(tel,connected) [tel$telNo drivername]
}

# --- Reconnect the tel if necessary (TBD in a personal script)

# === End of script
::robobs::log "$caption(robobs,exit_script) RobObs [info script]" 10
return ""
