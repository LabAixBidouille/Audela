#--------------------------------------------------
# source audace/plugin/tool/bddimages/tools_cata.tcl
#--------------------------------------------------
#
# Fichier        : tools_cata.tcl
# GUI            : Rien ne doit utiliser l'environnement graphique
# Description    : Manipulation des fichiers CATA
# Auteur         : Frederic Vachier
# Mise à jour $Id: tools_cata.tcl 6858 2011-03-06 14:19:15Z fredvachier $
#
namespace eval tools_cata {












proc ::tools_cata::extract_cata_xml { catafile } {

  global bddconf

      # copy catafile vers tmp
      set destination [file join $bddconf(dirtmp) [file tail $catafile]]
      #gren_info "destination = $destination\n"
      set errnum [catch {file copy "$catafile" "$destination" ; gunzip "$destination"} msgzip ]
      #gren_info "errnum = $errnum\n"
      #gren_info "msgzip = $msgzip\n"
      
      # gunzip catafile de tmp
      # return le nom de fichier
      return [file rootname $destination]
 }
 
 
















proc ::tools_cata::get_cata_xml { catafile } {

       global bddconf


      
    set fields ""

         #gren_info "get_cata_xml = $catafile \n"
         set fxml [open $catafile "r"]
         set data [read $fxml]
         close $fxml
         #gren_info "data = $data \n"

      set motif  "<vot:TABLE\\s+?name=\"(.+?)\"\\s+?nrows=(.+?)>(?:.*?)</vot:TABLE>"
      set res [regexp -all -inline -- $motif $data]
      set cpt 1
      foreach { table name nrows } $res {
         #gren_info "$cpt  :  \n"
         #gren_info "Name => $name  \n"
         #gren_info "nrows  => $nrows  \n"
         #gren_info "TABLE => $table  \n"
         set res [ get_table $name $table ]
         #gren_info "TABLE res => $res  \n"
         #set ftmp  [lindex [lindex $res 0] 2]
         #set ftmp [lrange $ftmp 1 end]
         #set ftmp [list  [lindex [lindex $res 0] 0]   [lindex [lindex $res 0] 1]  $ftmp]  
         #gren_info "TABLE => $ftmp  \n"
         
         lappend fields [lindex $res 0]
         set asource [lindex $res 1]
         foreach x $asource {
            set idcataspec [lindex $x 0]
            set val [lindex $x 1]
            #gren_info "$idcataspec = $val\n"
            if {![info exists tsource($idcataspec)]} {
               #gren_info "set $idcataspec => $val  \n"
               set tsource($idcataspec) [list [list $name {} $val]]
            } else {
               #gren_info "app $idcataspec => $val  \n"
               lappend tsource($idcataspec) [list $name {} $val]
            }
         }


         incr cpt
      }
      
      #gren_info "tsource => [array get tsource]  \n"
      set tab [array get tsource]
      set lso {}
      set cpt 0
      foreach val $tab {
         #gren_info "vals [expr $cpt%2] => $val \n"
         if {[expr $cpt%2] == 0 } {
            # indice
         } else {
            lappend lso $val
         }
         incr cpt
      }
      
      #gren_info "FIELDS => $fields  \n"
      #gren_info "SOURCES => $lso  \n"
      
      return [list $fields $lso]

}



















proc ::tools_cata::get_table { name table } {


      set motif  "<vot:FIELD(?:.*?)name=\"(.+?)\"(?:.*?)</vot:FIELD>"

      set res [regexp -all -inline -- $motif $table ]
      #gren_info "== res $res \n"
      set cpt 1
      set listfield ""
      foreach { x y } $res {
         #gren_info "== $cpt  : $y \n"
         
         if {$y != "idcataspec.$name"} { lappend listfield $y }
         incr cpt
      }
      
      set listfield [list $name [list ra dec poserr mag magerr] $listfield]
      #gren_info "== listfield $listfield \n"

      set motiftr  "<vot:TR>(.*?)</vot:TR>"
      set motiftd  "<vot:TD>(.*?)</vot:TD>"
      
      set tr [regexp -all -inline -- $motiftr $table ]
      set cpt 1
      set lls ""
      foreach { a x } $tr {
         #gren_info "TR-> $cpt  : a: $a x: $x \n"
         #gren_info "TR-> $cpt \n"
         set td [regexp -all -inline -- $motiftd $x ]
         set u 0
         set ls ""
         foreach { y z } $td {
            if { $u == 0 } {
               set idcataspec $z
            } else {
               lappend ls $z
            }
            incr u
         }
         #gren_info "$idcataspec : $ls\n"
         lappend lls [list $idcataspec $ls]
         incr cpt
         if { $cpt > 1000 } { break }
      }
      
      #gren_info "lls = $lls \n"
      return [list $listfield $lls]
}
















# Fin du namespace
}
