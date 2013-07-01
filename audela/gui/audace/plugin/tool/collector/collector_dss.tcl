#
# Fichier : collector_dss.tcl
# Description :
# Auteur : Raymond Zachantke
# Mise à jour $Id$
#

   #--   Liste des proc de la gestion des requetes DSS aupres de SkyView
   # nom proc                             utilisee par
   # ::collector::requestSkyView          Commande du bouton 'Image DSS'
   # ::collector::loadDSS                 requestSkyView
   # ::collector::updateDSSData           requestSkyView
   # ::collector::extractDataFromComment  updateDSSData

   #------------------------------------------------------------
   #  requestSkyView
   #  Commande du bouton 'Image DSS' : formate et gere la requete aupres de SkyView
   #  Parametres : nom de l'image == [file join $::audace(rep_images) dss$::conf(extension,defaut)]
   #  Derive de ::sn_tarot::listRequest
   #------------------------------------------------------------
   proc requestSkyView { filename {visuNo 1} } {
      variable private
      global caption

      #--   change le bouton 'Image DSS'
      $private(This).cmd.dss configure -text $caption(collector,loading)

      #--   inhibe les boutons
      configButtons disabled
      update

      #--   efface l'image existante
      if {[buf[visu$visuNo buf] imageready]} {visu$visuNo clear}

      set url "http://skyview.gsfc.nasa.gov/cgi-bin/runquery.pl"
      set sentence  "Position=%s,%s&Size=%s,%s&Pixels=%s,%s&Rotation=%s&Survey=DSS&Scaling=Linear&Projection=Tan&Coordinates=J2000&Return=FITS"

      #  Position=ra,dec en degres
      #  Size=size[,size] - The size[s] of the image in degrees.  If only one value is given the image is square.
      #  Pixels=n[,m] - The number of pixels in the image. If only one value is given the height and width are the same.
      #  brightness Scaling (Log, Linear, Sqrt, HistEq)
      #  map Projection (Tan, Sin, Car, Ait, Zea, Csc)
      #  Rotation (degres)
      #  Return {fits jpeg gif}
      #  transcodage : ra->crval1 dec->crval2 size_x->fov1 size_y->fov2 pixels_x->naxis1 pixels_y->naxis2 rotation->crota2
      #  crval1 crval2 fov1 fov2 et crota2 en degres

      #--   collecte les infos de la requete
      foreach var [list crval1 crval2 fov1 fov2 naxis1 naxis2 crota2] {
         set $var $private($var)
      }

      #--   limite la taille et le temps de telechargement, sans modification de FOV
      if {$naxis1 > 768} {
         set naxis2 [expr { int($naxis2 * 768. / $naxis1 ) } ]
         set naxis1 768
      }

      #--   formate la requete
      set query [format $sentence $crval1 $crval2 $fov1 $fov2 $naxis1 $naxis2 $crota2]
      #::console::affiche_resultat "query=$query\n"

      #--   initialisation
      lassign [list 0 ""] ok reason

      #--   traitement des erreurs
      lassign [loadDSS "$url" "$query" "$filename"] ok reason

      if {$reason eq ""} {
         loadima $filename
         updateDSSData $visuNo [list $crval1 $crval2 $naxis1 $naxis2 $crota2]
      } else {
        switch -exact $reason {
            urlError {set msg [format $caption(collector,urlError) $url]}
            default  {set msg [format $caption(collector,dssNotFound) $filename $reason]}
         }
         ::console::affiche_erreur "$msg\n"
         if {$reason eq "urlError"} {
            return
         }
      }

      #--   change le bouton 'Image DSS'
      $private(This).cmd.dss configure -text $caption(collector,dss)

      #--   desinhibe les boutons
      configButtons !disabled
      update
   }

   #------------------------------------------------------------
   #  loadDSS
   #  Telecharge les images DSS sur SkyView
   #  Parametres : url, requete formatee et nom de l'image
   #  Derive de ::sn_tarot::loadDSS
   #------------------------------------------------------------
   proc loadDSS { url query filename {chunk 4096} } {

      set ok 0

      if { [catch {set tok [::http::geturl $url -query $query -blocksize $chunk]} ErrInfo]} {
         return [ list $ok urlError ]
      }

      upvar #0 $tok state

      if {[::http::status $tok] != "ok"} {
         set reason "pb download"
         return [list $ok $reason]
      }

      #--   verifie le contenu
      set key [string range [::http::data $tok] 0 4]

      if {$key == "<html" || $key == "<xmls"} {
         #--   identifie le motif de l'echec
         set texte [lindex [array get state body] 1]
         set index [string first "Reason:" $texte]
         set texte [string range $texte $index end]
         set index [string first < $texte]
         incr index -1
         set reason [string range $texte 8 $index]
         return [list $ok $reason]
      }

      foreach { meta_name value } $state(meta) {
         #update
         if {[regexp -nocase ^content-disposition$ $meta_name]} {
            # Recherche l'ID de l'image attachee
            regsub -nocase -all "attachment; filename=" $value "" html_file
            if {$html_file ne ""} {
               set ok 1
               #::console::affiche_resultat "[file rootname $filename] attachment=$html_file $ok\n"
               #::console::affiche_resultat "[::http::size $tok]\n"
            }
         }
      }

      if { $ok == 1 } {
         #--   detruit une image de meme nom pre-existante
         if {[file exists $filename] == 1} {file delete $filename}
         #--   sauve la nouvelle image
         set f [open $filename w]
         fconfigure $f -translation binary
         puts -nonewline $f [::http::data $tok]
         chan close $f
      }

      ::http::cleanup $tok
      return $ok
   }

   #------------------------------------------------------------
   # updateDSSData
   # Met a jour collector avec les valeurs de l'en-tete FITS de l'image
   #------------------------------------------------------------
   proc updateDSSData { visuNo data } {
      variable private

      set ext $::conf(extension,defaut)
      lassign $data crval1 crval2 naxis1 naxis2 crota2

      #--   Rem : respecter l'ordre
      #--   actualise la taille des pixels (NAXIS réduit avec FOV (constant) de l'image
      set private(photocell1) [expr { $private(photocell1) * $private(naxis1) / $naxis1 }]
      set private(pixsize1) $private(photocell1)
      set private(photocell2) [expr { $private(photocell2) * $private(naxis2) / $naxis2 }]
      set private(pixsize2) $private(photocell2)

      #--   actualise l'affichage des naxis (susceptibles d'etre modifies)
      set private(naxis1) $naxis1
      set private(naxis2) $naxis2

      #--   actualise private(cdelt) en arcsec
      set private(cdelt1) [expr { [lindex [buf[visu$visuNo buf] getkwd CDELT1] 1] * 3600 }]
      set private(cdelt2) [expr { [lindex [buf[visu$visuNo buf] getkwd CDELT2] 1] * 3600 }]

      #-- complete l'en-tete FITS
      set bufNo [visu$visuNo buf]
      buf$bufNo delkwd RADESYS
      foreach {kwd val} [list \
         CROTA2 $private(crota2) \
         PIXSIZE1 $private(pixsize1) \
         PIXSIZE2 $private(pixsize2) \
         EQUINOX J2000.0 \
         RADECSYS FK5 \
         DEC "$private(dec)" \
         RA "$private(ra)" ] {
         buf$bufNo setkwd [format [formatKeyword $kwd] $val]
      }

      calibrationAstro $bufNo $ext $private(catAcc) $private(catname)
      saveima [file join $::audace(rep_images) dss$ext]
      extractDataFromComment $bufNo

      #--   il faut recharger l'image pour que le changement de coordonnees opere
      loadima [file join $::audace(rep_images) dss$ext]
   }

   #------------------------------------------------------------
   # extractDataFromComment
   # Si le mot cle COMMENT contient le nom et les caracteristiques du telescope
   # met a jour les variables correspondantes
   #------------------------------------------------------------
   proc extractDataFromComment { bufNo } {

      #--   extrait le nom du telescope
      set comment [buf$bufNo getkwd COMMENT]

      if {[lindex $comment 1] ne ""} {
         set comment [string map [list "\}" "" "\{" "" "COMMENT" "" string "" "*" ""] $comment]
         regexp -all {.+(TELESCOP=[[:space:]]\'.+\').+(TELESCOP=[[:space:]]\'.+\').+} $comment match south north
         if {[string index $private(dec) 0] eq "+"} {
            set result $north
        } else {
            set result $south
         }
         set k [string first "'" $result]
         set result [string range $result [incr k] end]
         set k [string first "'" $result]
         set private(telescop) [string range $result 0 [incr k -1]]

         #--   calcule les parametres optiques
         switch -exact $private(telescop) {
            "Palomar 48-inch Schmidt"  {  set aptdia 1.2
                                          set fond 2.5
                                          set foclen [expr {$fond*$aptdia}]
                                       }
            "UK Schmidt (new optics)"  {  set aptdia 1.2
                                          set foclen 3.07
                                       }
         }
         set private(aptdia) $aptdia
         set private(foclen) $foclen
         buf$bufNo setkwd [list APTDIA "$private(aptdia)" double Diameter m]
         buf$bufNo setkwd [list FOCLEN "$private(foclen)" double {Resulting Focal length} m]

        lassign [getFonDResolution $aptdia $foclen] private(fond) private(resolution)
      }
   }

