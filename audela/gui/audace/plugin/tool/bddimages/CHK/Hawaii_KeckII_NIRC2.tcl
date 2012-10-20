##################################################################################################
# Telelescope du l ' Observatoire du Pico dos Dias Itajuba Br�sil pour la 
# Camera IKON-L
##################################################################################################


##################################################################################################
# procedure de la derniere Chance !
# Elle permet de modifier les cl�s des headers en se basant sur le nom de l image.
# tres dangeureuse car modifie les images brutes
# cela est contraire a la philo de bddimages qui cherche a conserver les images brutes
#
# lancer dans la console le source suivant :
#
#  >  source [ file join $audace(rep_plugin) tool bddimages CHK Hawaii_KeckII_NIRC2.tcl]
#
##################################################################################################


    proc modif_img_header_keck { name path dest} {


      set fichiers [lsort [glob -nocomplain ${path}/*${name}*]]

      foreach fichier $fichiers {

         # charge l image
         loadima $fichier

         set dateobs [buf1 getkwd "DATE-OBS"]
         set utc     [buf1 getkwd "UTC"]
         set date    [string trim [lindex $dateobs 1]]
         set ti      [string trim [lindex $utc 1]]
         set date "${date}T${ti}"

         set exposure [string trim [lindex [buf1 getkwd "ELAPTIME"] 1 ]]

         # modifi les header
         buf1 setkwd [list "DATE-OBS"  $date "string" "UT date of start of observation" ""]
         buf1 setkwd [list "EXPOSURE" $exposure  "double" "exposure duration (seconds)--calculated" ""]
         buf1 setkwd [list "OBJECT" "136108_Haumea" "string" "Object name inside field" ""]
         buf1 setkwd [list "IAU_CODE" "568" "string" "Observatory IAU Code" ""]



         ::bddimagesAdmin::bdi_setcompat 1
         buf1 setkwd [list "BDDIMAGES STATE" "CORR" "string" "RAW | CORR | CATA | ?" ""]   
         buf1 setkwd [list "BDDIMAGES TYPE"  "IMG" "string" "IMG | FLAT | DARK | OFFSET | ?" ""]

         # sauve l image
         set f [file tail $fichier]
         set f [string range $f 0 [expr [string last .fits $f] -1]]
         set newfile [file join $dest "KECKII_${date}_${f}_CHK.fits"]
         ::console::affiche_resultat "sauve image : $newfile\n"
         saveima $newfile

         # take a look
         # set lh [buf1 getkwds]
         #::console::affiche_resultat "$lh\n"
          #break
      }

      return
   }

# ----------------------------------------------------------------------------------------------------

# --
#  >  source [ file join $audace(rep_plugin) tool bddimages CHK Hawaii_KeckII_NIRC2.tcl]

# ----------------------------------------------------------------------------------------------------

#  set path "/work/AsterOA/136108_Haumea/Observations/HST/science/drz"
#  set dest "/work/Observations/bddimages/incoming"
   set path "/data/astrodata/Observations/Images/bddimages/bddimages_local/tmp/img"
   set dest "/data/astrodata/Observations/Images/bddimages/bddimages_local/tmp/CHK"

   ::console::affiche_resultat "Rep travail = $path\n"

   modif_img_header_keck "SnA"  $path $dest

   return

