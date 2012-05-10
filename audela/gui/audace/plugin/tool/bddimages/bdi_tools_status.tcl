#--------------------------------------------------
# source audace/plugin/tool/bddimages/bdi_tools_status.tcl
#--------------------------------------------------
#
# Fichier        : bdi_tools_status.tcl
# Description    : Fonction du status de la base de donnees
# Auteur         : Frédéric Vachier
# Mise à jour $Id: bdi_tools_status.tcl 7048 2011-04-02 15:52:09Z fredvachier $
#

namespace eval ::bdi_tools_status {

variable err_sql    
variable err_file   
variable err_img    
variable err_img_hd 
variable err_nblist 
variable new_list_sql
variable new_list_dir
variable list_img
variable list_img_hd
variable err_doublon
variable list_doublon



   proc ::bdi_tools_status::get_idbddcata { idbddimg } {

      set sqlcmd "SELECT idbddcata FROM cataimage where idbddimg = $idbddimg;"
      set err [catch {set idbddcata [::bddimages_sql::sql query $sqlcmd]} msg]
      if {$err} {
         tk_messageBox -message "$caption(bdi_status,consoleErr2) $msg" -type ok
         return
      }
      if { $idbddcata != "" } {
         ::console::affiche_resultat "idbddcata : $idbddcata\n"
      } else {
         ::console::affiche_resultat "pas de cata\n"
         set idbddcata -1
      }
      return $idbddcata
   }











   proc ::bdi_tools_status::get_img_name { idbddimg } {

      global bddconf

      set sqlcmd "SELECT dirfilename,filename FROM images where idbddimg = $idbddimg;"
      set err [catch {set resultsql [::bddimages_sql::sql query $sqlcmd]} msg]
      if {$err} {
         tk_messageBox -message "$caption(bdi_status,consoleErr2) $msg" -type ok
         return
      }

      if { $resultsql != "" } {
         set dirfilename [lindex $resultsql 0]
         set filename    [lindex $resultsql 1]
         set src         [file join $bddconf(dirfits) $dirfilename $filename]
         return [list $bddconf(dirfits) $bddconf(dirfits) $dirfilename $src]
      } else {
         return ""
      }

   }






   proc ::bdi_tools_status::get_cata_name { idbddcata } {

      global bddconf
      global caption

      set sqlcmd "SELECT dirfilename,filename FROM catas where idbddcata = $idbddcata;"
      set err [catch {set resultsql [::bddimages_sql::sql query $sqlcmd]} msg]
      if {$err} {
         tk_messageBox -message "$caption(bdi_status,consoleErr2) $msg" -type ok
         return
      }

      if { $resultsql != "" } {
         set dirfilename [lindex $resultsql 0]
         set filename    [lindex $resultsql 1]
         set src         [file join $bddconf(dircata) $dirfilename $filename]
         return [list $bddconf(dircata) $dirfilename $filename $src]
      } else {
         return ""
      }

   }






   # Backup d un fichier quelconque existant sur le disque
   # Copie du fichier dans incoming
   proc ::bdi_tools_status::backup_name { name } {

         set base        [lindex $name 0]
         set dirfilename [lindex $name 1]
         set filename    [lindex $name 2]
         set src         [lindex $name 3]

         if { [file exists  $src] } {
            set dest [file join $bddconf(inco) $filename]
            set errmv [catch {[file copy $src $dest]} msg]
            if {$errmv} {
               # traiter l erreur
               ::console::affiche_erreur "Erreur : Copie de $src vers $dest\n"
               return -code 1 "Erreur : Copie de $src vers $dest\n"
            } else {
               ::console::affiche_resultat "Copie de $filename\n"
               return -code 0 "backup ok"
            }
         }


   }

   # Backup d un fichier fits existant sur le disque
   proc ::bdi_tools_status::backup_img { idbddimg } {

      global bddconf

      ::console::affiche_resultat "backup_img : $idbddimg \n"

      # regarde s il existe un cata
      set err [catch {set idbddcata [::bdi_tools_status::get_idbddcata $idbddimg]} msg]
      if { $idbddcata == -1 } {
          # n existe pas
      } else {
          if {[llength $idbddcata]>1} {
             foreach id $idbddcata {
                # backup du cata
                ::console::affiche_resultat "backup_img : backup_cata $id \n"
                ::bdi_tools_status::backup_cata $id
                
             }
          } else {
             # backup du cata
             ::console::affiche_resultat "backup_img : backup_cata $idbddcata \n"
             ::bdi_tools_status::backup_cata $idbddcata
          }
      }
      
      set err [catch {set name [::bdi_tools_status::get_img_name $idbddimg]} msg]
      if {$err} {
         ::console::affiche_erreur "Erreur get_img_name : err = $err msg = $msg\n"
      }
      if { $name == "" } {
          # n existe pas
      } else {
         set errbck [catch {::bdi_tools_status::backup_name $name} msg]
         if {$errbck} {
            ::console::affiche_erreur "Erreur bck : err = $errbck msg = $msg\n"
         }
      }

   }

   # Backup d un fichier cata existant sur le disque
   proc ::bdi_tools_status::backup_cata { idbddcata } {

      #::console::affiche_resultat "backup_cata : $idbddcata\n"

      set err [catch {set name [::bdi_tools_status::get_cata_name $idbddcata]} msg]
      if {$err} {
         ::console::affiche_erreur "Erreur get_cata_name : err = $err msg = $msg\n"
      }
      if { $name == "" } {
          # n existe pas
      } else {
         set errbck [catch {::bdi_tools_status::backup_name $name} msg]
         if {$errbck} {
            ::console::affiche_erreur "Erreur bck : err = $errbck msg = $msg\n"
         }
      }
   }














   # Effacement d un fichier quelconque existant sur le disque
   proc ::bdi_tools_status::delete_name { name } {

         set src [lindex $name 3]
         if { [file exists  $src] } {
            set errmv [catch {[file delete $src]} msg]
            if {$errmv} {
               # traiter l erreur
               ::console::affiche_erreur "Erreur : Effacement de $src\n"
               return -code 1 "Erreur : Effacement de $src\n"
            } else {
               ::console::affiche_resultat "Copie de $filename\n"
               return -code 0 "Effacement ok"
            }
         }

   }


   # effacement d un fichier fits du disque et de la base
   proc ::bdi_tools_status::delete_img { idbddimg } {

      ::console::affiche_resultat "delete_img : $idbddimg \n"
      # regarde s il existe un cata
      set err [catch {set idbddcata [::bdi_tools_status::get_idbddcata $idbddimg]} msg]
      if { $idbddcata == -1 } {
          # n existe pas
      } else {
          if {[llength $idbddcata]>1} {
             foreach id $idbddcata {
                ::console::affiche_resultat "delete_img : delete_cata $id \n"
                # delete du cata
                ::bdi_tools_status::delete_cata $id
             }
          } else {
             # delete du cata
             ::bdi_tools_status::delete_cata $idbddcata
          }
      }
      
      set err [catch {set name [::bdi_tools_status::get_img_name $idbddimg]} msg]
      if { $name == "" } {
          # n existe pas
      } else {
         set errdel [catch {::bdi_tools_status::delete_name $name} msg]
         if {$errdel} {
            ::console::affiche_erreur "Erreur del : err = $errdel msg = $msg\n"
            #return -code $errdel $msg
         }
      }
      
      set sqlcmd "SELECT idheader FROM images where idbddimg = $idbddimg;"
      set err [catch {set line [::bddimages_sql::sql query $sqlcmd]} msg]
      if {$err} {
         return -code 1 "inexistant dans la table 'images'"
      }
      ::console::affiche_resultat "nb : [llength $line]\n"
      set line     [lindex $line 0]
      set idheader [lindex $line 0]
      
      set sqlcmd "DELETE FROM images WHERE idbddimg = $idbddimg;"  
      set err [catch {set line [::bddimages_sql::sql query $sqlcmd]} msg]
      if {$err} {
         return -code 1 "Effacement dans la table 'images'"
      }
      set sqlcmd "DELETE FROM images_$idheader WHERE idbddimg = $idbddimg;"  
      set err [catch {set line [::bddimages_sql::sql query $sqlcmd]} msg]
      if {$err} {
         return -code 2 "Effacement dans la table 'images_$idheader'"
      }
   
   }













   proc ::bdi_tools_status::delete_cata { idbddcata } {

      ::console::affiche_resultat "delete_cata : $idbddcata \n"

      set err [catch {set name [::bdi_tools_status::get_cata_name $idbddcata]} msg]
      if { $name == "" } {
          # n existe pas
      } else {
         set errdel [catch {::bdi_tools_status::delete_name $name} msg]
         if {$errdel} {
            ::console::affiche_erreur "Erreur bck : err = $errdel msg = $msg\n"
         }
      }

      set sqlcmd "DELETE FROM catas WHERE idbddcata = $idbddcata;"  
      set err [catch {set line [::bddimages_sql::sql query $sqlcmd]} msg]
      if {$err} {
         return -code 1 "Effacement dans la table 'catas'"
      }
      set sqlcmd "DELETE FROM cataimage WHERE idbddcata = $idbddcata;"  
      set err [catch {set line [::bddimages_sql::sql query $sqlcmd]} msg]
      if {$err} {
         return -code 2 "Effacement dans la table 'cataimage'"
      }
   
   }










   
   
   proc ::bdi_tools_status::img_is_ok { x } {

      global bddconf


      if { [string is double -strict $x] } {  
         ::console::affiche_erreur "IMG_IS_OK: idbddimg = $x \n"
         set idbddimg $x
         
         # verif images
         set sqlcmd "SELECT idheader,filename,dirfilename,sizefich,datemodif FROM images where idbddimg = $idbddimg;"
         set err [catch {set data [::bddimages_sql::sql query $sqlcmd]} msg]
         if {$err} {
            return -code 1 "inexistant dans la table 'images'"
         }
         set nb [llength $data]
         ::console::affiche_resultat "nb : $nb\n"
         if {$nb>1} {
            return -code 1 "Plus d'une occurence dans la table 'images'"
         }
         if {$nb==0} {
            return -code 1 "n'existe pas dans la table 'images'"
         }
         set line        [lindex $data 0]
         set idheader    [lindex $line 0]
         set filename    [lindex $line 1]
         set dirfilename [lindex $line 2]
         
         # verif images_$idheader
         set sqlcmd "SELECT * FROM images_$idheader where idbddimg = $idbddimg;"
         set err [catch {set data [::bddimages_sql::sql query $sqlcmd]} msg]
         if {$err} {
            return -code 1 "inexistant dans la table 'images_$idheader'"
         }
         set nb [llength $data]
         ::console::affiche_resultat "nb : $nb\n"
         if {$nb>1} {
            return -code 1 "Plus d'une occurence dans la table 'images_$idheader'"
         }
         if {$nb==0} {
            return -code 1 "n'existe pas dans la table 'images_$idheader'"
         }
         # verif file
         set f [file join $bddconf(dirbase) $dirfilename $filename]
         if { ! [file exists f]} {
            ::console::affiche_erreur "inexistant sur le disque $f"
            return -code 2 "inexistant sur le disque $f"
         }




      } else {
         ::console::affiche_resultat "IMG_IS_OK: file = $x\n"
         set r [file rootname $x]
         set r [file rootname $r]
         set r [file tail $r]
         ::console::affiche_resultat "recherche $r\n"
         set sqlcmd "SELECT idbddimg,idheader,filename,dirfilename,sizefich,datemodif FROM images where filename like '${r}.fits.gz';"
         set err [catch {set data [::bddimages_sql::sql query $sqlcmd]} msg]
         if {$err} {
            return -code 1 "inexistant dans la table 'images'"
         }
         #::console::affiche_resultat "line : $data\n"
         ::console::affiche_resultat "nb : [llength $data]\n"
         ::console::affiche_resultat "x : $x \n"
         
         set pass "no"
         set cpt 0
         foreach line $data {

gren_info "++++ DATA = $line\n"

            set idbddimg    [lindex $line 0]
            set idheader    [lindex $line 1]
            set filename    [lindex $line 2]
            set dirfilename [lindex $line 3]
            set sizefich    [lindex $line 4]
            set datemodif   [lindex $line 5]
         
            set f [file join $bddconf(dirbase) $dirfilename $filename]
            ::console::affiche_resultat "idbddimg $idbddimg $f\n"
            if {$f == $x} {
              ::console::affiche_resultat "idbddimg $idbddimg $f\n"
               incr cpt
               set pass "yes"
               if { ! [file exists f]} {
                  ::console::affiche_erreur "inexistant sur le disque $f"
                  return -code 2 "inexistant sur le disque $f"
               }

               set sqlcmd "SELECT idbddimg FROM images_$idheader where idbddimg = $idbddimg;"
               set err [catch {set result [::bddimages_sql::sql query $sqlcmd]} msg]
               if {$err||$idbddimg==""} {
                  ::console::affiche_erreur "inexistant dans la table 'images_idhd'"
                  return -code 3 "inexistant dans la table 'images_idhd'"
               }
            }

         }
         
         if {$cpt > 1 } {
            ::console::affiche_erreur "plusieurs occurences\n"
            return -code 1 "plusieurs occurences"
         }
         
         if {$pass == "no" } {
            ::console::affiche_erreur "1 Le nom de l'image n'est pas coherent avec celui de la table 'images'\n"
            ::console::affiche_erreur "  filename    = $filename \n"
            ::console::affiche_erreur "  dirfilename = $dirfilename \n"
            ::console::affiche_erreur "  x           = $x \n"

            return -code 1 "1 Le nom de l'image n'est pas coherent avec celui de la table 'images'\n"
         }
         
      }

      return code 0 "ok"
   }

















   proc ::bdi_tools_status::repare { } {
      
      global bddconf
      global caption

      ::console::affiche_resultat "Reparation \n"
      
      ::console::affiche_resultat "err_sql    = $::bdi_tools_status::err_sql    \n"
      ::console::affiche_resultat "err_file   = $::bdi_tools_status::err_file   \n"
      ::console::affiche_resultat "err_img    = $::bdi_tools_status::err_img    \n"
      ::console::affiche_resultat "err_img_hd = $::bdi_tools_status::err_img_hd \n"
      ::console::affiche_resultat "err_nblist = $::bdi_tools_status::err_nblist \n"


      if { $::bdi_tools_status::err_sql == "yes" } {
      

         ::console::affiche_resultat "LIST SQL : AFAIRE \n"
         foreach elem $::bdi_tools_status::new_list_sql {
            ::console::affiche_resultat "($elem)\n"
             set isd [file isdirectory $elem]
             set isf [file isfile $elem]
             #::console::affiche_resultat "$isd $isf $elem \n"
             if {$isd == 1} {
                ::console::affiche_erreur "repertoire : $elem \n"
                continue
             } else {
                if {$isf == 1} {
                   ::console::affiche_resultat "file ($elem)\n"
                }
             }
         }
         ::console::affiche_resultat "NB SQL : [llength $::bdi_tools_status::new_list_sql]\n"

         ::console::affiche_resultat "LIST SQL : PROCEDE  \n"
         foreach elem $::bdi_tools_status::new_list_sql {

            ::console::affiche_resultat "*** SQL:($elem) is_ok ? -> \n"
            set err [catch {::bdi_tools_status::img_is_ok $elem} msg]
            ::console::affiche_resultat "*** ($elem) is_ok ! (err $err msg $msg)\n"

            if {$err} {

                 set f [file tail $elem]
                 set r [file rootname $elem]
                 set r [file rootname $r]
                 set r [file tail $r]

                 set sqlcmd "SELECT idbddimg,filename,dirfilename FROM images where filename like '${r}.fits.gz';"
                 set errsel [catch {set data [::bddimages_sql::sql query $sqlcmd]} msg]
                 if {$errsel} {
                    tk_messageBox -message "$caption(bdi_status,consoleErr2) $msg" -type ok
                    return
                 }

                 # Backup lorsque err == 1
                 if {$err==1 || $data==""} {
                     ::console::affiche_resultat "deplacement de $f dans incoming\n"
                     set dest [file join $bddconf(dirfits) $f]
                     set errmv [catch {[file rename $elem $dest]} msg]
                 }

                 if {$data!=""} {

                    set pass "no"
                    set cpt 0
                    foreach line $data {
                       set idbddimg    [lindex $line 0]
                       set filename    [lindex $line 1]
                       set dirfilename [lindex $line 2]
                       set f [file join $bddconf(dirbase) $dirfilename $filename]
                       if {$f == $elem} {
                          incr cpt
                          set pass "yes"
                          set pass_idbddimg $idbddimg
                       }
                    }
                    if {$cpt > 1 } {
                       ::console::affiche_erreur "plusieurs occurences\n"
                       return -code 1 "plusieurs occurences"
                    }

                    if {$pass == "no" } {
                       ::console::affiche_erreur "2 Le nom de l'image n'est pas coherent avec celui de la table 'images'\n"
                       return -code 2 "2 Le nom de l'image n'est pas coherent avec celui de la table 'images'\n"
                    }

                    if {$pass == "yes" } {
                       ::console::affiche_erreur "BACKUP $pass_idbddimg\n"
                       # Backup
                       ::bdi_tools_status::backup_img $pass_idbddimg
                       # Delete
                       ::bdi_tools_status::delete_img $pass_idbddimg
                    }
                 }

            }

            set ::bdi_tools_status::new_list_sql [lrange $::bdi_tools_status::new_list_sql 1 end]
break
         }
      
      }
    
    






      if { $::bdi_tools_status::err_file == "yes" } {
    
         ::console::affiche_resultat "LIST FILE : AFAIRE \n"
         foreach elem $::bdi_tools_status::new_list_dir {
            ::console::affiche_resultat "($elem)\n"
             set isd [file isdirectory $elem]
             set isf [file isfile $elem]
             #::console::affiche_resultat "$isd $isf $elem \n"
             if {$isd == 1} {
                ::console::affiche_erreur "repertoire : $elem \n"
                continue
             } else {
                if {$isf == 1} {
                   ::console::affiche_resultat "file ($elem)\n"
                }
             }
         }
         ::console::affiche_resultat "NB FILE : [llength $::bdi_tools_status::new_list_dir]\n"

         ::console::affiche_resultat "LIST FILE : PROCEDE  \n"
         foreach elem $::bdi_tools_status::new_list_dir {




            ::console::affiche_resultat "*** SQL:($elem) is_ok ? -> \n"
            set err [catch {::bdi_tools_status::img_is_ok $elem} msg]
           ::console::affiche_resultat "*** ($elem) is_ok ! (err $err msg $msg)\n"
         
            if {$err} {

                 set f [file tail $elem]
                 set r [file rootname $elem]
                 set r [file rootname $r]
                 set r [file tail $r]

                 set sqlcmd "SELECT idbddimg,filename,dirfilename FROM images where filename like '${r}.fits.gz';"
                 set errsel [catch {set data [::bddimages_sql::sql query $sqlcmd]} msg]
                 if {$errsel} {
                    tk_messageBox -message "$caption(bdi_status,consoleErr2) $msg" -type ok
                    return
                 }

                 # Backup lorsque err == 1
                 if {$err==1 || $data==""} {
                     set dest [file join $bddconf(dirinco) $f]
                     ::console::affiche_resultat "fits : deplacement de $elem vers $dest\n"
                     set ex [file exists $dest]
                     if {$ex==1} {
                        ::console::affiche_erreur "Le fichier destination existe\n"
                        catch{set size1 [file size $elem]}
                        catch{set size2 [file size $dest]}
                        ::console::affiche_resultat "size : $size1 $size2\n"
                        if {$size1==$size2} {
                           set errdel [catch {[file delete $elem]} msg]
                           if {$errdel} {
                              ::console::affiche_erreur "effacement de $elem : $msg\n"
                           }
                        } else {
                              ::console::affiche_erreur "fichiers differents ($elem $size1) ($dest $size2)\n"
                        }
                     } else {
                        set errmv [catch {[file rename -force -- $elem $dest]} msg]
                        if {$errmv} {
                           #::console::affiche_erreur "deplacement de $elem vers $dest : $errmv $msg\n"
                        }
                     }
                 }

                 if {$data!=""} {

                    set pass "no"
                    set cpt 0
                    foreach line $data {
                       set idbddimg    [lindex $line 0]
                       set filename    [lindex $line 1]
                       set dirfilename [lindex $line 2]
                       set f [file join $bddconf(dirbase) $dirfilename $filename]
                       if {$f == $elem} {
                          incr cpt
                          set pass "yes"
                          set pass_idbddimg $idbddimg
                       }
                    }
                    if {$cpt > 1 } {
                       ::console::affiche_erreur "plusieurs occurences\n"
                       return -code 1 "plusieurs occurences"
                    }

                    if {$pass == "no" } {
                       ::console::affiche_erreur "3 pLe nom de l'image n'est pas coherent avec celui de la table 'images'\n"
                       return -code 3 "3 lLe nom de l'image n'est pas coherent avec celui de la table 'images'\n"
                    }

                    if {$pass == "yes" } {
                       ::console::affiche_erreur "BACKUP $pass_idbddimg\n"
                       # Backup
                       ::bdi_tools_status::backup_img $pass_idbddimg
                       # Delete
                       ::bdi_tools_status::delete_img $pass_idbddimg
                    }
                 }

            }

            set ::bdi_tools_status::new_list_dir [lrange $::bdi_tools_status::new_list_dir 1 end]
break
         }
    
      }
      
      
      
      if { $::bdi_tools_status::err_img == "yes" } {
    

         ::console::affiche_resultat "LIST IMG : AFAIRE \n"
         foreach elem $::bdi_tools_status::list_img {
            ::console::affiche_resultat "($elem)\n"
             set isd [file isdirectory $elem]
             set isf [file isfile $elem]
             #::console::affiche_resultat "$isd $isf $elem \n"
             if {$isd == 1} {
                ::console::affiche_erreur "repertoire : $elem \n"
                continue
             } else {
                if {$isf == 1} {
                   ::console::affiche_resultat "file ($elem)\n"
                }
             }
         }
         ::console::affiche_resultat "NB IMG : [llength $::bdi_tools_status::list_img]\n"
         ::console::affiche_resultat "LIST IMG : PROCEDE  \n"

         foreach elem $::bdi_tools_status::list_img {

            ::console::affiche_resultat "*** SQL:($elem) is_ok ? -> \n"
            set err [catch {::bdi_tools_status::img_is_ok $elem} msg]
           ::console::affiche_resultat "*** ($elem) is_ok ! (err $err msg $msg)\n"

            if {$err} {
               # Backup
               ::bdi_tools_status::backup_img $elem
               # Delete
               ::bdi_tools_status::delete_img $elem
            }
            #set ::bdi_tools_status::list_img [lrange $::bdi_tools_status::list_img 1 end]
         }


      }






      if { $::bdi_tools_status::err_img_hd == "yes" } {
    
         ::console::affiche_resultat "LIST IMGHD : AFAIRE \n"

         foreach elem $::bdi_tools_status::list_img_hd {
            ::console::affiche_resultat "($elem)\n"
             set isd [file isdirectory $elem]
             set isf [file isfile $elem]
             #::console::affiche_resultat "$isd $isf $elem \n"
             if {$isd == 1} {
                ::console::affiche_erreur "repertoire : $elem \n"
                continue
             } else {
                if {$isf == 1} {
                   ::console::affiche_resultat "file ($elem)\n"
                }
             }
         }
         ::console::affiche_resultat "NB IMG : [llength $::bdi_tools_status::list_img_hd]\n"
         ::console::affiche_resultat "LIST IMGHD : PROCEDE  \n"

         foreach elem $::bdi_tools_status::list_img_hd {

            ::console::affiche_resultat "*** SQL:($elem) is_ok ? -> \n"
            set err [catch {::bdi_tools_status::img_is_ok $elem} msg]
           ::console::affiche_resultat "*** ($elem) is_ok ! (err $err msg $msg)\n"

            if {$err} {

               set sqlcmd "SELECT DISTINCT idheader FROM header;"
               set errsel [catch {set data [::bddimages_sql::sql query $sqlcmd]} msg]
               if {$errsel} {
                  tk_messageBox -message "$caption(bdi_status,consoleErr2) $msg" -type ok
                  return
               }
               if {$errsel==1 || $data==""} {
                  ::console::affiche_erreur "pas de header ($errsel) ($msg) ($data)\n"
               }
               if {$data!=""} {
                  foreach idhd $data {
                     set sqlcmd "DELETE FROM images_$idhd where idbddimg = $elem;"
                     set errdel [catch {::bddimages_sql::sql query $sqlcmd} msg]
                     if {$errdel} {
                        tk_messageBox -message "$caption(bdi_status,consoleErr2) $msg" -type ok
                        return
                     }
                  }
               }
            }
            #set ::bdi_tools_status::list_img [lrange $::bdi_tools_status::list_img 1 end]
break
         }
      }




      if { $::bdi_tools_status::err_nblist == "yes" } {

         # Un raison peut etre un champ vide dans la table image
         set sqlcmd "DELETE FROM images where filename ='';"
         set errdel [catch {::bddimages_sql::sql query $sqlcmd} msg]
         if {$errdel} {
            tk_messageBox -message "$caption(bdi_status,consoleErr2) $msg" -type ok
            return
         }


      }
      

      if { $::bdi_tools_status::err_doublon == "yes" } {


         foreach elem $::bdi_tools_status::list_doublon {

            ::console::affiche_resultat "DOUBLON : $elem\n"
            
            set f [file tail $elem]
            set r [file rootname $elem]
            set r [file rootname $r]
            set r [file tail $r]

            set sqlcmd "SELECT idbddimg,filename,dirfilename FROM images where filename like '${r}.fits.gz';"
            set errsel [catch {set data [::bddimages_sql::sql query $sqlcmd]} msg]
            if {$errsel} {
               tk_messageBox -message "$caption(bdi_status,consoleErr2) $msg" -type ok
               return
            }
gren_info "Long DATA = [llength $data]\n"

            # Backup lorsque err == 1
            if {$errsel==1 || $data==""} {
                set dest [file join $bddconf(dirinco) $f]
                ::console::affiche_resultat "fits : deplacement de $elem vers $dest\n"
                set errmv [catch {[file rename -force -- $elem $dest]} msg]
                if {$errmv} {
                   #::console::affiche_erreur "deplacement de $elem vers $dest : $errmv $msg\n"
                }
            }

            if {$data!=""} {

               set pass "no"
               set cpt 0
               foreach line $data {
                  set idbddimg    [lindex $line 0]
                  set filename    [lindex $line 1]
                  set dirfilename [lindex $line 2]
                  set f [file join $bddconf(dirbase) $dirfilename $filename]
                  if {$f == $elem} {
                     incr cpt
                     set pass "yes"
                     set pass_idbddimg $idbddimg
                  }
               }
               if {$cpt > 1 } {
                  ::console::affiche_erreur "plusieurs occurences\n"
                  return -code 1 "plusieurs occurences"
               }

               if {$pass == "no" } {
                  ::console::affiche_erreur "4 Le nom de l'image n'est pas coherent avec celui de la table 'images'\n"
                  ::console::affiche_erreur "  f    = $f\n"
                  ::console::affiche_erreur "  elem = $elem\n"
                 return -code 4 "4 Le nom de l'image n'est pas coherent avec celui de la table 'images' \n"
               }

               if {$pass == "yes" } {
                  ::console::affiche_erreur "BACKUP $pass_idbddimg\n"
                  # Backup
                  ::bdi_tools_status::backup_img $pass_idbddimg
                  # Delete
                  ::bdi_tools_status::delete_img $pass_idbddimg
               }
            }


            ::console::affiche_erreur "REPARATION du doublon $elem\n"
            set ::bdi_tools_status::list_doublon [lrange $::bdi_tools_status::list_doublon 1 end]
            
break
            
# fin foreach            
         }
      
      }

      
   }

}
