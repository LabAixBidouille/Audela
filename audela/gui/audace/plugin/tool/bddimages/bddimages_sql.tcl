# source audace/plugin/tool/bddimages/bddimages_sql.tcl

#
# Fichier        : bddimages_sql.tcl
# Description    : Routines sql
# Auteur         : Frédéric Vachier
# Mise à jour $Id$
#

namespace eval bddimages_sql {

   global bddconf

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
      } elseif {$cmd=="exec"} {
         set texte [lindex $args 1]
         set sql(q) [::mysql::exec $sql(h) "$texte"]
         if {$sql(q)==-1} {
            return ""
         }
         return $sql(q)
      } else {
         error "usage : sql connect|disconnect|selectdb|query|insertid|getcolname"
      }
   }
   
   # ==========================================================================================
   # -- Connexion a bddimages --
   # ==========================================================================================
   proc connect { } {
   
      global bddconf
      set connected "$bddconf(dbname) @ $bddconf(server)"

      set err [catch {sql query "use $bddconf(dbname);"} msg]
      if {$err} {
         set err [catch {sql connect $bddconf(server) $bddconf(login) $bddconf(pass)} msg]
         if {$err} {
            return -code error "Erreur de connexion a MySql <$err> <$msg>" 
         } else {
            set err [catch {sql query "use $bddconf(dbname);"} msg]
            if {$err} {
               return -code error "Erreur de connexion a� $bddconf(dbname) <$err> <$msg>"
            } else {
               return -code 0 $connected
            }
         }
      }
      return -code 0 $connected
   
   }

   # ==========================================================================================

   #--- namespace
   global sql
   global audace

   #--- extension MySQL
   set lib [file join $audace(rep_install) bin "libmysqltcl[info sharedlibextension]"]
   set err [catch {load $lib} msg]
   if {$err == 1} {
      gren_erreur "Cannot load libmysqtcl[info sharedlibextension]\n"
   } else {
      set err [catch {package require mysqltcl} msg]
      gren_info "Mysql: mysqltcl $msg loaded\n"
   }

}

