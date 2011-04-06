#--------------------------------------------------
# source audace/plugin/tool/bddimages/bddimages_admin.tcl
#--------------------------------------------------
#
# Fichier        : bddimages_admin.tcl
# Description    : Manipulation des fichiers de config XML de bddimages
#                  
# Auteur         :  J. Berthier & Frédéric Vachier
# Mise à jour $Id$
#
#--------------------------------------------------
#
# - namespace bddimages_admin
#
#--------------------------------------------------
#
#   -- Fichiers source externe :
#
#  bddimages_admin.cap
#
#--------------------------------------------------
#
#  Structure de la liste image
#
# {               -- debut de liste
#
#   {             -- debut d une image
#
#     {ibddimg 1}
#     {ibddcata 2}
#     {filename toto.fits.gz}
#     {dirfilename /.../}
#     {filenametmp toto.fit}
#     {cataexist 1}
#     {cataloaded 1}
#     ...
#     {tabkey {{NAXIS1 1024} {NAXIS2 1024}} }
#     {cata {{{IMG {ra dec ...}{USNO {...]}}}} { { {IMG {4.3 -21.5 ...}} {USNOA2 {...}} } {source2} ... } } }
#
#   }             -- fin d une image
#
# }               -- fin de liste
#
#--------------------------------------------------
#
#  Structure du tabkey
#
# { {NAXIS1 1024} {NAXIS2 1024} etc ... }
#
#--------------------------------------------------
#
#  Structure du cata
#
# {               -- debut structure generale
#
#  {              -- debut des noms de colonne des catalogues
#
#   { IMG   {list field crossmatch} {list fields}} 
#   { TYC2  {list field crossmatch} {list fields}}
#   { USNO2 {list field crossmatch} {list fields}}
#
#  }              -- fin des noms de colonne des catalogues
#
#  {              -- debut des sources
#
#   {             -- debut premiere source
#
#    { IMG   {crossmatch} {fields}}  -> vue dans l image
#    { TYC2  {crossmatch} {fields}}  -> vue dans le catalogue
#    { USNO2 {crossmatch} {fields}}  -> vue dans le catalogue
#
#   }             -- fin premiere source
#
#  }              -- fin des sources
#
# }               -- fin structure generale
#
#--------------------------------------------------
#
#  Structure intellilist_i (dite inteligente)
#
#
# {
#   {name               ...  }
#   {datemin            ...  }
#   {datemax            ...  }
#   {type_req_check     ...  }
#   {type_requ          ...  }
#   {choix_limit_result ...  }
#   {limit_result       ...  }
#   {type_result        ...  }
#   {type_select        ...  }
#   {reqlist           { 
#                        { valide     ... }
#                        { condition  ... }
#                        { champ      ... }
#                        { valeur     ... }
#                      }
#
#   }
#
# }
#
#--------------------------------------------------
#
#  Structure intellilist_n (dite normale)
#
#
# {
#   {name               ...  }
#   {datemin            ...  }
#   {datemax            ...  }
#   {type_req_check     ...  }
#   {type_requ          ...  }
#   {choix_limit_result ...  }
#   {limit_result       ...  }
#   {type_result        ...  }
#   {type_select        ...  }
#   {reqlist            { 
#                         {image_34 {134 345 677}}
#                         {image_38 {135 344 679}}
#                       }
#
#   }
#
# }
#
#--------------------------------------------------

namespace eval ::bddimagesAdmin {
   package provide bddimagesAdmin 1.0
   global audace

   # Lecture des captions
   source [ file join [file dirname [info script]] bddimages_admin.cap ]

}

#--------------------------------------------------
#  ::bddimagesAdmin::sql_header { }
#--------------------------------------------------
# Permet de recuperer le nombre d'images dans la bddimages
# @return -nombre de header
#--------------------------------------------------
proc ::bddimagesAdmin::sql_nbimg { } {
   set sqlcmd ""
   append sqlcmd "SELECT count(*) FROM images;"
   set err [catch {set status [::bddimages_sql::sql query $sqlcmd]} msg]
   if {$err != 0} {
      ::console::affiche_erreur "ERREUR sql_nbimg\n"
      ::console::affiche_erreur "  SQL : <$sqlcmd>\n"
      ::console::affiche_erreur "  ERR : <$err>\n"
      ::console::affiche_erreur "  MSG : <$msg>\n"
      return "Table 'images' inexistantes"
   } else {
      return $msg
   }
}

#--------------------------------------------------
#  ::bddimagesAdmin::sql_header { }
#--------------------------------------------------
# Permet de recuperer le nombre de header dans la bddimages
# @return -nombre de header
#--------------------------------------------------
proc ::bddimagesAdmin::sql_header { } {
   set sqlcmd ""
   append sqlcmd "SELECT distinct idheader FROM header;"
   set err [catch {set status [::bddimages_sql::sql query $sqlcmd]} msg]
   if {$err != 0} {
      ::console::affiche_erreur "ERREUR sql_header\n"
      ::console::affiche_erreur "  SQL : <$sqlcmd>\n"
      ::console::affiche_erreur "  ERR : <$err>\n"
      ::console::affiche_erreur "  MSG : <$msg>\n"
      return "Table 'header' inexistantes"
   } else {
      return [llength $msg]
   }
}

#--------------------------------------------------
#  ::bddimagesAdmin::GetPassword { }
#--------------------------------------------------
# Demande d'un mot de passe utilisateur
# @param msg Message de demande du mot de passe
# @return -code err
#--------------------------------------------------
proc ::bddimagesAdmin::GetPassword { msg } {
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

   bind .passwd.f.gpass.v <Key-Return> { set getPassword(result) 1; destroy .passwd }
   
   grab set .passwd
   tkwait window .passwd
   if {$getPassword(result)} {
      return -code 0 $getPassword(passwd)
   } else {
      return -code error ""
   }
}

#--------------------------------------------------
#  ::bddimagesAdmin::RAZBdd { }
#--------------------------------------------------
# Reinitialise la base de donnees bddimages
# @return -code err
#--------------------------------------------------
proc ::bddimagesAdmin::RAZBdd { } {
   global caption
   global bddconf
   
   set answer [tk_messageBox -title $caption(bddimages_admin,msg_prevent) -message $caption(bddimages_admin,msg_prevent2) \
           -icon question -type okcancel ]
   switch -- $answer {
      ok {
         if { [catch {::bddimagesAdmin::GetPassword $caption(bddimages_admin,mdprootsql)} passwd ] != 0 } {
            ::console::affiche_erreur "$caption(bddimages_admin,cancelRAZ)\n"
            return
         }
         # Supprime la BDD
         set status "ok"
         if { [catch {::mysql::connect -host $bddconf(server) -user root -password $passwd} dblink] != 0 } {
            ::console::affiche_erreur "$dblink\n"
            set status "Error: $dblink"
         } else {
            if {$status == "ok"} {
               set sqlcmd "DROP DATABASE IF EXISTS $bddconf(dbname);"
               set err [catch {::mysql::query $dblink $sqlcmd} msg]
               if {$err} {
                  set status "Failed : \n <$sqlcmd> \n <$err> \n <$msg>"
               }
            }
            if {$status == "ok"} {
               set sqlcmd "CREATE DATABASE IF NOT EXISTS $bddconf(dbname);"
               set err [catch {::mysql::query $dblink $sqlcmd} msg]
               if {$err} {
                  set status "Failed : \n <$sqlcmd> \n <$err> \n <$msg>"
               }
            }
            if {$status=="ok"} {
               set sqlcmd "GRANT ALL PRIVILEGES ON `bddimages` . * TO '$bddconf(login)'@'$bddconf(server)' WITH GRANT OPTION ;"
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
         tk_messageBox -message "$caption(bddimages_admin,efface): $status" -type ok

         # Supprime le repertoire fits
         set errnum [catch {file delete -force $bddconf(dirfits)} msg]
         if {$errnum == 0} {
            ::console::affiche_resultat "Effacement du repertoire : $bddconf(dirfits) \n"
            set errnum [catch {file mkdir  $bddconf(dirfits)} msg]
            if {$errnum == 0} {
               ::console::affiche_resultat "Creation du repertoire : $bddconf(dirfits) \n"
            } else {
               ::console::affiche_resultat "ERREUR: Creation du repertoire : $bddconf(dirfits) impossible <$errnum>\n"
            }
         } else {
            ::console::affiche_resultat "ERREUR: Effacement du repertoire : $bddconf(dirfits) impossible <$errnum>\n"
         }
         
         # Supprime le repertoire logs
         set errnum [catch {file delete -force $bddconf(dirlog)} msg]
         if {$errnum == 0} {
            ::console::affiche_resultat "Effacement du repertoire : $bddconf(dirlog) \n"
            set errnum [catch {file mkdir  $bddconf(dirlog)} msg]
            if {$errnum == 0} {
               ::console::affiche_resultat "Creation du repertoire : $bddconf(dirlog) \n"
            } else {
               ::console::affiche_resultat "ERREUR: Creation du repertoire : $bddconf(dirlog) impossible <$errnum>\n"
            }
         } else {
            ::console::affiche_resultat "ERREUR: Effacement du repertoire : $bddconf(dirlog) impossible <$errnum>\n"
         }
         
         # Supprime le repertoire probleme
         set errnum [catch {file delete -force $bddconf(direrr)} msg]
         if {$errnum == 0} {
            ::console::affiche_resultat "Effacement du repertoire : $bddconf(direrr) \n"
            set errnum [catch {file mkdir  $bddconf(direrr)} msg]
            if {$errnum == 0} {
               ::console::affiche_resultat "Creation du repertoire : $bddconf(direrr) \n"
            } else {
               ::console::affiche_resultat "ERREUR: Creation du repertoire : $bddconf(direrr) impossible <$errnum>\n"
            }
         } else {
            ::console::affiche_resultat "ERREUR: Effacement du repertoire : $bddconf(direrr) impossible <$errnum>\n"
         }

      }
   }
}

#--------------------------------------------------
#  ::bddimagesAdmin::TestConnectBdd { }
#--------------------------------------------------
# Test la connection vers la base de donnees bddimages
# @return -code err
#--------------------------------------------------
proc ::bddimagesAdmin::TestConnectBdd { } {
   global bddconf
   global caption

   set status ""
   if { [catch {::mysql::connect -host $bddconf(server) -user $bddconf(login) -password $bddconf(pass) -db $bddconf(dbname)} dblink] != 0 } {
      set err 1
      set status "$caption(bddimages_admin,mysqlconnecterr)\n $dblink"
   } else {
      set sqlcmd "SHOW TABLES;"
      set err [catch {::mysql::query $dblink $sqlcmd} msg]
      if {$err != 0} {
         set status "$caption(bddimages_admin,mysqlshowerr)\n <$err>, <$msg>"
      } else {
         set status "$caption(bddimages_admin,mysqlok)"
      }
      # Fermeture connection
      ::mysql::close $dblink
      unset dblink
   }
   tk_messageBox -message "$status" -type ok
   return -code $err $status
}




#--------------------------------------------------
#  ::bddimagesAdmin::bdi_compatible { }
#--------------------------------------------------
# verifie la compatibilite de l image
# @return 1 si compatible 0 sinon
#--------------------------------------------------
proc ::bddimagesAdmin::bdi_compatible { bufno } {

   set compat 0

   set key [buf$bufno getkwd "BDDIMAGES VERSION"]
   if {[lindex $key 1] != 1 } {
      return $compat
   }
   set key [buf$bufno getkwd "BDDIMAGES STATE"]
   if {[lindex $key 0] == "" } {
      return $compat
   }
   set key [buf$bufno getkwd "BDDIMAGES TYPE"]
   if {[lindex $key 0] == "" } {
      return $compat
   }
   set key [buf$bufno getkwd "BDDIMAGES WCS"]
   if {[lindex $key 0] == "" } {
      return $compat
   }
   set key [buf$bufno getkwd "BDDIMAGES NAMECATA"]
   if {[lindex $key 0] == "" } {
      return $compat
   }
   set key [buf$bufno getkwd "BDDIMAGES DATECATA"]
   if {[lindex $key 0] == "" } {
      return $compat
   }
   set key [buf$bufno getkwd "BDDIMAGES ASTROID"]
   if {[lindex $key 0] == "" } {
      return $compat
   }
   set key [buf$bufno getkwd "BDDIMAGES ASTROMETRY"]
   if {[lindex $key 0] == "" } {
      return $compat
   }
   set key [buf$bufno getkwd "BDDIMAGES CATAASTROM"]
   if {[lindex $key 0] == "" } {
      return $compat
   }
   set key [buf$bufno getkwd "BDDIMAGES PHOTOMETRY"]
   if {[lindex $key 0] == "" } {
      return $compat
   }
   set key [buf$bufno getkwd "BDDIMAGES CATAPHOTOM"]
   if {[lindex $key 0] == "" } {
      return $compat
   }
   
   return 1
}

#--------------------------------------------------
#  ::bddimagesAdmin::bdi_setcompat { }
#--------------------------------------------------
# verifie la compatibilite de l image
# @return 1 si compatible 0 sinon
#--------------------------------------------------
proc ::bddimagesAdmin::bdi_setcompat { bufno } {

   set key [buf$bufno getkwd "BDDIMAGES VERSION"]
   if {[lindex $key 1] != 1 } {
      buf$bufno setkwd [list "BDDIMAGES VERSION" "1" "int" "Compatibility version for bddimages" ""]
   }
   set key [buf$bufno getkwd "BDDIMAGES STATE"]
   if {[lindex $key 0] == "" } {
      buf$bufno setkwd [list "BDDIMAGES STATE" "?" "string" "RAW | CORR | CATA | ?" ""]
   }
   set key [buf$bufno getkwd "BDDIMAGES TYPE"]
   if {[lindex $key 0] == "" } {
      buf$bufno setkwd [list "BDDIMAGES TYPE" "?" "string" "IMG | FLAT | DARK | OFFSET | ?" ""]
   }
   set key [buf$bufno getkwd "BDDIMAGES WCS"]
   if {[lindex $key 0] == "" } {
      buf$bufno setkwd [list "BDDIMAGES WCS" "?" "string" "Y | N | ? (WCS performed)" ""]
   }
   set key [buf$bufno getkwd "BDDIMAGES NAMECATA"]
   if {[lindex $key 0] == "" } {
      buf$bufno setkwd [list "BDDIMAGES NAMECATA" "?" "string" "Name file of the cata file" ""]
   }
   set key [buf$bufno getkwd "BDDIMAGES DATECATA"]
   if {[lindex $key 0] == "" } {
      buf$bufno setkwd [list "BDDIMAGES DATECATA" "?" "string" "Date iso when the cata file was modified" ""]
   }
   set key [buf$bufno getkwd "BDDIMAGES ASTROID"]
   if {[lindex $key 0] == "" } {
      buf$bufno setkwd [list "BDDIMAGES ASTROID" "?" "string" "ASTROID performed" ""]
   }
   set key [buf$bufno getkwd "BDDIMAGES ASTROMETRY"]
   if {[lindex $key 0] == "" } {
      buf$bufno setkwd [list "BDDIMAGES ASTROMETRY" "?" "string" "Astrometry performed" ""]
   }
   set key [buf$bufno getkwd "BDDIMAGES CATAASTROM"]
   if {[lindex $key 0] == "" } {
      buf$bufno setkwd [list "BDDIMAGES CATAASTROM" "?" "string" "Catalog used for astrometry" ""]
   }
   set key [buf$bufno getkwd "BDDIMAGES PHOTOMETRY"]
   if {[lindex $key 0] == "" } {
      buf$bufno setkwd [list "BDDIMAGES PHOTOMETRY" "?" "string" "Photometry performed" ""]
   }
   set key [buf$bufno getkwd "BDDIMAGES CATAPHOTOM"]
   if {[lindex $key 0] == "" } {
      buf$bufno setkwd [list "BDDIMAGES CATAPHOTOM" "?" "string" "Catalog used for photometry" ""]
   }

   # retire les mots cles         
   set dellist ""
   lappend dellist "BDDIMAGES RAW"
   lappend dellist "BDDIMAGES FLAT"
   lappend dellist "BDDIMAGES DARK"
   lappend dellist "BDDIMAGES OFFSET"
   lappend dellist "BDDIMAGES SFLAT"
   lappend dellist "BDDIMAGES SDARK"
   lappend dellist "BDDIMAGES SOFFSET"
   lappend dellist "BDDIMAGES STATES"
   lappend dellist "HIERARCH BDDIMAGES RAW"
   lappend dellist "HIERARCH BDDIMAGES FLAT"
   lappend dellist "HIERARCH BDDIMAGES DARK"
   lappend dellist "HIERARCH BDDIMAGES OFFSET"
   lappend dellist "HIERARCH BDDIMAGES SFLAT"
   lappend dellist "HIERARCH BDDIMAGES SDARK"
   lappend dellist "HIERARCH BDDIMAGES SOFFSET"
   lappend dellist "HIERARCH BDDIMAGES VERSION"
   lappend dellist "HIERARCH BDDIMAGES STATES"
   lappend dellist "HIERARCH BDDIMAGES STATE"
   lappend dellist "HIERARCH BDDIMAGES TYPE"
   lappend dellist "HIERARCH BDDIMAGES WCS"
   lappend dellist "HIERARCH BDDIMAGES NAMECATA"
   lappend dellist "HIERARCH BDDIMAGES DATECATA"
   lappend dellist "HIERARCH BDDIMAGES ASTROID"
   lappend dellist "HIERARCH BDDIMAGES ASTROMETRY"
   lappend dellist "HIERARCH BDDIMAGES CATAASTROM"
   lappend dellist "HIERARCH BDDIMAGES PHOTOMETRY"
   lappend dellist "HIERARCH BDDIMAGES CATAPHOTOM"

#      lappend dellist "BDDIMAGES RAW"
#      lappend dellist "BDDIMAGES FLAT"
#      lappend dellist "BDDIMAGES DARK"
#      lappend dellist "BDDIMAGES OFFSET"
#      lappend dellist "BDDIMAGES SFLAT"
#      lappend dellist "BDDIMAGES SDARK"
#      lappend dellist "BDDIMAGES SOFFSET"
#      lappend dellist "BDDIMAGES VERSION"
#      lappend dellist "BDDIMAGES STATES"
#      lappend dellist "BDDIMAGES STATE"
#      lappend dellist "BDDIMAGES TYPE"
#      lappend dellist "BDDIMAGES WCS"
#      lappend dellist "BDDIMAGES NAMECATA"
#      lappend dellist "BDDIMAGES DATECATA"
#      lappend dellist "BDDIMAGES ASTROID"
#      lappend dellist "BDDIMAGES ASTROMETRY"
#      lappend dellist "BDDIMAGES CATAASTROM"
#      lappend dellist "BDDIMAGES PHOTOMETRY"
#      lappend dellist "BDDIMAGES CATAPHOTOM"
   
   foreach del $dellist {
      set key [buf$bufno getkwd $del]
      if {[lindex $key 0] != "" } {
         buf$bufno delkwd $del
         ::console::affiche_resultat "DEL HEADKEY : $del \n"
      }
   }       

   return
}
