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
# tel::create telscript -telname mytel -script $audace(rep_install)/gui/audace/scripts/telscript/telscript_template.tcl -home \{$audace(posobs,observateur,gps)\}
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
# tel1 loopeval "source $audace(rep_install)/gui/audace/scripts/telscript/telscript_template.tcl"
# foreach res [lsort [tel1 variables]] { console::affiche_resultat "$res\n" }
# tel1 radec coord

# --- common defined variables
set telscript(def,telname) mytel
set telscript(def,speed_diurnal) [expr 360./(23*3600+56*60+4)]

# === Proc called one time at the start of the driver
proc setup { } {
   global telscript
   # --- Get useful variables
   set telname $telscript(def,telname)   
   
   # --- The initial telescope position is HA=0 et Dec=0
   set telscript($telname,coord_app_cod_deg_ha)  0
   set telscript($telname,coord_app_cod_deg_dec) 0
   set telscript($telname,jdutc_app_cod) [mc_date2jd now]
   
   # --- The initial telescope motion is "motor off"
   set telscript($telname,speed_app_cod_deg_ha) 0
   set telscript($telname,speed_app_cod_deg_dec) 0
   set telscript($telname,motion) "stopped"
   
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
   set home $telscript($telname,home)
   set telscript($telname,message) ""
   catch {append telscript($telname,message) "ETAPE 0 telscript($telname,goto,halim)=$telscript($telname,goto,halim)\n"}
  
   # === Compute current apparent coordinates for "tel1 radec coord"
   set jd1 $telscript($telname,jdutc_app_cod)
   set jd2 [mc_date2jd now]
   set lst [mc_date2lst $jd2 $home -format deg]
   set dsec [expr 86400.*($jd2-$jd1)]
   if {$telscript($telname,motion)=="radec_slewing"} {
   append telscript($telname,message) "ETAPE 1\n"
      if {($telscript($telname,goto,speed_ha)==0)&&($telscript($telname,goto,speed_dec)==0)} {
         set telscript($telname,motion) "tracking"
      } else {
   append telscript($telname,message) "ETAPE 2\n"
         set ha [expr $telscript($telname,coord_app_cod_deg_ha)+$dsec*$telscript($telname,goto,speed_ha)]
         set ha [expr fmod(720+$ha,360)]
         if {$ha>180} { set ha [expr $ha-360] }
   append telscript($telname,message) "ETAPE 2 ha=$ha telscript($telname,goto,halim)=$telscript($telname,goto,halim)\n"
         if {($telscript($telname,goto,speed_ha)>0)&&($ha>$telscript($telname,goto,halim))} {
            set ha $telscript($telname,goto,halim)
            set telscript($telname,goto,speed_ha) 0
   append telscript($telname,message) "ETAPE 2.5\n"
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
   append telscript($telname,message) "ETAPE 3\n"
      }
   } else {
      set ha  [expr $telscript($telname,coord_app_cod_deg_ha)+$dsec*$telscript($telname,speed_app_cod_deg_ha)]
      set ha [expr fmod(720+$ha,360)]
      set dec [expr $telscript($telname,coord_app_cod_deg_dec)+$dsec*$telscript($telname,speed_app_cod_deg_dec)]
   }
   append telscript($telname,message) "ETAPE 4\n"
   set ra [expr fmod(720+$lst-$ha,360)]
   set telscript($telname,jdutc_app_cod) $jd2
   # --- variables used to commit "tel1 radec coord" and "tel1 hadec coord" after this proc
   set telscript($telname,coord_app_cod_deg_ha) $ha
   set telscript($telname,coord_app_cod_deg_dec) $dec
   set telscript($telname,coord_app_cod_deg_ra) $ra
   
   # === Process actions (actions are set by tel1 commands)
   if {$telscript($telname,action_next)=="motor_on"} {
   
      # --- Action = motor_on
      set telscript($telname,speed_app_cod_deg_ha) $telscript(def,speed_diurnal)
      
   } elseif {$telscript($telname,action_next)=="motor_off"} {
   
      # --- Action = motor_off
      set telscript($telname,speed_app_cod_deg_ha) 0
      set telscript($telname,speed_app_cod_deg_dec) 0
      
   } elseif {$telscript($telname,action_next)=="motor_stop"} {
   
      # --- Action = motor_stop
      set telscript($telname,speed_app_cod_deg_ha) 0
      set telscript($telname,speed_app_cod_deg_dec) 0
      set telscript($telname,motion) "stopped"
      
   } elseif {$telscript($telname,action_next)=="radec_goto"} {
   
   append telscript($telname,message) "ETAPE 100\n"
      # --- Action = radec_goto
      set ra0 $telscript($telname,ra0)
      set dec0 $telscript($telname,dec0)
      set ha0 [expr fmod(720+$lst-$ra0,360)]
      if {$ha0>180} { set ha0 [expr $ha0-360] }
      if {$ha>180} { set ha [expr $ha-360] }
      set dha [expr $ha0-$ha] ; # western positive
      set telscript($telname,goto,halim) $ha0
      set telscript($telname,goto,speed_ha) 0.5
      if {$dha<0} {
         set telscript($telname,goto,speed_ha) [expr -1*$telscript($telname,goto,speed_ha)]
      }
      set ddec [expr $dec0-$dec] ; # northern positive
      set telscript($telname,goto,declim) $dec0
      set telscript($telname,goto,speed_dec) 0.5
      if {$ddec<0} {
         set telscript($telname,goto,speed_dec) [expr -1*$telscript($telname,goto,speed_dec)]
      }
      set telscript($telname,motion) "radec_slewing"
      set telscript($telname,action_next) "motor_on"
   append telscript($telname,message) "ETAPE 200\n"
      
   }
  catch {append telscript($telname,message) "ETAPE 1000 telscript($telname,goto,halim)=$telscript($telname,goto,halim)\n"}
    
   # --- Set a comment that the loop is OK
   set telscript($telname,status) "loop OK"
}
