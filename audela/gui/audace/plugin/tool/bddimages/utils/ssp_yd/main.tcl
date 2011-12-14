
# source /srv/develop/audela/gui/audace/plugin/tool/bddimages/utils/ssp_yd/main.tcl


##
# @file
#
# @author fv
#
# @brief Traitement des archives dans bddimages a partir de la base de donnees SSP

source /srv/develop/audela/gui/audace/plugin/tool/bddimages/utils/astroid/get_one_image.tcl
source /srv/develop/audela/gui/audace/plugin/tool/bddimages/utils/ssp_yd/get_cata.tcl
source /srv/develop/audela/gui/audace/plugin/tool/bddimages/utils/astroid/imprimlist.tcl
source /srv/develop/audela/gui/audace/plugin/tool/bddimages/utils/ssp_yd/visu.tcl
source /srv/develop/audela/gui/audace/plugin/tool/bddimages/utils/astroid/astrometry.tcl
source /srv/develop/audela/gui/audace/plugin/tool/bddimages/utils/astroid/photometry.tcl
source /srv/develop/audela/gui/audace/plugin/tool/bddimages/utils/astroid/identification.tcl
source /srv/develop/audela/gui/audace/vo_tools.tcl
source /srv/develop/audela/gui/audace/plugin/tool/av4l/av4l_extraction.tcl

::bddimagesXML::load_xml_config
::bddimagesXML::get_config bddimages_cador

cleanmark

gren_info "****************************************************************** \n"
gren_info "** info de la configuration \n"

gren_info "SSP_PLUGIN: name    : $bddconf(name)    \n"
gren_info "SSP_PLUGIN: dbname  : $bddconf(dbname)  \n"
gren_info "SSP_PLUGIN: login   : $bddconf(login)   \n"
gren_info "SSP_PLUGIN: pass    : $bddconf(pass)    \n"
gren_info "SSP_PLUGIN: server  : $bddconf(server)  \n"
gren_info "SSP_PLUGIN: port    : $bddconf(port)    \n"
gren_info "SSP_PLUGIN: dirbase : $bddconf(dirbase) \n"
gren_info "SSP_PLUGIN: dirinco : $bddconf(dirinco) \n"
gren_info "SSP_PLUGIN: dirfits : $bddconf(dirfits) \n"
gren_info "SSP_PLUGIN: dircata : $bddconf(dircata) \n"
gren_info "SSP_PLUGIN: direrr  : $bddconf(direrr)  \n"
gren_info "SSP_PLUGIN: dirlog  : $bddconf(dirlog)  \n"
gren_info "SSP_PLUGIN: dirtmp  : $bddconf(dirtmp)  \n"
gren_info "SSP_PLUGIN: limit   : $bddconf(limit)   \n"

gren_info "****************************************************************** \n"
gren_info "** info de la visu \n"

   #set bddconf(visuno) [::visu::create $bddconf(bufno) 1]
   set bddconf(visuno) 1
   set bddconf(bufno) [::confVisu::getBufNo $bddconf(visuno)]
   gren_info "SSP_PLUGIN: bufNo   : $bddconf(bufno)   \n"
   gren_info "SSP_PLUGIN: visuNo  : $bddconf(visuno)   \n"

gren_info "****************************************************************** \n"
gren_info "** info de la base \n"

   # Selection de la bdd
   set err [catch {::bddimages_sql::sql query "use $bddconf(dbname);"} msg]
   if {$err} {
      gren_info "SSP_PLUGIN: ERREUR 1 \n"
      gren_info "SSP_PLUGIN:        NUM : <$err> \n" 
      gren_info "SSP_PLUGIN:        MSG : <$msg> \n"
      }

   # Nombre d image dans bddimages
   set sqlcmd "select count(*) from images;"
   set err [catch {set resultsql [::bddimages_sql::sql query $sqlcmd]} msg]
   if {$err} {
      gren_info "SSP_PLUGIN: ERREUR 2 \n"
      gren_info "SSP_PLUGIN:        NUM : <$err> \n" 
      gren_info "SSP_PLUGIN:        MSG : <$msg> \n"
      }
   gren_info "SSP_PLUGIN: NB IMAGE SUR $bddconf(dbname) =<$resultsql>\n\n"

   set sqlcmd    "select count(*) from catas where ssp_date<now()"
   set err [catch {set resultsql [::bddimages_sql::sql query $sqlcmd]} msg]
   if {$err} {
      gren_info "SSP_PLUGIN: ERREUR 2 \n"
      gren_info "SSP_PLUGIN:        NUM : <$err> \n" 
      gren_info "SSP_PLUGIN:        MSG : <$msg> \n"
      }
   gren_info "SSP_PLUGIN: NB IMAGE a traiter SUR $bddconf(dbname) =<$resultsql>\n\n"

   set nbimg $resultsql

   gren_info "****************************************************************** \n"
   gren_info "** Chargement d'une image \n"


   set r [get_one_image]
   gren_info "SSP_PLUGIN: result one_ssp   : $r \n"

   gren_info "SSP_PLUGIN:idbddcata  = $ssp_image(idbddcata)\n"
   gren_info "SSP_PLUGIN:idbddimage = $ssp_image(idbddimg)\n"
   gren_info "SSP_PLUGIN:cata       = $ssp_image(dir_cata_file)/$ssp_image(cata_filename)\n"
   gren_info "SSP_PLUGIN:image      = $ssp_image(fits_dir)/$ssp_image(fits_filename)\n"
   gren_info "SSP_PLUGIN:idheader   = $ssp_image(idheader)\n"
   gren_info "SSP_PLUGIN:dateobs    = $ssp_image(dateobs)\n"
   gren_info "SSP_PLUGIN:ra         = $ssp_image(ra)\n"
   gren_info "SSP_PLUGIN:dec        = $ssp_image(dec)\n"
   gren_info "SSP_PLUGIN:telescop   = $ssp_image(telescop)\n"
   gren_info "SSP_PLUGIN:exposure   = $ssp_image(exposure)\n"
   gren_info "SSP_PLUGIN:filter     = $ssp_image(filter)\n"


   gren_info "****************************************************************** \n"
   gren_info "** Lecture du CATA \n"

   # Recupere les noms des fichiers
   set fitsfile "$bddconf(dirbase)/$ssp_image(fits_dir)/$ssp_image(fits_filename)"
   ::console::affiche_resultat "FILE : $fitsfile\n"
   set catafile "$bddconf(dirbase)/$ssp_image(dir_cata_file)/$ssp_image(cata_filename)"
   ::console::affiche_resultat "CATA : $catafile\n"

   # Recupere le catalogue des sources correspondant a l image
   set listsources [get_cata $catafile]

   # Affichage la liste des sources
   #imprim_sources $listsources

   # Affichage de l image
   affich_image $fitsfile
   ::console::affiche_resultat "IMAGE AFFICHEE\n"

   # Affichage centre champ de l image
   set centre [list {"CENTRE" {} {} } [list [list [list "CENTRE" [list $ssp_image(ra) $ssp_image(dec)] {}]]]]
    affich_rond $centre "CENTRE" "red" 1
 #   ::console::affiche_resultat "ROND ROUGE: centre du champ provenant du header fits\n"

   gren_info "****************************************************************** \n"
# {IMG {ra dec poserr mag magerr} 
#      {id flag xpos ypos instr_mag err_mag flux_sex err_flux_sex ra dec calib_mag 
#      calib_mag_ss1 err_calib_mag_ss1 calib_mag_ss2 err_calib_mag_ss2 
#      nb_neighbours radius background_sex x2_momentum_sex y2_momentum_sex 
#      xy_momentum_sex major_axis_sex minor_axis_sex position_angle_sex fwhm_sex flag_sex}
# }
# {USNO2 {ra dec poserr mag magerr} 
#        {} 
# }
::console::affiche_resultat "[lindex $listsources 0]  \n"

   set unesource [lindex [lindex $listsources 1] 10]
   ::console::affiche_resultat "$unesource \n"
   set ra  [lindex [lindex [lindex $unesource 0] 1] 0]
   set dec [lindex [lindex [lindex $unesource 0] 1] 1]
   set x [lindex [lindex [lindex $unesource 0] 2] 2]
   set y [lindex [lindex [lindex $unesource 0] 2] 3]
   set fwhm [lindex [lindex [lindex $unesource 0] 2] 24]
   ::console::affiche_resultat "X $x / Y $y / FWHM $fwhm\n"

   set source [list {"SOURCE" {} {} } [list [list [list "SOURCE" [list $ra $dec] {}]]]]
   affich_rond $source "SOURCE" "green" 1

   gren_info "[::confVisu::screen2Canvas  $bddconf(visuno) [list $x $y]]\n"
   gren_info "[::confVisu::canvas2Picture $bddconf(visuno) [list $x $y]]\n"

   affich_un_rond_xy $x $y "green" 5  4

   set results [ ::av4l_photom::photom_methode $x $y $fwhm $bddconf(bufno) ]
   set x2 [lindex $results 0]
   set y2 [lindex $results 1]
   ::console::affiche_resultat "X $x2 / Y $y2 \n"
   affich_un_rond_xy $x2 $y2 "blue" 5  2
   ::console::affiche_resultat "diff X [expr abs($x2-$x)] / Y [expr abs($y2-$y)] \n"
   
   gren_info "$results\n"

 #   ::visu::delete $bddconf(visuno)


   # FIN
   gren_info "****************************************************************** \n"
   gren_info "FIN de script\n"


# buf1 load  /astrodata/Observations/Images/bddimages/bddimages_cador/fits/tarot_chili/2009/11/19/IM_20091119_055755761_230749_54410102.fits.gz
# set autocuts [buf1 autocuts]
# visu1 disp [list [lindex $autocuts 0] [lindex $autocuts 1]]
# loadima /astrodata/Observations/Images/bddimages/bddimages_cador/fits/tarot_chili/2009/11/19/IM_20091119_055755761_230749_54410102.fits.gz
