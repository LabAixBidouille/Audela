#
# Fichier : scopedome.tcl
# Description : Procedures specifiques du plugin
# Auteur : Raymond ZACHANTKE
# Mise à jour $Id$
#

#---------------------------------------------------------------------------
#  createProcess
#     create the process
#  parameter : path to the process, name of the window
#  return    : comobj connected
#---------------------------------------------------------------------------
proc ::scopedome::createProcess { path {windowName "ScopeDome LS"} } {

   package require tcom 3.9

   set progID "ASCOM.ScopeDomeUSBDome.DomeLS"

   set comobj [tcom::ref createobject -local $progID]
   tcom::configure -concurrency apartmentthreaded
   set connect 1
   set connected [::scopedome::connect $comobj $connect]

   #--   Debug
   #::scopedome::getAscomMethodsProperties $comobj
   #::console::disp "ici [tcom::info interface $comobj]\n"
   #::scopedome::getSupportedActions $comobj

   #--   Identifie et active la fenetre ouverte
   #set hwin [::scopedome::activateWindow $windowName]
   #set pid [twapi::get_window_process $hwin]

   return [list $comobj $connected]
}

#---------------------------------------------------------------------------
#  connect
#     Connect/Disconnect the driver
#  parameter : comobject, connect {0 = no | 1 yes}
#  return : state of Connected
#---------------------------------------------------------------------------
proc ::scopedome::connect { comobj connect } {

   if {$connect ne "[$comobj Connected]"} {
      $comobj Connected $connect
   }
   return  [$comobj Connected]
}

#---------------------------------------------------------------------------
#  activateWindow
#     get focus on the driver
#  parameter : windowName (eg ScopeDome LS)
#  return : hwin
#---------------------------------------------------------------------------
proc ::scopedome::activateWindow { windowName } {

   set hwin ""
   while {$hwin eq ""} {
      set hwin [twapi::find_windows -match glob -text "$windowName"]
      after 500
   }

   twapi::show_window $hwin -sync -activate
   twapi::set_foreground_window $hwin
   twapi::move_window $hwin 800 400 -sync
   twapi::set_focus $hwin

   return $hwin
}

#---------------------------------------------------------------------------
#  killCom
#     Close ScopeDome LS if it exists and kill com object
#  parameter : none
#  return : nothing
#---------------------------------------------------------------------------
proc ::scopedome::killCom { } {
   variable widget

   if {[info exists widget(comobj)] ==1} {
      catch { $widget(comobj) Dispose }
      unset widget(comobj)
   }
}

#---------------------------------------------------------------------------
#  writeFileSystem
#     write file :/ScopeDome/CurrentTelescopeStatus.txt (< 3ms)
#     file structure :
#     [header]
#     telescop_name = "name"
#     [Telescope]
#     Alt=5.6
#     Az=340
#     Ra=3.3
#     Dec=4.5
#     SideOfPier=1
#     Slewing=false
#     AtPark=true
#  parameter : cycle (ms)
#  return : nothing
#---------------------------------------------------------------------------
proc ::scopedome::writeFileSystem { cycle } {
   variable widget
   global audace conf caption

   set telNo $audace(telNo)

   if {$conf(scopedome,connectScope) ==1 && $telNo == 1 && $widget(domNo) ==1} {

      #--
      set listNoCoords [list \
         "$caption(telescope,astre_est)" \
         "$caption(telescope,tel)" \
         "$caption(telescope,pas_coord1)" \
      ]

      set rahms $audace(telescope,getra)
      set decdms $audace(telescope,getdec)
      if {$rahms ni $listNoCoords} {

         set radeg [mc_angle2deg $rahms]
         set decdeg [mc_angle2deg $decdms]
         set home $conf(posobs,observateur,gps)
         set datetu [mc_date2iso8601 [::audace::date_sys2ut now]]
         set date [mc_date2jd $datetu]
         lassign [mc_radec2altaz $radeg $decdeg $home $date] azdeg altdeg
         set azdeg [expr {fmod($azdeg+180,360)}]
         set side [string map [list E 0 W 1] [tel$telNo german]]
         if {$audace(telescope,goto) ==1} {
            set slewing "true"
         } else {
            set slewing "false"
         }

         #--   Write file "C:/ScopeDome/ScopeDomeCurrentTelescopeStatus.txt"
         set fid [open $widget(filesystem) w]
         puts $fid "\[header\]"
         puts $fid "program_name = \"$conf(telescope)\""
         puts $fid "\[Telescope\]"
         puts $fid "Alt=$altdeg"
         puts $fid "Az=$azdeg"
         puts $fid "Ra=$radeg"
         puts $fid "Dec=$decdeg"
         puts $fid "SideOfPier=$side"
         puts $fid "Slewing=$slewing"
         puts $fid "AtPark=false"
         catch {close $fid}
      }
   }

   set widget(afterID) [after $cycle "::scopedome::writeFileSystem $cycle"]
}

#------------------------------------------------------------
#  onChangeScope  :
#     Start/Stop to write file \
#     C:/ScopeDome/ScopeDomeCurrentTelescopeStatus.txt
#  parameter : action { refresh | stop }
#  return nothing
#------------------------------------------------------------
proc ::scopedome::onChangeScope { {action ""} } {
   variable widget

   set cycle 5000 ;# ms

   if {$action eq "refresh"} {
      ::scopedome::writeFileSystem $cycle
  } elseif {$action eq "stop" && [info exists widget(afterID)] == 1} {
      #--   Arrete l'ecriture du fichier
      after cancel "::scopedome::writeFileSystem $cycle"
      unset widget(afterID)
   }
}

#---------------------------------------------------------------------------
#  cmd
#  Dispatch commands
#  parameter : type
#  return nothing
#---------------------------------------------------------------------------
proc ::scopedome::cmd { type } {
   variable widget

   set do $widget(${type})
   set comobj $widget(comobj)
   set widget(propertyResult) ""

   if {[catch {
      switch -exact $type {
         action   {  if {$do in [list AbortSlew CloseShutter OpenShutter Park]} {
                        $comobj $do
                     } else {
                        $comobj Action $do ""
                     }
                  }
         switch   {  set value $widget(switchValue)
                     if {$do eq "Slaved"} {
                        #--   Ascom command Slaved (pas de toggle)
                        $comobj -set $do $value
                     } else {
                        set value [string map [list Off 0 On 1 Toggle 2] $value]
                        $comobj CommandString "$do $value"
                     }
                  }
         cmd      {  set value $widget(cmdValue)
                     #--   Verify input
                     if {$do in [list SlewToAzimuth SyncToAzimuth GoTo]} {
                        if {[string is double -strict $value] ==1 && \
                           $value >= 0 && $value <= 360} {
                        } else {
                           ::scopedome::errorBox limite
                           set widget(ok) 0
                           return $widget(ok)
                        }
                     }
                     if {$do eq "Enc_GoTo"} {
                        set azFinal [expr { 179.0+int($value)/3464 }]
                     } else {
                        set azFinal $value
                     }
                     set deltaMin 0.05
                     set widget(propertyResult) [::scopedome::readProperty $comobj Azimuth]
                     lassign $widget(propertyResult) az
                     set delta [expr { abs($azFinal-$az) }]
                     update

                     if {$do in [list SlewToAzimuth SyncToAzimuth]} {
                        #--   Ascom command
                        $comobj $do $value
                     } elseif {$do in [list GoTo Enc_GoTo]} {
                        #--   Other command
                        $comobj CommandString "$do $value"
                     }

                     #--   Suit le deplacement
                     while {$delta >= $deltaMin} {
                        after 2000
                        set widget(propertyResult) [::scopedome::readProperty $comobj Azimuth]
                        lassign $widget(propertyResult) az
                        set delta [expr { abs($azFinal-$az) }]
                        update
                     }
                     set widget(propertyResult) [::scopedome::readProperty $comobj Azimuth]
                     return $widget(propertyResult)
                  }
         property {  set widget(propertyResult) [::scopedome::readProperty $comobj $do]}
      }
    } msg] == 1} {
      ::console::disp "$do : $msg\n"
   }
}

#---------------------------------------------------------------------------
#  readProperty
#  parameter : comobj, propertyName
#  return : formated value
#---------------------------------------------------------------------------
proc ::scopedome::readProperty { comobj propertyName } {

   if {[catch {
      if {$propertyName in [list Azimuth AtHome AtPark Connected \
         ShutterStatus Slaved Slewing]} {
         #--   Variables for direct reading (ASCOM)
         set result "[$comobj -get $propertyName]"
      } else {
         #--   Variables requiring CommandString
         set result "[$comobj -get CommandString $propertyName]"
         regsub "," $result "." result
      }
   } msg] ==1} {
      ::console::disp "$msg\n"
   }

   #--   Format = degres
   set listDeg [list Azimuth Dome_Scope_Ra Dome_Scope_Dec \
      Dome_Scope_Alt Dome_Scope_Az Wind_Direction]

   #--   Format = °C
   set listCelsius [list Dew_Point Temperature_In_Dome Temperature_Outside_Dome \
      Temperature_Humidity_Sensor Temperature_In_From_Weather_Station \
      Temperature_Out_From_Weather_Station]

   #--   Format = boolean
   set listBool [list AtHome AtPark Connected Dome_Error \
      Dome_Scope_Is_Connected Slaved Slewing Cloud_Sensor_Rain \
      Rel_Scope_Get_State Rel_CCD_Get_State \
      Rel_Light_Get_State Rel_Fan_Get_State \
      Rel_REL_1_Get_State Rel_REL_2_Get_State \
      Rel_REL_3_Get_State Rel_REL_4_Get_State \
      Rel_Shutter_1_Open_Get_State Rel_Shutter_1_Close_Get_State \
      Rel_Shutter_2_Open_Get_State Rel_Shutter_2_Close_Get_State \
      Rel_Dome_CW_Get_State Rel_Dome_CCW_Get_State]

   #--   Format tristate {0|1|-1}
   set listTriState [list Internal_Sensor_Observatory_Safe \
     Internal_Sensor_Power_Failure Internal_Sensor_Scope_At_Home \
      Internal_Sensor_Clouds Internal_Sensor_Rain Internal_Sensor_Free_Input \
      Cloud_Sensor_Day_Night Cloud_Sensor_Clear_Cloudy]

   #--    Format %
   set listPercent [list Humidity_Humidity_Sensor Shutter_Link_Strength]

   #--   Format V
   set listVolt [list Analog_Input_Shutter Analog_Input_Main]

   #::console::disp "read $propertyName $result\n"

   #--   Formatting of the result
   if {$propertyName in $listDeg} {
      if {$result eq "0"} {
         set result "Scope not connected"
      } else {
         set result [format "%.2f °" $result]
      }
   } elseif {$propertyName in $listCelsius} {
      set result [format "%.1f °C" $result]
   } elseif {$propertyName in $listVolt} {
      if {$result ==0} {
         set result ?
      } else {
         set result [format "%.2f V" $result]
      }
   } elseif {$propertyName in $listPercent} {
      if {$propertyName eq "Shutter_Link_Strength" && $result ==0} {
         set result ?
      } else {
         append result " %"
      }
   } elseif {$propertyName eq "Wind_Speed"} {
      set result [format "%s km/h" $result]
   } elseif {$propertyName eq "Pressure"} {
      set result [format "%s hPa" $result]
   } elseif {$propertyName eq "ShutterStatus"} {
      set result [string map [list 0 Open 1 Closed] $result]
   } elseif {$propertyName in "$listTriState"} {
      set result [string map [list 0 No 1 Yes -1 ?] $result]
   } elseif {$propertyName in $listBool} {
      set result [string map [list 0 False 1 True] $result]
   }

   return $result
}

#---------- not used or only for debug -------------------

#---------------------------------------------------------------------------
#  getAscomMethodsProperties
#     for debug
#  parameter : comobject
#  return : nothing
#---------------------------------------------------------------------------
proc ::scopedome::getAscomMethodsProperties { comobj } {

   set interfacehandle [tcom::info interface $comobj]
   foreach c [list name iid methods properties] {
      set content [$interfacehandle $c]
      ::console::disp "\n$c :\n"
      for {set i 0} {$i < [llength $content]} {incr i} {
         ::console::disp "[lindex $content $i]\n"
      }
   }
}

#---------------------------------------------------------------------------
#  getSupportedActions
#    get all supported actions
#    write them in a file
#    for debug
#  parameter : COM object
#  return : list of supported actions
#---------------------------------------------------------------------------
proc ::scopedome::getSupportedActions { comobj } {

   set supportedActions [list ]
   set handle [$comobj SupportedActions]
   if {$handle ne ""} {
      for {set i 0} {$i < [$handle Count]} {incr i} {
         set cmd [$handle Item $i]
         lappend supportedActions $cmd
      }
   }

   #--    Debug
   set fid [open [file join "C:/" ScopeDome supportedActionsLS.txt] w]
   foreach cmd $supportedActions {
      puts $fid $cmd
   }
   close $fid

   return $supportedActions
}

#---------------------------------------------------------------------------
#  executeVBSScript
#     execute a vbs script
#     not in use
#  parameter : access to vbs script file
#  return nothing
#---------------------------------------------------------------------------
proc ::scopedome::executeVBSScript { scriptFile } {

   if {[catch {exec wscript.exe $scriptFile} msg] !=0} {
      ::console::disp "$msg\n"
   }
}

#---------------------------------------------------------------------------
#  writeScriptBat
#     commande du bouton 'Script BAT'
#     create a batchfile, execute the command, destroy the batchfile
#     not in use
#  parameter : none
#  return nothing
#---------------------------------------------------------------------------
proc ::scopedome::writeScriptBat { }  {
   variable widget

   set cmdBat [file join [file dirname $widget(fileAccess)] test.bat]
   set cmd $widget(actionsParam)

   #--   Cree le fichier de commande test.bat
   set fid [open $cmdBat w]
   puts $fid "$widget(fileAccess) $cmd"
   close $fid

   if {[catch {exec $cmdBat} msg] ==0} {
      ::console::disp "$cmd OK\n"
   } else {
      ::console::disp "$msg\n"
   }
   file delete -force $cmdBat
}

