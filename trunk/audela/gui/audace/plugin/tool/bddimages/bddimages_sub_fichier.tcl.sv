# source audace/plugin/tool/bddimages/bddimages_sub_fichier.tcl

proc bddimages_sauve_fich {texte} {

   global bddconf   
   global entetelog   

     set texte "$entetelog:$texte"
     createdir_ifnot_exist $bddconf(dirlog)
     set fichlog "$bddconf(dirlog)/lastlog.txt"
     set sizelog 0
     catch { set sizelog [file size $fichlog]}
      
     if {$sizelog > 1000000} {
       set listlog [glob -nocomplain $bddconf(dirlog)/*]
       set listlog [lsort -ascii $listlog]
       set last [file tail [lindex $listlog end]]       
       set last [string range $last 3 7]
       
       set err [catch {set new [expr $last + 1]} msg]
       if {$err} {set new ""}
       set new "0000000$new"
       set ext [string range $new [expr [string length $new]-5] end ]
       catch {file rename $fichlog "$bddconf(dirlog)/log$ext.txt"}
       }
     catch { set bddfileout [open $fichlog a] }
     catch { puts $bddfileout $texte }
     catch { close $bddfileout }

}

# ----------------------------------------

# globrdk

# retourne la liste recursive des fichiers
# d un repertoire avec une limite de 1000
# fichiers fits

# ---------------------------------------

proc globrdk { {dir .} limit } {

  global maliste
  
    set liste [glob -nocomplain $dir/*]

    foreach i $liste {
       if { [llength $maliste]==$limit && $limit!=0 } {
         break
	 }    
       if {[file type $i]=="directory"} {
                 if {[llength $maliste]<$limit || $limit==0} {
		   globrdk $i $limit
		   } else {
		   break
		   }
        } else {
	   set result [bddimages_formatfichier $i]
	   set form2  [lindex $result 0]
           if { ([llength $maliste]<$limit || $limit==0) && ( $form2=="fit" || $form2=="fit.gz" || $form2=="fits" || $form2=="fits.gz" || $form2=="cata.txt" || $form2=="cata.txt.gz") } {
              lappend maliste $i
	      } else {
	      }
        }
    }
 }

proc globrd {{dir .}} {
    set res {}
    set liste [glob -nocomplain $dir/*]
    foreach i $liste {
        if {[file type $i]=="directory"} {
                eval lappend res [globrd $i]
        } else {
                lappend res $i
        }
    }
    return $res
 }
 
 
proc globr {{dir .}} {
    set res {}

    set errnum [catch {set cur [glob $dir]} msg]
    if {$errnum} {
    
    } else {
    foreach i $cur {
        if {[file type $i]=="directory"} {
        } else {
                lappend res $i
        }
    }
        
    eval lappend res [globrd $dir]
    }
    return $res
 }


# ----------------------------------------

# numberoffile

# ---------------------------------------
proc numberoffile { dir } {
      set err [catch {set list_file [globr $dir/*]} result]
      if {$err==0} {
        set nbfile [llength $list_file]
      } else { 
        set nbfile "Failed <ERR:$err> <RESULT:$result>"
      }
    return $nbfile
 }


# ----------------------------------------

# bddimages_formatfichier

# retourne le format du fichier image

# ---------------------------------------
proc bddimages_formatfichier {fichierorig} {

    set fichier [string tolower $fichierorig]
    set form2 "unknown"
    set form1 0

    set form [string last fits.gz $fichier]
    if {$form>1} {set form2 "fits.gz"}

    if {$form2=="unknown"} {
      set form [string last fits $fichier]
      if {$form>1} {set form2 "fits"}
      }

    if {$form2=="unknown"} {
      set form [string last fit.gz $fichier]
      if {$form>1} {set form2 "fit.gz"}
      }

    if {$form2=="unknown"} {
      set form [string last fit $fichier]
      if {$form>1} {set form2 "fit"}
      }

    if {$form2=="unknown"} {
      set form [string last cata.txt.gz $fichier]
      if {$form>1} {set form2 "cata.txt.gz"}
      }

    if {$form2=="unknown"} {
      set form [string last cata.txt $fichier]
      if {$form>1} {set form2 "cata.txt"}
      }

    set racinefich "unknown"
    if { $form2!="unknown" && $form>1 } {
      set racinefich [string range $fichierorig 0 [expr $form -2]]
      }

return [ list $form2 $racinefich]
}

# ---------------------------------------

# createdir_ifnot_exist

# cree un nouveau repertoire s il n existe pas

# ---------------------------------------
proc createdir_ifnot_exist {dirfilename} {

  set direxist [file exists $dirfilename]

  if {$direxist==0} {

    set errnum [catch {file mkdir $dirfilename} msg]
    if {$errnum==0} {
#      bddimages_sauve_fich "createdir_ifnot_exist: Creation du repertoire : $dirfilename <$errnum>"
      } else {
        bddimages_sauve_fich "createdir_ifnot_exist: ERREUR MV: Creation du repertoire $dirfilename impossible <$errnum>"
        }

    }

}
