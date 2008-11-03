#
# Fichier : ros.tcl
# Description : Function to launch Robotic Observatory Software installation
# Auteur : Alain KLOTZ
# Mise a jour $Id: ros.tcl,v 1.7 2008-11-03 11:58:34 alainklotz Exp $
#

proc ros { args } {
   global ros

   set ros(withtk) 1
   set err [catch {wm withdraw .} msg]
   if {$err==1} {
      set ros(withtk) 0
   }

   set action [lindex $args 0]
   set syntax "ros Software Keyword Action ?parameters?"

   if {$action=="install"} {
      source [pwd]/../ros/ros_install.tcl

   } elseif {$action=="gardien"} {
      # source ../gui/audace/ros.tcl
      # ros gardien send SET init|roof_open|roof_close|flatfield_on|flatfield_off|dark_on|dark_off|native
      # case of native : ros gardien send SET native Power LCOUPOLE 1
      #set syntax "ros gardien send SET init|roof_open|roof_close|flatfield_on|flatfield_off|dark_on|dark_off|native ?params?"
      set action2 [lindex $args 1]
      set params [lrange $args 2 end]
      set err [catch {source "[pwd]/../ros/root.tcl"}] ; if {$err==1} { source "$ros(root,ros)/../ros/root.tcl" }
      set ros(falsenameofexecutable) majordome
      source "$ros(root,ros)/src/common/variables_globales.tcl"
      unset ros(falsenameofexecutable)
      set req(gardien,gar,host) $req(majordome,gardien,host)
      set req(gardien,gar,port) $req(majordome,gardien,port)
      set err [catch {source "[pwd]/../gui/audace/socket_tools.tcl"}] ; if {$err==1} { source "$ros(root,ros)/../gui/audace/socket_tools.tcl" }
      set err [catch {socket_client_open clientgar2 $req(gardien,gar,host) [expr $req(gardien,gar,port)+1]} msg]
      if {$err==1} {
         set texte $msg
         if {$ros(withtk)==0} {
            puts "$texte"
         } else {
            ::console::affiche_resultat "$texte\n"
         }
         return
      }
      if {($action2=="send")} {
         socket_client_put clientgar2 "$params"
         after 2000
         set msg [socket_client_get clientgar2]
      } else {
         set msg "$syntax\nERROR: Action must be amongst send"
      }
      set texte $msg
      if {$ros(withtk)==0} {
         puts "$texte"
      } else {
         ::console::affiche_resultat "$texte\n"
      }
      socket_client_close clientgar2

   } elseif {$action=="telescope"} {
      # source ../gui/audace/ros.tcl
      # ros telescope send SET native ?params?
      # case of native : ros telescope send SET native #j-
      set action2 [lindex $args 1]
      set params [lrange $args 2 end]
      set err [catch {source "[pwd]/../ros/root.tcl"}] ; if {$err==1} { source "$ros(root,ros)/../ros/root.tcl" }
      set ros(falsenameofexecutable) majordome
      source "$ros(root,ros)/src/common/variables_globales.tcl"
      unset ros(falsenameofexecutable)
      set req(telescope,tel,host) $req(majordome,tel,host)
      set req(telescope,tel,port) $req(majordome,tel,port)
      set err [catch {source "[pwd]/../gui/audace/socket_tools.tcl"}] ; if {$err==1} { source "$ros(root,ros)/../gui/audace/socket_tools.tcl" }
      set err [catch {socket_client_open clienttel2 $req(telescope,tel,host) [expr $req(telescope,tel,port)+1]} msg]
      if {$err==1} {
         set texte $msg
         if {$ros(withtk)==0} {
            puts "$texte"
         } else {
            ::console::affiche_resultat "$texte\n"
         }
         return
      }
      if {($action2=="send")} {
         socket_client_put clienttel2 "$params"
         after 2000
         set msg [socket_client_get clienttel2]
      } else {
         set msg "$syntax\nERROR: Action must be amongst send"
      }
      set texte $msg
      if {$ros(withtk)==0} {
         puts "$texte"
      } else {
         ::console::affiche_resultat "$texte\n"
      }
      socket_client_close clienttel2

   } elseif {$action=="camera"} {
      # source ../gui/audace/ros.tcl
      # ros telescope send SET native ?params?
      # case of native : ros telescope send SET native #j-
      set action2 [lindex $args 1]
      set params [lrange $args 2 end]
      set err [catch {source "[pwd]/../ros/root.tcl"}] ; if {$err==1} { source "$ros(root,ros)/../ros/root.tcl" }
      set ros(falsenameofexecutable) majordome
      source "$ros(root,ros)/src/common/variables_globales.tcl"
      unset ros(falsenameofexecutable)
      set req(camera,cam,host) $req(majordome,cam,host)
      set req(camera,cam,port) $req(majordome,cam,port)
      set err [catch {source "[pwd]/../gui/audace/socket_tools.tcl"}] ; if {$err==1} { source "$ros(root,ros)/../gui/audace/socket_tools.tcl" }
      set err [catch {socket_client_open clientcam2 $req(camera,cam,host) [expr $req(camera,cam,port)+1]} msg]
      if {$err==1} {
         set texte $msg
         if {$ros(withtk)==0} {
            puts "$texte"
         } else {
            ::console::affiche_resultat "$texte\n"
         }
         return
      }
      if {($action2=="send")} {
         socket_client_put clientcam2 "$params"
         after 2000
         set msg [socket_client_get clientcam2]
      } else {
         set msg "$syntax\nERROR: Action must be amongst send"
      }
      set texte $msg
      if {$ros(withtk)==0} {
         puts "$texte"
      } else {
         ::console::affiche_resultat "$texte\n"
      }
      socket_client_close clientcam2

   } else {
      set texte "$syntax"
      append texte "\nERROR: Software must amongst install gardien telescope camera"
      if {$ros(withtk)==0} {
         puts "$texte"
      } else {
         ::console::affiche_resultat "$texte\n"
      }
   }
}

