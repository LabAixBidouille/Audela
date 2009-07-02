# ----------------------------------------

# bddimages_keywd_to_variable

# transforme un mot cle du header en
# variable pour la BDD

# ---------------------------------------
proc bddimages_keywd_to_variable { key } {

#  set tmp [string map {"-" "_"} [string tolower $key]]
  set tmp [string map {" " "_"} [string tolower $key]]
  return $tmp 

}


# ---------------------------------------

# bddimages_header_id

# Determine le type de header de l image
# créé les structures de table si besoin

# ---------------------------------------
proc bddimages_header_id { tabkey } {

  # --- Recuperation des champs des header de la base
  set sqlcmd ""
  append sqlcmd "SELECT idheader,keyname FROM header;"
  set err [catch {set resultsql [::bddimages_sql::sql query $sqlcmd]} msg]
  
  if {$err} {
    bddimages_sauve_fich "bddimages_header_id: ERREUR : <$err> <$msg>"
    switch $msg {
      "::mysql::query/db server: Table 'bddimages.header' doesn't exist" {
        unset sqlcmd
        append sqlcmd "CREATE TABLE header ("
        append sqlcmd "idheader INT NOT NULL,"
        append sqlcmd "keyname VARCHAR(20) NOT NULL,"
        append sqlcmd "type VARCHAR(20) NOT NULL,"
        append sqlcmd "variable VARCHAR(20) NOT NULL,"
        append sqlcmd "unit VARCHAR(20) NULL,"
        append sqlcmd "comment VARCHAR(256) NULL"
        append sqlcmd ") TYPE = MYISAM ;"    
        set err [catch {::bddimages_sql::sql query $sqlcmd} msg]
        if {$err} {
          bddimages_sauve_fich "bddimages_header_id: ERREUR 201 : Creation table header <$err> <$msg>"
          return [list 201 0]
          } else {
          bddimages_sauve_fich "bddimages_header_id: Creation table header..."
	  set resultsql ""
          # --- 
	  }
	}

      "::mysql::query/db server: MySQL server has gone away" {
        set err [catch {::bddimages_sql::connect} msg]
        set err [catch {set resultsql [::bddimages_sql::sql query $sqlcmd]} msg]
        if {$err} { return [list 208 0] }
	}

      default {
          bddimages_sauve_fich "bddimages_header_id: ERREUR 202 : Impossible d acceder aux informations de bddimages.header"
          bddimages_sauve_fich "bddimages_header_id:    NUM : <$err>"
          bddimages_sauve_fich "bddimages_header_id:    MSG : <$msg>"
          bddimages_sauve_fich "bddimages_header_id:    SQL : <$sqlcmd>"
          return [list 202 0]
        }
      }

    } 

  # -- Construction de chaque liste de mot-cles des header de la base
  foreach line $resultsql {
    set idheader [lindex $line 0]
    set key [lindex $line 1]
    lappend header($idheader) $key       
    }

  # -- Comparaison des mot-cles des header de la base avec le header de l image
  set arrnames [array names header]
  set listidentique "no"

  foreach idhd $arrnames {
    set listbase [lsort -ascii $header($idhd)]
    set listidentique "yes"
    set list_keys [list ]
    foreach key $tabkey {
      lappend list_keys [lindex $key 0]
      } 
    set list_keys [lsort -ascii $list_keys]      
    if {[llength $list_keys]==[llength $listbase]} {
      foreach key $listbase {
	if {[lsearch -exact $list_keys $key]<0} {
	  set listidentique "no"
	  }   
        }
	if {$listidentique=="yes"} {
	  set idheader $idhd
	  }
      } else {
        set listidentique "no"
	}
    if {$listidentique=="yes"} {
      break
      }
    }

  # -- Creation d un nouveau type de header
  if {$listidentique=="no"} {

    # -- determination du nouveau id (bouche les trous)
    set idhdder [lindex [lsort -integer -decreasing $arrnames] 0]
    set idheader 0
    for {set x 1} {$x<=$idhdder} {incr x} {
      if {[lsearch -exact $arrnames $x]<0} {
        set idheader $x
        break
        }
      }

#    bddimages_sauve_fich "bddimages_header_id: idheader = $idheader"	
    if {$idheader==0} {
      set idhdder [expr $idhdder + 1]
      set idheader $idhdder
#      bddimages_sauve_fich "bddimages_header_id: Ajoute un nouveau header en fin de liste <IDHD=$idheader>"	
      }

    # -- Creation de la ligne sql pour l insertion du nouvel header
    set sqlcmd ""
    set sqlcmd2 ""

    append sqlcmd "INSERT INTO header (idheader, keyname, type, variable, unit, comment) VALUES \n"
    append sqlcmd2 "CREATE TABLE images_$idheader (\n"
    append sqlcmd2 "`idbddimg` bigint(20) NOT NULL,\n"

    foreach keyval $tabkey {

      set key     [lindex $keyval 0]
      set info    [lindex $keyval 1]
      set type    [lindex $info 2]
      set var     [bddimages_keywd_to_variable $key]
      set unit    [lindex $info 4]
      set comment [lindex $info 3]

      # -- Creation de la ligne sql pour la creation d une nouvelle table header
      switch $type {
        "string" {
	  set type TEXT
	  }
        "float" {
	  set type DOUBLE
	  }
        "double" {
	  set type DOUBLE
	  }
        "int" {
	  set type INT
	  }
        "" {
           bddimages_sauve_fich "bddimages_header_id: ERREUR 203 : type de champ du header vide"	
           return  [list 203 0]
	  }
        default {
           bddimages_sauve_fich "bddimages_header_id: ERREUR 204 : type de champ du header inconnu <$type>"	
           return [list 204 0]
	  }
	}
      append sqlcmd2 "`$var` $type NULL,\n"

      # -- Creation de la ligne sql pour l insertion d un nouvel enregistrement de la table header
      if {$unit==""} {
        set unit "NULL"
	} else {
	  set unit "'$unit'"
	  }
      if {$comment==""} {
        set comment "NULL"
	} else {
	  # attention au caractere ' dans la chaine de caractere
	  # on remplace par le caractere blanc
          set comment [string map {"'" " "} $comment]
	  set comment "'$comment'"
	  }
      append sqlcmd "($idheader, '$key', '$type','$var', $unit, $comment),\n"

      } 
      #-- fin de foreach keyval $tabkey 
      
      set sqlcmd "$sqlcmd"
      set sqlcmd [string trimright $sqlcmd ",\n"]

      set sqlcmd2 [string trimright $sqlcmd2 ",\n"]
      append sqlcmd2 ") TYPE = MYISAM ;"   

     #  bddimages_sauve_fich "bddimages_header_id: sqlcmd <$sqlcmd>"	
     #  bddimages_sauve_fich "bddimages_header_id: sqlcmd2 <$sqlcmd2>"	

  # -- Acces a la base

      # --Insertion d un nouvel enregistrement de la table header
      set err [catch {::bddimages_sql::sql query $sqlcmd} msg]
      if {$err} {
          bddimages_sauve_fich "bddimages_header_id: ERREUR 205 : Insertion table header <$err> <$msg>"	
          return [list 205 0]
          } else {
#          bddimages_sauve_fich "bddimages_header_id: Insertion d un nouveau type de header dans la base <IDHD=$idheader>"	
	  }
      # -- Creation d une nouvelle table header
      set err [catch {::bddimages_sql::sql query $sqlcmd2} msg]
      if {$err} {
        bddimages_sauve_fich "bddimages_header_id: ERREUR 206 : Creation table images_$idheader <$err> <$msg> <$sqlcmd2> "	
        set sqlcmd "DELETE FROM header WHERE idheader=$idheader"
        set err [catch {::bddimages_sql::sql query $sqlcmd} msg]
        if {$err} {
          bddimages_sauve_fich "bddimages_header_id: ERREUR 207 : Effacement impossible dans la table header pour l id = $idheader  <$err> <$msg> "	
          return [list 207 0]
          } else {
          bddimages_sauve_fich "bddimages_header_id: Effacement dans la table header pour IDHD=$idheader "	
	  }
        return [list 206 0]
        } else {
#          bddimages_sauve_fich "bddimages_header_id: Insertion d un nouveau type de header dans la base <IDHD=$idheader> "	
	  }


    }
    # -- Fin Creation d un nouveau type de header

return [list 0 $idheader]
}
