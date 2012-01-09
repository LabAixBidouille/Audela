#
# Fichier : sn_tarot_http.tcl
# Description : Procedures pour la connexion a des sites http
# Auteur : Alain KLOTZ et Raymond ZACHANTKE
# Mise à jour $Id$
#

#--------------proc lancees par sn_tarot_go.tcl -------------

#------------------------------------------------------------
# downloadFile
#    Telecharge et verifie un fichizer zip
#  Parametres : url jusqu'au denier /, ce qui suit (nom du fichier zip)
#  et le nom complet sous lequel il faut enregistrer le fichier
#------------------------------------------------------------
proc ::sn_tarot::downloadFile { url0 param file } {
   global panneau caption

   if { [catch { set tok [ ::http::geturl ${url0}/$param ] } ErrInfo ] } {
      tk_messageBox -icon info -type ok \
         -message [ format $caption(sn_tarot_go,url_error) $url0 ]
      return 0
   }

   upvar #0 $tok state

  if { [ ::http::status $tok ] != "ok" } {
      error "pb download"
      return 0
   }

   #--   verifie le contenu
   set key [ string range [ ::http::data $tok ] 0 4 ]

   if { $key == "<?xml" } {
      tk_messageBox -icon info -type ok \
         -message [ format $caption(sn_tarot_go,file_error) $param ]
      return 0
   }

   #--   nettoie l'ancien fichier
   if { [ file exists $file ] } {
      file delete $file
   }

   #--   enregistre le fichier vers le dossier
   set f [ open $file w ]
   fconfigure $f -translation binary
   puts -nonewline $f [ ::http::data $tok ]
   close $f
   ::http::cleanup $tok

   return 1
}

#------------------------------------------------------------
# ::sn_tarot::httpcopy
#  Adapte de http://tmml.sourceforge.net/doc/tcl/http.html
#  Liee a proc ::sn_tarot::inventaire de sn_tarot_go.tcl
#  Integre la redirection
#------------------------------------------------------------
proc ::sn_tarot::httpcopy { url file {chunk 4096} } {

   #--   copie la page html dans le fichier provisoire $file
   set out [ open $file w ]

   if {[catch {set token [ ::http::geturl $url -channel $out -blocksize $chunk ]} ErrInfo]} {
      close $out
      return $ErrInfo
   }
   close $out

   upvar #0 $token state

   foreach {name value} $state(meta) {
      #--   cas de redirection
      if {[regexp -nocase ^location$ $name]} {
         return [ ::sn_tarot::httpcopy [string trim $value] $file $chunk ]
      }
   }
}

#--------  gestion des requetes DSS aupres de Skyview -------

#------------------------------------------------------------
# listRequest
#  Formate et gere les requetes des images DSS manquantes
#  Paremetre : liste du nom des galaxies (sans extension)
#------------------------------------------------------------
proc ::sn_tarot::listRequest { files_to_load } {
   global conf caption rep snvisu

   set snvisu(dss) 1
   set ext $conf(extension,defaut)
   set pi [ expr {4*atan(1)} ]
   set n 0
   set len [ llength $files_to_load ]

   set url "http://skyview.gsfc.nasa.gov/cgi-bin/images?"
   set sentence  "Position=%s,%s&Size=%s,%s&Pixels=%s,%s&Rotation=%s&Survey=DSS&Scaling=Linear&Projection=Tan&Coordinates=J2000&Return=FITS"
   #  Size=size[,size] - The size[s] of the image in degrees.  If only one value is given the image is square.
   #  Pixels=n[,m] - The number of pixels in the image. If only one value is given the height and width are the same.
   #  brightness Scaling (Log, Linear, Sqrt, HistEq)
   #  map Projection (Tan, Sin, Car, Ait, Zea, Csc)
   #  Rotation (degres)
   #  pixel Resampling : Nearest Neighbor (NN), Bi-Linear (LI), Lanczos3, Spline3, Clip (Flux conserving), Clip (Intensive)
   #  Grid overlay : No grid, Coordinates same as image, J2000, B1950, Galatic, I2000, ICRS
   #  Plot color : e.g. green black, white
   #  Return {fits jpeg gif}

   set todestroy [ ::sn_tarot::createProgressBar ]

   #::console::affiche_resultat "\n$caption(sn_tarot,main_title) :\n"

   foreach name $files_to_load {

      if {![catch { set kwds_list [ fitsheader [ file join $rep(name1) $name$ext ] ] } ] } {

         #--   extrait les mots cles et leur valeur
         foreach kwd [ list CROTA2 CDELT1 CDELT2 CRPIX1 CRPIX2 CRVAL1 CRVAL2 FOCLEN NAXIS1 NAXIS2 ] {
            set index [ lsearch -index 0 -regexp -exact $kwds_list "$kwd" ]
            set [ string tolower $kwd ] [ lindex $kwds_list [ list $index 1 ] ]
         }

         set coscrota2 [expr cos($crota2*$pi/180.)]
         set sincrota2 [expr sin($crota2*$pi/180.)]
         set cd11 [expr $pi/180*($cdelt1*$coscrota2)]
         set cd12 [expr $pi/180*(abs($cdelt2)*$cdelt1/abs($cdelt1)*$sincrota2)]
         set cd21 [expr $pi/180*(-abs($cdelt1)*$cdelt2/abs($cdelt2)*$sincrota2)]
         set cd22 [expr $pi/180*($cdelt2*$coscrota2)]

         set x [expr $naxis1/2.]
         set y [expr $naxis2/2.]
         set dra  [expr $cd11*($x-($crpix1-0.5)) + $cd12*($y-($crpix2-0.5))]
         set ddec [expr $cd21*($x-($crpix1-0.5)) + $cd22*($y-($crpix2-0.5))]
         set coscrval2 [expr cos($crval2*$pi/180.)]
         set sincrval2 [expr sin($crval2*$pi/180.)]
         set delta [expr $coscrval2 -$ddec*$sincrval2 ]
         set gamma [expr sqrt($dra*$dra + $delta*$delta) ]
         set ra [expr $crval1 + 180./$pi*atan($dra/$delta)]
         set dec [expr 180./$pi*atan( ($sincrval2+$ddec*$coscrval2)/$gamma )]

         set fov_x [ format %.6f [expr abs($cdelt1)*$naxis1]]
         set fov_y [ format %.6f [expr abs($cdelt2)*$naxis2]]

         #--   formate la requete
         set query [ format $sentence $ra $dec $fov_x $fov_y $naxis1 $naxis2 $crota2 ]
         #::console::affiche_resultat "query=$query\n"

         #--   initialisation
         lassign [ list 0 "" ]  ok reason

         #--   traitement des erreurs
         lassign [ ::sn_tarot::loadDSS "$url" "$query" $name ] ok reason
         if { $reason eq "" } {
            #::console::affiche_resultat "[ format $caption(sn_tarot,dss_download_ok) $name$ext ]\n"
            incr n
            set snvisu(progress) [ expr { $n*100./$len } ]
            update
         } else {
            switch -exact $reason {
               url_error   {set msg [ format $caption(sn_tarot_go,url_error) $url ]}
               default     {set msg [ format $caption(sn_tarot,dss_not_found) $name$ext $reason ]}
            }
            ::console::affiche_resultat "$msg\n"
            if {$reason eq "url_error"} {
               #return $n
               destroy $todestroy
            }
         }
      }
   }

   destroy $todestroy
   set snvisu(dss) 0

   #--   retourne le nombre de fichiers telecharges
   #return $n
}

#------------------------------------------------------------
# loadDSS
# Telecharge les images DSS
# Parametres : url, requete formatee et nom de la galaxie
#------------------------------------------------------------
proc ::sn_tarot::loadDSS { url query name } {
   global rep

   set ok 0

   if { [catch { set tok [ ::http::geturl "$url" -query "$query" ] } ErrInfo ] } {
       return [ list $ok url_error ]
   }

   upvar #0 $tok state

   if { [ ::http::status $tok ] != "ok" } {
      set reason "pb download"
      return [ list $ok $reason ]
   }

  #--   verifie le contenu
   set key [ string range [ ::http::data $tok ] 0 4 ]

   if { $key == "<html" || $key == "<xmls" } {
      #--   identifie le motif de l'echec
      set texte [ lindex [ array get state body ] 1 ]
      set index [ string first "Reason:" $texte ]
      set texte [ string range $texte $index end ]
      set index [ string first < $texte ]
      incr index -1
      set reason [ string range $texte 8 $index ]
      return [ list $ok $reason ]
   }

   foreach { meta_name value } $state(meta) {
      if {[regexp -nocase ^content-disposition$ $meta_name]} {
         # Recherche l'ID de l'image attachee
         regsub -nocase -all "attachment; filename=" $value "" html_file
         if { $html_file ne "" } {
            set ok 1
            #::console::affiche_resultat "$name attachment=$html_file $ok\n"
         }
      }
   }

  if { $ok == 1 } {
      #--   sauve l'image dans le repertoire dss
      set filename [ file join $rep(name3) $name.fit ]
      if { [ file exists $filename ] == 1 } { file delete $filename }
      set f [ open $filename w ]
      fconfigure $f -translation binary
      puts -nonewline $f [ ::http::data $tok ]
      close $f
   }

   ::http::cleanup $tok
   return $ok
}

