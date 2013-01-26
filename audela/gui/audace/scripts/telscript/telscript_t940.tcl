# === Script template to test and to develop a scripted telescope driver ===
#
# INTRODUCTION
# ------------
# Driving a telescope with AudeLA is based on a Tcl instanciation of
# an AudeLA object called tel1. The driver itself is wriiten in C/C++
# code (source codes in audela/src/libtel).
#
# As a consequence, an astronomer interested to develop a new telescope 
# driver for AudeLA must program the corresponding C/C++ code that is
# not easy for most astronomers.
#
# The libtelscript telescope library is a programmed C/C++ telescope
# driver for AudeLA that calls a Tcl script every few milliseconds.
# By this way it becomes possible to develop a Tcl script that can
# drive a telescope.
#
# AN EXAMPLE
# ----------
# The telscript_template.tcl script simulates a basic telescope driver. 
# To test this driver, type the following terminal command:
#
# tel::create telscript -telname t940 -script $audace(rep_install)/gui/audace/scripts/telscript/telscript_t940.tcl -home \{$audace(posobs,observateur,gps)\}
#
# During the creation of tel1, firstly the script telscript_template.tcl is
# sourced. This script must contains at less two procs: setup and loop
# (with no input paramters). Secondly, the proc setup is called. The
# contents of the setup proc should establish the physical connections
# with the telescope controller. Thirdly, the proc loop is called inside
# an infinite loop. The proc loop should contain the code to process the
# actions to drive the telescope.
#
# After the creation, the tel1 commands like "tel1 radec coord" and others
# can be used.
#
# READING THE TELESCOPE COORDINATES
# ---------------------------------
#
# tel1 looperror
# tel1 loopeval "source $audace(rep_install)/gui/audace/scripts/telscript/telscript_t940.tcl"
# foreach res [lsort [tel1 variables]] { console::affiche_resultat "$res\n" }
# tel1 radec coord

# --- common defined variables
set telscript(def,telname) t940
set telscript(def,AXE_AZ) 0
set telscript(def,AXE_EL) 2
set telscript(def,AXE_PA) 3
set telscript(def,ETEL_MAXI) [expr 2048*8192*512]
set telscript(def,AXIS_AZ,adu2deg) [expr $telscript(def,ETEL_MAXI)/512.]
set telscript(def,AXI_AZ,adu) [expr $telscript(def,ETEL_MAXI)/2.]
set telscript(def,AXI_AZ,deg) 315
set telscript(def,AXIS_EL,adu2deg) [expr $telscript(def,ETEL_MAXI)/512.]
set telscript(def,AXI_EL,adu) [expr $telscript(def,ETEL_MAXI)/2.]
set telscript(def,AXI_EL,deg) 45
set telscript(def,AXIS_PA,adu2deg) [expr $telscript(def,ETEL_MAXI)/512.]
set telscript(def,AXI_PA,adu) [expr $telscript(def,ETEL_MAXI)/2.]
set telscript(def,AXI_PA,deg) 0

# === Proc called one time at the start of the driver
proc setup { } {
   global telscript
   # --- Get useful variables
   set telname $telscript(def,telname)   
   set AXE_AZ $telscript(def,AXE_AZ)
   set AXE_EL $telscript(def,AXE_EL)
   set AXE_PA $telscript(def,AXE_PA)

   # --- open the driver
   set err [catch {
      load libeteltcl.dll
      etel_open -driver DSTEB3 -axis $AXE_AZ -axis $AXE_EL -axis $AXE_PA
   } msg ]

   # --- identify the mode type of connection
   set telscript($telname,mode) real
   if {$err==1} {
      set telscript($telname,mode) simulation
   }
   
   if {$telscript($telname,mode)=="simulation"} {
      # --- The initial telescope position is HA=0 et Dec=0
      set telscript($telname,coord_app_cod_deg_ha)  0
      set telscript($telname,coord_app_cod_deg_dec) 0
      set telscript($telname,jdutc_app_cod) [mc_date2jd now]
      # --- The initial telescope motion is "motor off"
      set telscript($telname,speed_app_cod_deg_ha) 0
      set telscript($telname,speed_app_cod_deg_dec) 0
      set telscript($telname,motion) "stopped"
   }
   
   # --- Set a comment that the setup is OK
   set telscript($telname,status) "setup OK"
}

# === Proc called on loop after the start of the driver
# Before calling this proc, the following variables are updated
# telscript($telname,action_next)
# telscript($telname,ha0)
# telscript($telname,ra0)
# telscript($telname,dec0)
# After calling this proc, the following variables are commited
# telscript($telname,message)
# telscript($telname,coord_app_cod_deg_ra)
# telscript($telname,coord_app_cod_deg_dec)
# telscript($telname,coord_app_cod_deg_ha)
#
proc loop { } {
   global telscript
   # --- Get useful variables
   set telname $telscript(def,telname)
   set AXE_AZ $telscript(def,AXE_AZ)
   set AXE_EL $telscript(def,AXE_EL)
   set AXE_PA $telscript(def,AXE_PA)
   set home $telscript($telname,home)
   set telscript($telname,message) ""
  
   # === Compute current apparent coordinates for "tel1 radec coord"
   if {$telscript($telname,mode)=="real"} {
      set m7 [etel_get_register_s $AXE_AZ M 7]
	   append telscript($telname,message) "m7=$m7\n"   
      set az [expr 1.*($m7-$telscript(def,AXI_AZ,adu))/$telscript(def,AXIS_AZ,adu2deg)+$telscript(def,AXI_AZ,deg)]
      set m7 [etel_get_register_s $AXE_EL M 7]
      set el [expr 1.*($m7-$telscript(def,AXI_EL,adu))/$telscript(def,AXIS_EL,adu2deg)+$telscript(def,AXI_EL,deg)]
      set m7 [etel_get_register_s $AXE_PA M 7]
      set pa [expr 1.*($m7-$telscript(def,AXI_PA,adu))/$telscript(def,AXIS_PA,adu2deg)+$telscript(def,AXI_PA,deg)]
      set jd2 [mc_date2jd now]
      set res [mc_altaz2radec $az $el $home $jd2]
      set ra [lindex $res 0]
      set dec [lindex $res 1]
      set ha [lindex $res 2]
   } else {
      set jd1 $telscript($telname,jdutc_app_cod)
      set jd2 [mc_date2jd now]
      set lst [mc_date2lst $jd2 $home -format deg]
      set dsec [expr 86400.*($jd2-$jd1)]
      if {$telscript($telname,motion)=="radec_slewing"} {
         if {($telscript($telname,goto,speed_ha)==0)&&($telscript($telname,goto,speed_dec)==0)} {
            set telscript($telname,motion) "tracking"
         } else {
            set ha [expr $telscript($telname,coord_app_cod_deg_ha)+$dsec*$telscript($telname,goto,speed_ha)]
            set ha [expr fmod(720+$ha,360)]
            if {$ha>180} { set ha [expr $ha-360] }
            if {($telscript($telname,goto,speed_ha)>0)&&($ha>$telscript($telname,goto,halim))} {
               set ha $telscript($telname,goto,halim)
               set telscript($telname,goto,speed_ha) 0
            }
            if {($telscript($telname,goto,speed_ha)<0)&&($ha<$telscript($telname,goto,halim))} {
               set ha $telscript($telname,goto,halim)
               set telscript($telname,goto,speed_ha) 0
            }
            set dec [expr $telscript($telname,coord_app_cod_deg_dec)+$dsec*$telscript($telname,goto,speed_dec)]
            if {($telscript($telname,goto,speed_dec)>0)&&($dec>$telscript($telname,goto,declim))} {
               set dec $telscript($telname,goto,declim)
               set telscript($telname,goto,speed_dec) 0
            }
            if {($telscript($telname,goto,speed_dec)<0)&&($dec<$telscript($telname,goto,declim))} {
               set dec $telscript($telname,goto,declim)
               set telscript($telname,goto,speed_dec) 0
            }
         }
      } else {
         set ha  [expr $telscript($telname,coord_app_cod_deg_ha)+$dsec*$telscript($telname,speed_app_cod_deg_ha)]
         set ha [expr fmod(720+$ha,360)]
         set dec [expr $telscript($telname,coord_app_cod_deg_dec)+$dsec*$telscript($telname,speed_app_cod_deg_dec)]
      }
      set ra [expr fmod(720+$lst-$ha,360)]
      set telscript($telname,jdutc_app_cod) $jd2
   }
   # --- variables used to commit "tel1 radec coord" and "tel1 hadec coord" after this proc
   set telscript($telname,coord_app_cod_deg_ha) $ha
   set telscript($telname,coord_app_cod_deg_dec) $dec
   set telscript($telname,coord_app_cod_deg_ra) $ra
   
   # === Process actions (actions are set by tel1 commands)
   if {$telscript($telname,action_next)=="motor_on"} {
   
      # --- Action = motor_on
      
   } elseif {$telscript($telname,action_next)=="motor_off"} {
   
      # --- Action = motor_off
      
   } elseif {$telscript($telname,action_next)=="motor_stop"} {
   
      # --- Action = motor_stop
      
   } elseif {$telscript($telname,action_next)=="radec_goto"} {
   
      # --- Action = radec_goto
      
   }
    
   # --- Set a comment that the loop is OK
   set telscript($telname,status) "loop OK"
}
