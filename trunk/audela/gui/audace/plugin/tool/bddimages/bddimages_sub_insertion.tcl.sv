# source audace/plugin/tool/bddimages/bddimages_subroutines.tcl

# ----------------------------------------
# Fonction : bddimages_insertion_unfich
# ----------------------------------------

# Insere une image

# ---------------------------------------
proc bddimages_insertion_unfich { ligne } {

  global bddconf

  uplevel #0 "source \"[ file join $bddconf(rep_plug) bddimages_sub_header.tcl ]\""

  set etat      [lindex $ligne 0]
  set nomfich   [lindex $ligne 1]
  set dateobs   [lindex $ligne 2]
  set site      [lindex $ligne 3]
  set sizefich  [lindex $ligne 4]
  set err       [lindex $ligne 5]
  set tabkey    [lindex $ligne 6]

  # --- Recupere la taille de l'image pour verifier si elle n est pas en cours de transfert
  set errnum [catch {set sizefichcurrent [file size $nomfich]} msg ]
  if {$errnum!=0} { 
    bddimages_sauve_fich "bddimages_insertion_unfich: Erreur taille de l image courante <$errnum> <$sizefichcurrent> <$msg>"
    if {$sizefichcurrent!=$sizefich} {
      return [list -1 $nomfich]
      }
    }

  set result [bddimages_formatfichier $nomfich]
  set form2  [lindex $result 0]
  set racinefich  [lindex $result 1]

  if {$form2=="fit"} {
     set racine [string range $nomfich 0 [expr [string length  $nomfich] - 5]]
     set nomfichdest "$racine.fits"
     bddimages_sauve_fich "bddimages_insertion_unfich: Deplacement de $nomfich vers $nomfichdest"
     set errnum [catch {file rename $nomfich $nomfichdest} msg]
     set nomfich $nomfichdest
     bddimages_sauve_fich "bddimages_insertion_unfich: Compression GZIP de $nomfich"
     gzip $nomfich
     set nomfich "$nomfichdest.gz"
     set form2 "fits.gz"
     }
  if {$form2=="fit.gz"} {
     set racine [string range $nomfich 0 [expr [string length  $nomfich] - 8]]
     set nomfichdest "$racine.fits.gz"
     bddimages_sauve_fich "bddimages_insertion_unfich: Deplacement de $nomfich vers $nomfichdest"
     set errnum [catch {file rename $nomfich $nomfichdest} msg]
     set nomfich $nomfichdest
     set form2 "fits.gz"
     }
  if {$form2=="fits"} {
     bddimages_sauve_fich "bddimages_insertion_unfich: Compression GZIP de $nomfich"
     gzip $nomfich
     set nomfich "$nomfich.gz"
     set form2 "fits.gz"
     }
  if {$form2=="cata.txt"} {
     bddimages_sauve_fich "bddimages_insertion_unfich: Compression GZIP de $nomfich"
     gzip $nomfich
     set nomfich "$nomfich.gz"
     set form2 "cata.txt.gz"
     }
  if {$form2=="fits.gz"} {

      # --- Reconnaissance du header FITS dans la base
      set liste [bddimages_header_id $tabkey]
      set err      [lindex $liste 0]
      set idheader [lindex $liste 1]
      #bddimages_sauve_fich "bddimages_insertion_unfich: type de header <IDHD=$idheader>"

      # --- Insertion des donnees dans la base
      if {$err==0} {
        set err [bddimages_images_datainsert $tabkey $idheader $nomfich $site $dateobs $sizefich]
      } else {
          set dirpb "$bddconf(direrr)"
          createdir_ifnot_exist $dirpb
          set dirpb "$bddconf(direrr)/$err"
          createdir_ifnot_exist $dirpb
          bddimages_sauve_fich "bddimages_insertion_unfich: Deplacement du fichier $nomfich dans $dirpb"
          set errnum [catch {file rename $nomfich $dirpb/} msg]
          if {$errnum!=0} {
            bddimages_sauve_fich "bddimages_insertion_unfich: ERREUR MV: Deplacement impossible"
            bddimages_sauve_fich "bddimages_insertion_unfich:      NUM : <$errnum>"
            bddimages_sauve_fich "bddimages_insertion_unfich:      MSG : <$msg>"
            }
        }
      }
      # Fin condition fichier fits.gz

  if {$form2=="cata.txt.gz"} {
# TODO
      puts "TODO: $nomfich"
      set err "CATA_TODO"
      }
      # Fin condition fichier cata.txt.gz

      return [list $err $nomfich]
  }
  # fin de bddimages_insertion





# ---------------------------------------

# bddimages_images_datainsert

# Insere nouvelle image dans la BDD
# 

# ---------------------------------------
proc bddimages_images_datainsert { tabkey idheader filename site dateobs sizefich } {

  global bddconf

  set etat 0

  # Detection de la date et site

  set annee [string range $dateobs 0 3]
  set mois  [string range $dateobs 5 6]
  set jour  [string range $dateobs 8 9]
  
  set dirfilename "fits/$site/$annee/$mois/$jour"

  # Insere nouvelle image dans la table images
   set fic [file tail "$filename"]
   set sqlcmd "INSERT INTO images (idheader, tabname, filename, dirfilename,sizefich,datemodif) VALUES "
   append sqlcmd "('$idheader', 'images_$idheader', '$fic', '$dirfilename','$sizefich',NOW())"

     # -- Execute la ligne SQL

   set err [catch {set resultsql [::bddimages_sql::sql query $sqlcmd]} msg]
   if {$err} {
      switch $msg {
        "::mysql::query/db server: Table 'bddimages.images' doesn't exist" {
          set sqlcmdcrea ""
          append sqlcmdcrea "CREATE TABLE IF NOT EXISTS images ("
          append sqlcmdcrea "  idbddimg bigint(20) NOT NULL auto_increment,"
          append sqlcmdcrea "  idheader int(11) NOT NULL,"
          append sqlcmdcrea "  tabname varchar(20) NOT NULL,"
          append sqlcmdcrea "  filename varchar(128) NOT NULL,"
          append sqlcmdcrea "  dirfilename varchar(128) NOT NULL,"
          append sqlcmdcrea "  sizefich int(20) NOT NULL,"
          append sqlcmdcrea "  datemodif DATETIME NOT NULL,"
          append sqlcmdcrea "  PRIMARY KEY  (idbddimg)"
          append sqlcmdcrea ") ENGINE=MyISAM;"

          set err [catch {::bddimages_sql::sql query $sqlcmdcrea} msg]
          if {$err} {
             bddimages_sauve_fich "bddimages_images_datainsert: ERREUR 101 : Creation table images <err=$err> <msg=$msg> <sql=$sqlcmdcrea>"
             return 101
             } else {
             bddimages_sauve_fich "bddimages_images_datainsert: Creation table images..."
            set resultsql ""
            set err [catch {set resultsql [::bddimages_sql::sql query $sqlcmd]} msg]
            if {$err} {
              bddimages_sauve_fich "bddimages_images_datainsert: ERREUR 102 : Impossible d inserer un element dans la table images <err=$err> <msg=$msg>"
              return 102
              } else {

              }
            }
          }
        default {
           bddimages_sauve_fich "bddimages_images_datainsert: ERREUR 103 : Impossible d acceder aux informations de bddimages.images <err=$err> <msg=$msg>"
           return 103
           }
        }
        # Fin switch
    } 
    set err [catch {::bddimages_sql::sql insertid} insert_idbddimg]
   # bddimages_sauve_fich "bddimages_images_datainsert: Insertion nouvel element dans la table images <$insert_idbddimg>"
   
  # -- Insere nouvelle image dans la table commun
   set datejj  [ mc_date2jd $dateobs ]
   set sqlcmd "INSERT INTO commun (idbddimg, datejj) VALUES "
   append sqlcmd "('$insert_idbddimg', '$datejj')"

     # -- Execute la ligne SQL

   set err [catch {set resultsql [::bddimages_sql::sql query $sqlcmd]} msg]
   if {$err} {
      switch $msg {
        "::mysql::query/db server: Table 'bddimages.commun' doesn't exist" {
          set sqlcmdcrea ""
          append sqlcmdcrea "CREATE TABLE IF NOT EXISTS commun ("
          append sqlcmdcrea "  idbddimg bigint(20) NOT NULL,"
          append sqlcmdcrea "  datejj double NOT NULL,"
          append sqlcmdcrea "  PRIMARY KEY  (idbddimg)"
          append sqlcmdcrea ") ENGINE=MyISAM;"

          set err [catch {::bddimages_sql::sql query $sqlcmdcrea} msg]
          if {$err} {
             bddimages_sauve_fich "bddimages_images_datainsert: ERREUR 101 : Creation table commun <err=$err> <msg=$msg> <sql=$sqlcmdcrea>"
             return 101
            } else {
             bddimages_sauve_fich "bddimages_images_datainsert: Creation table commun..."
             set resultsql ""
             set err [catch {set resultsql [::bddimages_sql::sql query $sqlcmd]} msg]
             if {$err} {
              bddimages_sauve_fich "bddimages_images_datainsert: ERREUR 102 : Impossible d inserer un element dans la table commun <err=$err> <msg=$msg>"
              return 102
              } else {

              }
            }
          }
        default {
           bddimages_sauve_fich "bddimages_images_datainsert: ERREUR 103 : Impossible d acceder aux informations de bddimages.commun <err=$err> <msg=$msg>"
           return 103
           }
        }
        # Fin switch
    } 
  
  
  
  # -- Insere nouvelle image dans la table images_$idheader

    # -- Creation ligne sql

  set sqlcmd  "`idbddimg`,"
  set sqlcmd2 "'$insert_idbddimg'," 

  foreach info $tabkey {    
    set tmp [bddimages_keywd_to_variable [lindex $info 0]]
    append sqlcmd "`$tmp`,"
    set tmp [lindex [lindex $info 1] 1]
    append sqlcmd2 "'$tmp',"
    }

  set sqlcmd  [string trimright $sqlcmd  ","]
  set sqlcmd2 [string trimright $sqlcmd2 ","]
  set sqlcmd "INSERT INTO images_$idheader ($sqlcmd) VALUES ($sqlcmd2);"

    # -- Execute la ligne SQL

  set err [catch {::bddimages_sql::sql query $sqlcmd} msg]
#  bddimages_sauve_fich "bddimages_images_datainsert: $sqlcmd <$err> <$msg>"
  if {$err} {
    bddimages_sauve_fich "bddimages_images_datainsert: ERREUR XXX : Ne peut inserer une nouvelle image dans la table images_$idheader <$err> <$msg>"

    set sqlcmd "DELETE FROM images WHERE idbddimg = $insert_idbddimg" 
    set err [catch {::bddimages_sql::sql query $sqlcmd} msg]
    if {$err} {
      bddimages_sauve_fich "bddimages_images_datainsert: ERREUR 107 : Impossible de supprimer l'image de la table images <idbddimg=$insert_idbddimg> <err=$err> <msg=$msg>"
      return 107
      }
    } else {
#      bddimages_sauve_fich "bddimages_images_datainsert: Enregistrement insere dans la table images_$idheader"
    }


  # -- Deplacement de l image sur le DD

    # -- Verification de l existance des repertoires
    set dirfilename "$bddconf(dirbase)/fits"
    createdir_ifnot_exist $dirfilename

    set dirfilename "$dirfilename/$site"
    createdir_ifnot_exist $dirfilename

    set dirfilename "$dirfilename/$annee"
    createdir_ifnot_exist $dirfilename

    set dirfilename "$dirfilename/$mois"
    createdir_ifnot_exist $dirfilename

    set dirfilename "$dirfilename/$jour"
    createdir_ifnot_exist $dirfilename

    # -- 
    set errnum [catch {file rename $filename $dirfilename/} msgcp]

      if {$errnum!=0} {

        bddimages_sauve_fich "bddimages_images_datainsert: Le fichier $filename existe dans $dirfilename"

        # -- Le fichier existe dans $dirfilename 
        set etat 1
	
        # -- -> on efface les enregistrements de la base
        set sqlcmd "DELETE FROM images WHERE idbddimg = $insert_idbddimg" 
        set err [catch {::bddimages_sql::sql query $sqlcmd} msg]
        if {$err} {
           bddimages_sauve_fich "bddimages_images_datainsert: ERREUR 108 : Impossible de supprimer l image de images <idbddimg=$insert_idbddimg> <err=$err> <msg=$msg>"
           return 108
           }
        bddimages_sauve_fich "bddimages_images_datainsert: Suppression de l'enregistrement dans images"

        # -- -> on efface les enregistrements de la base
        set sqlcmd "DELETE FROM commun WHERE idbddimg = $insert_idbddimg" 
        set err [catch {::bddimages_sql::sql query $sqlcmd} msg]
        if {$err} {
           bddimages_sauve_fich "bddimages_images_datainsert: ERREUR 109 : Impossible de supprimer l image de commun <idbddimg=$insert_idbddimg> <err=$err> <msg=$msg>"
           return 109
           }
        bddimages_sauve_fich "bddimages_images_datainsert: Suppression de l enregistrement dans commun"
        set sqlcmd "DELETE FROM images_$idheader WHERE idbddimg = $insert_idbddimg" 
        set err [catch {::bddimages_sql::sql query $sqlcmd} msg]
        if {$err} {
           bddimages_sauve_fich "bddimages_images_datainsert: ERREUR 110 : Impossible de supprimer l image de images_$idheader <idbddimg=$insert_idbddimg> <err=$err> <msg=$msg>"
           return 110
           }
        bddimages_sauve_fich "bddimages_images_datainsert: Suppression de l enregistrement dans images_$idheader"

        # -- -> on copie dans $bddconf(direrr)
        set errcp [string first "file already exists" $msgcp]
        if {$errcp>0} {

          set dirpb "$bddconf(direrr)"
          createdir_ifnot_exist $dirpb

          set dirpb "$bddconf(direrr)/filexist"
          set err [catch {set sizefichexist [file size $dirfilename/$fic]} msg ]
          if {!$err} {
            if {$sizefichexist<$sizefich} { 
	      set dirpb "$bddconf(direrr)/filexistsizebigger" 
              bddimages_sauve_fich "bddimages_images_datainsert: Fichier $dirfilename/$fic dans la base ($sizefichexist octets) dans incoming $filename ($sizefich octets)"	      
	      }
            if {$sizefichexist>$sizefich} { 
	      set dirpb "$bddconf(direrr)/filexistsizelower" 
              bddimages_sauve_fich "bddimages_images_datainsert: Fichier $dirfilename/$fic dans la base ($sizefichexist octets) dans incoming $filename ($sizefich octets)"	      
	      }
            }

          createdir_ifnot_exist $dirpb

          bddimages_sauve_fich "bddimages_images_datainsert: Copie du fichier $filename dans $dirpb"	      
          set errnum [catch {file rename $filename $dirpb/} msg]

          # -- le fichier existe dans $dirpb -> on efface $filename

          set errcp [string first "file already exists" $msg]
          if {$errcp>0||$errnum==0} {
            set errnum [catch {file delete $filename} msg]
            if {$errnum!=0} {
              bddimages_sauve_fich "bddimages_images_datainsert: ERREUR 111 : effacement de $filename impossible <err=$errnum> <msg=$msg>"
              return 111
              } else {
                bddimages_sauve_fich "bddimages_images_datainsert: Fichier $filename supprime"
                }
              # Fin if {$errnum!=0} ... file delete $filename
            }
            # Fin Le fichier existe dans $dirpb
          } else {
              bddimages_sauve_fich "bddimages_images_datainsert: ERREUR 112"
              bddimages_sauve_fich "bddimages_images_datainsert: 	NUM : <$errcp>" 
              bddimages_sauve_fich "bddimages_images_datainsert: 	MSG : <$msgcp>"
              bddimages_sauve_fich "bddimages_images_datainsert:    Copie de $filename vers $dirfilename/ impossible"
              bddimages_sauve_fich "bddimages_images_datainsert: 	NUM : <$errnum>" 
              bddimages_sauve_fich "bddimages_images_datainsert: 	MSG : <$msg>"
              return 112
            }
            # Fin if {$errcp>0} ... string first "file already exists" 

        } 
        # Fin if {$errnum!=0} ... else ... file copy $filename $dirfilename/
return $etat
}





# fin bddimages_images_datainsert

#        append sqlcmd "CREATE TABLE IF NOT EXISTS `images` ("
#        append sqlcmd "`idbddimg` bigint(20) NOT NULL auto_increment,"
#        append sqlcmd "`idimage` bigint(20) default NULL,"
#        append sqlcmd "`idcata` bigint(20) default NULL,"
#        append sqlcmd "`iduser` int(11) default NULL,"
#        append sqlcmd "`idscene` bigint(20) default NULL,"
#        append sqlcmd "`idreq` bigint(20) default NULL,"
#        append sqlcmd "`idtelescope` tinyint(4) default NULL,"
#        append sqlcmd "`jdmed` double default NULL,"
#        append sqlcmd ") TYPE = MYISAM ;"    

