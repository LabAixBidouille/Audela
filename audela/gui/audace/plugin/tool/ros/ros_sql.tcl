# source audace/plugin/tool/ros/ros_sql.tcl

#
# Fichier        : ros_sql.tcl
# Description    : Routines sql
# Auteur         : Frédéric Vachier
# Mise à jour $Id: ros_sql.tcl,v 1.1 2011-02-19 20:43:49 fredvachier Exp $
#

namespace eval ros_sql {

   global rosconf

   # ==========================================================================================
   # ==========================================================================================
   proc sql { args } {
      global sql
   
      set cmd [lindex $args 0]
      if {$cmd=="connect"} {
         set ipdb [lindex $args 1]
         set user [lindex $args 2]
         set pass [lindex $args 3]
         if {[info exists sql(h)]==1} {
            if {$sql(h)!=""} {
               ::mysql::close $sql(h)
               unset sql(h)
            }
         }
         set sql(h) [::mysql::connect -host $ipdb -user $user -password $pass]
      } elseif {$cmd=="disconnect"} {
         ::mysql::close $sql(h)
         unset sql(h)
      } elseif {$cmd=="selectdb"} {
         set db [lindex $args 1]
         ::mysql::use $sql(h) $db
      } elseif {$cmd=="getcolname"} {
         ::mysql::col $sql(h) -current name
      } elseif {$cmd=="select"} {
         set texte [lindex $args 1]
         set row ""
         set row [::mysql::sel $sql(h) "$texte" -list]
         if {$row==""} {
            return ""
         }
         set col ""
         set col [::mysql::col $sql(h) -current name]
         set res ""
         lappend res $col
         lappend res $row
         return $res
      } elseif {$cmd=="query"} {
         set texte [lindex $args 1]
         set sql(q) [::mysql::query $sql(h) "$texte"]
         if {$sql(q)==-1} {
            return ""
         }
         set res ""
         while {[set row [::mysql::fetch $sql(q)]]!=""} {
            lappend res $row
         }
         ::mysql::endquery $sql(q)
         return $res
      } elseif {$cmd=="insertid"} {
         set nb [::mysql::insertid $sql(h)]
         return $nb
      } else {
         error "usage : sql connect|disconnect|selectdb|query|insertid|getcolname"
      }
   }
   
   # ==========================================================================================
   # -- Connexion a ros --
   # ==========================================================================================
   proc connect { } {
   
      global rosconf
      set connected "Connecté à $rosconf(dbname)"

      set err [catch {sql query "use $rosconf(dbname);"} msg]
      if {$err} {
         # -- Connexion a MySql --
         set err [catch {sql connect $rosconf(server) $rosconf(login) $rosconf(pass)} msg]
         if {$err} {
            gren_info "Erreur de connexion a MySql <$err> <$msg>\n"
            return -code error "Erreur de connexion a MySql <$err> <$msg>" 
         } else {
            gren_info "Connecté à MySql <$msg>\n"
            # -- Connexion a ros --
            set err [catch {sql query "use $rosconf(dbname);"} msg]
            if {$err} {
               gren_info "Erreur de connexion à $rosconf(dbname) <$err> <$msg>\n"
               return -code error "Erreur de connexion à $rosconf(dbname) <$err> <$msg>"
            } else {
               gren_info "Connecté à $rosconf(dbname)\n"
               return -code 0 $connected
            }
         }
      }
      gren_info "$connected\n"
      return -code 0 $connected
   
   }

   # ==========================================================================================

   #--- namespace
   global sql
   global audace
   #--- extension MySQL
   set err [catch {load [concat $audace(rep_install) "/bin/libmysqltcl[info sharedlibextension]"]} msg]
   if {$err==1} {
      set err [catch {package require mysqltcl} msg]
   }
#   load libyd[info sharedlibextension]

   set err [catch {connect} msg]
   if {$err} {
#       gren_info "Erreur connexion Mysql\n"
#       gren_info "ERR:$err\n"
#       gren_info "MSG:$msg\n"
#  ::console::affiche_resultat "Erreur connexion Mysql\n"
#  ::console::affiche_resultat "ERR:$err\n"
#  ::console::affiche_resultat "MSG:$msg\n"
   }

}

