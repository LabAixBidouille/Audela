#
# Fichier : ros_xml.tcl
# Description : Manipulation des fichiers de config XML de ros
#
# Auteur : J. Berthier & F. Vachier
# Mise à jour $Id: ros_admin.tcl,v 1.1 2011-02-19 20:43:49 fredvachier Exp $
#

namespace eval ::rosAdmin {
   package provide rosAdmin 1.0
   global audace

   # Lecture des captions
   source [ file join [file dirname [info script]] ros_admin.cap ]

}

#--------------------------------------------------
#  ::rosAdmin::sql_header { }
#--------------------------------------------------
# Permet de recuperer le nombre d'images dans la ros
# @return -nombre de header
#--------------------------------------------------
proc ::rosAdmin::sql_nbrequetes { } {
   set sqlcmd ""
   append sqlcmd "SELECT count(*) FROM requests;"
   set err [catch {set status [::ros_sql::sql query $sqlcmd]} msg]
   if {$err != 0} {
      ::console::affiche_erreur "ERREUR sql_nbrequetes\n"
      ::console::affiche_erreur "  SQL : <$sqlcmd>\n"
      ::console::affiche_erreur "  ERR : <$err>\n"
      ::console::affiche_erreur "  MSG : <$msg>\n"
      return -code $err "Table 'requests' inexistantes"
   } else {
      return $status
   }
}

#--------------------------------------------------
#  ::rosAdmin::sql_header { }
#--------------------------------------------------
# Permet de recuperer le nombre de header dans la ros
# @return -nombre de header
#--------------------------------------------------
proc ::rosAdmin::sql_nbscenes { } {
   set sqlcmd ""
   append sqlcmd "SELECT count(*) FROM scenes;"
   set err [catch {set status [::ros_sql::sql query $sqlcmd]} msg]
   if {$err != 0} {
      ::console::affiche_erreur "ERREUR sql_nbscenes\n"
      ::console::affiche_erreur "  SQL : <$sqlcmd>\n"
      ::console::affiche_erreur "  ERR : <$err>\n"
      ::console::affiche_erreur "  MSG : <$msg>\n"
      return -code $err "Table 'scenes' inexistantes"
   } else {
      return $status
   }
}

#--------------------------------------------------
#  ::rosAdmin::GetPassword { }
#--------------------------------------------------
# Demande d'un mot de passe utilisateur
# @param msg Message de demande du mot de passe
# @return -code err
#--------------------------------------------------
proc ::rosAdmin::GetPassword { msg } {
   global getPassword
   # getPassword est un tableau qui va contenir 3 entrées:
   #   name   contient le nom de l'utilisateur
   #   passwd contient son mot de passe
   #   result contient 1 si et seulement si l'utilisateur a cliqué sur Ok
   set getPassword(result) 0
   set getPassword(passwd) ""

   toplevel .passwd
   wm title .passwd "Root password"
   wm positionfrom .passwd user
   wm sizefrom .passwd user
   frame .passwd.f -relief groove
   pack configure .passwd.f -side top -fill both -expand 1 -padx 10 -pady 10

   # Frame qui va contenir le label "Type your password:" et une entrée pour le rentrer
   frame .passwd.f.pass
   pack configure .passwd.f.pass -side top -fill x
     label .passwd.f.pass.e -text $msg
     pack configure .passwd.f.pass.e -side left -anchor c

   # L'option -show permet de masquer la véritable entrée, 
   # et de mettre une étoile à la place des caractères saisis
   frame .passwd.f.gpass
   pack configure .passwd.f.gpass -side top -fill x
     entry .passwd.f.gpass.v -textvariable getPassword(passwd) -show "*"
     pack configure .passwd.f.gpass.v -side bottom -anchor c

   # Frame qui va contenir les boutons Cancel et Ok
   frame .passwd.f.buttons
   pack configure .passwd.f.buttons -side top -fill x
     button .passwd.f.buttons.cancel -text Cancel -command {destroy .passwd}
     pack configure .passwd.f.buttons.cancel -side left
     button .passwd.f.buttons.ok -text Ok -command { set getPassword(result) 1; destroy .passwd }
     pack configure .passwd.f.buttons.ok -side right

   grab set .passwd
   tkwait window .passwd
   if {$getPassword(result)} {
      return -code 0 $getPassword(passwd)
   } else {
      return -code error ""
   }
}

#--------------------------------------------------
#  ::rosAdmin::RAZBdd { }
#--------------------------------------------------
# Reinitialise la base de donnees ros
# @return -code err
#--------------------------------------------------
proc ::rosAdmin::RAZBdd { } {
   global caption
   global rosconf
   
   set answer [tk_messageBox -title $caption(ros_admin,msg_prevent) -message $caption(ros_admin,msg_prevent2) \
           -icon question -type okcancel ]
   switch -- $answer {
      ok {
         if { [catch {::rosAdmin::GetPassword $caption(ros_admin,mdprootsql)} passwd ] != 0 } {
            ::console::affiche_erreur "$caption(ros_admin,cancelRAZ)\n"
            return
         }
         # Supprime la BDD
         set status "ok"
         if { [catch {::mysql::connect -host $rosconf(server) -user root -password $passwd} dblink] != 0 } {
            ::console::affiche_erreur "$dblink\n"
            set status "Error: $dblink"
         } else {
            if {$status == "ok"} {
               set sqlcmd "DROP DATABASE IF EXISTS $rosconf(dbname);"
               set err [catch {::mysql::query $dblink $sqlcmd} msg]
               if {$err} {
                  set status "Failed : \n <$sqlcmd> \n <$err> \n <$msg>"
               }
            }
            if {$status == "ok"} {
               set sqlcmd "CREATE DATABASE IF NOT EXISTS $rosconf(dbname);"
               set err [catch {::mysql::query $dblink $sqlcmd} msg]
               if {$err} {
                  set status "Failed : \n <$sqlcmd> \n <$err> \n <$msg>"
               }
            }
            if {$status=="ok"} {
               set sqlcmd "GRANT ALL PRIVILEGES ON `ros` . * TO '$rosconf(login)'@'$rosconf(server)' WITH GRANT OPTION ;"
               set err [catch {::mysql::query $dblink $sqlcmd} msg]
               if {$err} {
                  set status "Failed : \n <$sqlcmd> \n <$err> \n <$msg>"
               }
            }
            # Fermeture connection
            ::mysql::close $dblink
            unset dblink
         }
         # Message 
         tk_messageBox -message "$caption(ros_admin,efface): $status" -type ok

         # Supprime le repertoire fits
         set errnum [catch {file delete -force $rosconf(dirfits)} msg]
         if {$errnum == 0} {
            ::console::affiche_resultat "Effacement du repertoire : $rosconf(dirfits) \n"
            set errnum [catch {file mkdir  $rosconf(dirfits)} msg]
            if {$errnum == 0} {
               ::console::affiche_resultat "Creation du repertoire : $rosconf(dirfits) \n"
            } else {
               ::console::affiche_resultat "ERREUR: Creation du repertoire : $rosconf(dirfits) impossible <$errnum>\n"
            }
         } else {
            ::console::affiche_resultat "ERREUR: Effacement du repertoire : $rosconf(dirfits) impossible <$errnum>\n"
         }
         
         # Supprime le repertoire logs
         set errnum [catch {file delete -force $rosconf(dirlog)} msg]
         if {$errnum == 0} {
            ::console::affiche_resultat "Effacement du repertoire : $rosconf(dirlog) \n"
            set errnum [catch {file mkdir  $rosconf(dirlog)} msg]
            if {$errnum == 0} {
               ::console::affiche_resultat "Creation du repertoire : $rosconf(dirlog) \n"
            } else {
               ::console::affiche_resultat "ERREUR: Creation du repertoire : $rosconf(dirlog) impossible <$errnum>\n"
            }
         } else {
            ::console::affiche_resultat "ERREUR: Effacement du repertoire : $rosconf(dirlog) impossible <$errnum>\n"
         }
         
         # Supprime le repertoire probleme
         set errnum [catch {file delete -force $rosconf(direrr)} msg]
         if {$errnum == 0} {
            ::console::affiche_resultat "Effacement du repertoire : $rosconf(direrr) \n"
            set errnum [catch {file mkdir  $rosconf(direrr)} msg]
            if {$errnum == 0} {
               ::console::affiche_resultat "Creation du repertoire : $rosconf(direrr) \n"
            } else {
               ::console::affiche_resultat "ERREUR: Creation du repertoire : $rosconf(direrr) impossible <$errnum>\n"
            }
         } else {
            ::console::affiche_resultat "ERREUR: Effacement du repertoire : $rosconf(direrr) impossible <$errnum>\n"
         }

      }
   }
}

#--------------------------------------------------
#  ::rosAdmin::TestConnectBdd { }
#--------------------------------------------------
# Test la connection vers la base de donnees ros
# @return -code err
#--------------------------------------------------
proc ::rosAdmin::TestConnectBdd { } {
   global rosconf
   global caption

   set status ""
   if { [catch {::mysql::connect -host $rosconf(server) -user $rosconf(login) -password $rosconf(pass) -db $rosconf(dbname)} dblink] != 0 } {
      set err 1
      set status "$caption(ros_admin,mysqlconnecterr)\n $dblink"
   } else {
      set sqlcmd "SHOW TABLES;"
      set err [catch {::mysql::query $dblink $sqlcmd} msg]
      if {$err != 0} {
         set status "$caption(ros_admin,mysqlshowerr)\n <$err>, <$msg>"
      } else {
         set status "$caption(ros_admin,mysqlok)"
      }
      # Fermeture connection
      ::mysql::close $dblink
      unset dblink
   }
   tk_messageBox -message "$status" -type ok
   return -code $err $status
}
