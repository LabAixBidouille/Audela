

proc get_cata_xml { catafile } {
       global bddconf


      
    set fields ""

         set fxml [open $catafile "r"]
         set data [read $fxml]
         close $fxml
         #gren_info "data = $data \n"

      set text2 {toto <TABLE name="IMG" nrows="3154"> </TABLE> test <TABLE name="USNOA2" nrows="3154"> </TABLE> fini}
      set motif  "<TABLE\\s+?name=\"(.+?)\"\\s+?nrows=(.+?)>(?:.*?)</TABLE>"
      set res [regexp -all -inline -- $motif $data]
      set cpt 1
      foreach { table name nrows } $res {
         #gren_info "$cpt  :  \n"
         #gren_info "Name => $name  \n"
         #gren_info "nrows  => $nrows  \n"
         if {$name=="IMG"} {
            set nrowsimg $nrows
         }
         #gren_info "TABLE => $table  \n"
         set res [ get_table $name $table ]
         #gren_info "TABLE => $res  \n"
         lappend fields [lindex $res 0]
         set asource [lindex $res 1]
         foreach x $asource {
            set idcataspec [lindex $x 0]
            set val [lindex $x 1]
            #gren_info "$idcataspec = $val\n"
            if {![info exists tsource($idcataspec)]} {
               #gren_info "set $idcataspec => $val  \n"
               set tsource($idcataspec) [list $name {} $val]
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
      
      #gren_info "NROWS => $nrowsimg  \n"
      #gren_info "FIELDS => $fields  \n"
      #gren_info "SOURCES => $lso  \n"
      
      return [list $fields $lso]

}






proc get_table { name table } {


      set motif  "<FIELD(?:.*?)name=\"(.+?)\"\\s+?arraysize=(?:.*?)/>"

      set res [regexp -all -inline -- $motif $table ]
      #gren_info "== res $res \n"
      set cpt 1
      set listfield ""
      foreach { x y } $res {
         #gren_info "== $cpt  : $y \n"
         if {$y != "idcataspec"} { lappend listfield $y }
         incr cpt
      }
      
      set listfield [list $name [list ra dec poserr mag magerr] $listfield]
      #gren_info "== listfield $listfield \n"

      set motiftr  "<TR>(.*?)</TR>"
      set motiftd  "<TD>(.*?)</TD>"
      
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













proc write_cata_votable { listsources tabkey newcatafile } {

   global bddconf

   set listevotable [listesource2listevotable $listsources $tabkey $newcatafile]

}


proc listesource2listevotable { listsources tabkey newcatafile } {

 global bddconf

   set fields  [lindex $listsources 0]
   set sources [lindex $listsources 1]

   set  listevotable "<?xml version='1.0'?>\n"
   append listevotable "<VOTABLE xsi:schemaLocation=\"http://www.ivoa.net/xml/VOTable/v1.1 http://www.ivoa.net/xml/VOTable/v1.1\"\n"
   append listevotable "xmlns:xsi=\"http://www.w3.org/2001/XMLSchema-instance\"\n"
   append listevotable "xmlns=\"http://www.ivoa.net/xml/VOTable/v1.1\">\n"
   append listevotable "<RESSOURCE>\n"


   foreach s $fields {
      foreach {name commun col} $s {
         gren_info "INSERT $name\n"
         set nbcol [llength $col]
         gren_info "COL $nbcol\n"


 # TABLE HEADER
         set votable "<TABLE name=\"header\" nrows=\"nbheaderkey\">\n"
         
         # ecrire ici tout le header de l image depuis le $tabkey

         append votable "  </TABLEDATA>\n"
         append votable "  </DATA>\n"
         append votable "</TABLE>\n"

# TABLES SOURCES
         
         # Cles des header
         set listevotabletmp "  <FIELD datatype=\"char\" name=\"idcataspec\" arraysize=\"30\"/>\n"
         if {$nbcol>0} {
            foreach key $col {
               append listevotabletmp "  <FIELD datatype=\"char\" name=\"$key\" arraysize=\"30\"/>\n"
            }
         }
         append listevotabletmp "  <DATA>\n"
         append listevotabletmp "  <TABLEDATA>\n"
         # --
         set nrows 0
         set idcataspec 0
         foreach s $sources {
               foreach c $s {
                  if { [lindex $c 0]==$name } {
                     set d [lindex $c 2]
                     append listevotabletmp "    <TR>\n"
                     append listevotabletmp "      <TD>$idcataspec</TD>\n"
                     if {$nbcol>0} {
                        foreach a $d {
                           append listevotabletmp "      <TD>$a</TD>\n"
                        }
                     }
                     append listevotabletmp "    </TR>\n"
                     incr nrows
                  } 
               }
            incr idcataspec
            #if { $nrows >= 5 } { break }
         }
         append listevotable "<TABLE name=\"$name\" nrows=\"$nrows\">\n"
         append listevotable $listevotabletmp
         append listevotable "  </TABLEDATA>\n"
         append listevotable "  </DATA>\n"
         append listevotable "</TABLE>\n"
      }
   }
   append listevotable "</RESSOURCE>\n"
   append listevotable "</VOTABLE>\n"

   set fxml [open $newcatafile "w"]
   puts $fxml $listevotable
   close $fxml

   return 0


}








proc write_cata_votable_dom { listsources } {

 global bddconf

   gren_info "GO WRITE VOTABLE \n"

   set newcatafile [file join $bddconf(astroid) .. ssp_votable cata.xml ]


   set docxml [::dom::DOMImplementation create]

   # Cree la racine du document 
   set root [::dom::document createElement $docxml "VOTABLE"]
   ::dom::element setAttribute $root "xmlns:xsi" "http://www.w3.org/2001/XMLSchema-instance"
   ::dom::element setAttribute $root "xsi:schemaLocation" "http://www.ivoa.net/xml/VOTable/v1.1 http://www.ivoa.net/xml/VOTable/v1.1"
   ::dom::element setAttribute $root "xmlns" "http://www.ivoa.net/xml/VOTable/v1.1"

   set ressource [::dom::document createElement $root "RESSOURCE"]


   # Premiere TABLE : La table Header
   set tableheader [::dom::document createElement $ressource "TABLE"]
   ::dom::element setAttribute $tableheader "nrows" 2
   ::dom::element setAttribute $tableheader "name" "Header"

      # Cles des header
      set node [::dom::document createElement $tableheader "FIELD"]
      ::dom::element setAttribute $node "comment"   "Telescope name"
      ::dom::element setAttribute $node "unit"      "iso-8601"
      ::dom::element setAttribute $node "name"      "TELESCOP"
      ::dom::element setAttribute $node "datatype"  "char"
      ::dom::element setAttribute $node "arraysize" "30"
      set node [::dom::document createElement $tableheader "FIELD"]
      ::dom::element setAttribute $node "comment"   "Observation date and time"
      ::dom::element setAttribute $node "unit"      "iso-8601"
      ::dom::element setAttribute $node "name"      "DATE-OBS"
      ::dom::element setAttribute $node "datatype"  "datetime"
      ::dom::element setAttribute $node "arraysize" "25"

       # --
       set data [::dom::document createElement $tableheader "DATA"]
       set tabledata [::dom::document createElement $data "TABLEDATA"]
      
          # les Donnees
          set tr [::dom::document createElement $tabledata "TR"]
          set key [::dom::document createElement $tr "TD"]
          ::dom::document createTextNode $key "Tarot_Chili"
          set key [::dom::document createElement $tr "TD"]
          ::dom::document createTextNode $key "2011-06-23T23:23:23.2345"


   

   if {1} {       

   # TABLES : les Sources de l'image
       
   set fields  [lindex $listsources 0]
   set sources [lindex $listsources 1]
       
   foreach s $fields {
      foreach {name commun col} $s {
         gren_info "INSERT $name\n"
         
         set table [::dom::document createElement $ressource "TABLE"]
         ::dom::element setAttribute $table "nrows" 3
         ::dom::element setAttribute $table "name" "$name"

         # Cles des header
         foreach key $col {
         set node [::dom::document createElement $table "FIELD"]
         ::dom::element setAttribute $node "name"      "$key"
         ::dom::element setAttribute $node "datatype"  "char"
         ::dom::element setAttribute $node "arraysize" "30"
         }
         # --
         set data [::dom::document createElement $table "DATA"]
         set tabledata [::dom::document createElement $data "TABLEDATA"]
         
         set cpt 0
         foreach s $sources {
            set tr [::dom::document createElement $tabledata "TR"]
            foreach c $s {
               if { [lindex $c 0]==$name } {
                  set d [lindex $c 2]
                  foreach a $d {
                     set key [::dom::document createElement $tr "TD"]
                     ::dom::document createTextNode $key $a
                  } 
               } 
            }
            if { $cpt > 3 } { break }
            incr cpt
         }
         break
      }
      break
   }
       
   }  
       

   set fxml [open $newcatafile "w"]
   puts $fxml [::dom::DOMImplementation serialize $docxml -indent true]
   close $fxml

   return 0





}










proc read_cata_votable {  } {



}
