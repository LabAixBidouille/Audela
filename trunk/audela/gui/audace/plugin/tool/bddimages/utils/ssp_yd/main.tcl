
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
source /srv/develop/audela/gui/audace/plugin/tool/bddimages/utils/astroid/visu.tcl
source /srv/develop/audela/gui/audace/plugin/tool/bddimages/utils/astroid/astrometry.tcl
source /srv/develop/audela/gui/audace/plugin/tool/bddimages/utils/astroid/photometry.tcl
source /srv/develop/audela/gui/audace/plugin/tool/bddimages/utils/astroid/identification.tcl
source /srv/develop/audela/gui/audace/vo_tools.tcl

::bddimagesXML::load_xml_config
::bddimagesXML::get_config bddimages_cador

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
   affich_rond $centre "CENTRE" "red" 7
   ::console::affiche_resultat "ROND ROUGE: centre du champ provenant du header fits\n"
  

   # Recupere le catalog astrometrique
   set astrometric_list [get_astrometric_catalog $ssp_image(ra) $ssp_image(dec) 30]

   # Affichage des ronds verts
   affich_rond $astrometric_list "TYCHO2" "blue" 2
   ::console::affiche_resultat "ROND BLEU: Etoiles tycho 2\n"

   set astrometric_list [add_sun_star "TYCHO2" $astrometric_list]

   # Affichage des ronds verts
   affich_rond $astrometric_list "SUNLIKE" "yellow" 2
   ::console::affiche_resultat "ROND JAUNE: Etoiles de type solaire\n"

   set starident [ identification $listsources "USNOA2" $astrometric_list "TYCHO2" 30.0 10.0 10.0 ]
   affich_rond $starident "TYCHO2" "red" 2

   # FIN
   gren_info "****************************************************************** \n"
   gren_info "FIN de script\n"
