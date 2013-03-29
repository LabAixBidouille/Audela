## @file bdi_tools_config.tcl
# @brief     Methodes dediees a la gestion des configurations de bddimages
# @author    Frederic Vachier and Jerome Berthier
# @version   1.0
# @date      2013
# @copyright GNU Public License.
# @par Ressource 
# @code  source [file join $audace(rep_install) gui audace plugin tool bddimages bdi_tools_config.tcl]
# @endcode

# Mise à jour $Id: bdi_tools_config.tcl 9215 2013-03-15 15:36:44Z jberthier $

#============================================================
## Declaration du namespace \c bdi_tools_config .
# @brief     GUI de gestion des configurations de bddimages
# @pre       Requiert bdi_tools_xml 1.0 et bddimagesAdmin 1.0
# @warning   Pour developpeur seulement
#
namespace eval bdi_tools_config {

   package require bdi_tools_xml 1.0
   package require bddimagesAdmin 1.0

   # @var Liste de tous les parametres de configuration sauves dans audace.ini
   variable allparams [list dbname login pass server dirbase dirinco dirfits dircata direrr dirlog dirtmp limit intellilists default_config current_config]

   # @var Liste des repertoires de travail de bddimages
   set bddimages_workdirs [list "cata" "fits" "incoming" "error" "log" "tmp"]

   # @var Etat de la connexion a la bdd
   variable ok_mysql_connect

}

#------------------------------------------------------------
## Chargement de la liste des noms des config XML de bddimages
# @return void
#
proc ::bdi_tools_config::load_config_names { } {

   global audace
   global bddconf

   #--- Charge les config bddimages depuis le fichier XML
   set err [::bdi_tools_xml::load_xml_config]
   #--- Recupere la liste des bddimages disponibles
   set bddconf(list_config) $::bdi_tools_xml::list_bddimages
   #--- Recupere la config par defaut [liste id name]
   set bddconf(default_config) $::bdi_tools_xml::default_config
   #--- Recupere la config par courante [liste id name]
   set bddconf(current_config) $::bdi_tools_xml::current_config

}

#------------------------------------------------------------
## Chargement d'une config XML donnee de bddimages
# @param name string Nom de la config a charger
# @return void
#
proc ::bdi_tools_config::load_config { name } {

   global bddconf

   gren_info "Loading '$name' config...\n"

   #--- Charge les config bddimages depuis le fichier XML
   #    et charge la config par defaut
   set err [::bdi_tools_xml::load_xml_config]
   #--- Recupere la liste des bddimages disponibles
   set bddconf(list_config) $::bdi_tools_xml::list_bddimages
   #--- Recupere la config par defaut name
   set bddconf(default_config) $::bdi_tools_xml::default_config

   # Charge specifiquement la config demandee
   set bddconf(current_config) [::bdi_tools_xml::load_config $name]

   #--- Test l'existence des repertoires de travail de bddimages en essayant de les creer
   catch {file mkdir $bddconf(dirbase)}
   catch {file mkdir $bddconf(dirinco)}
   catch {file mkdir $bddconf(dirfits)}
   catch {file mkdir $bddconf(dircata)}
   catch {file mkdir $bddconf(direrr)}
   catch {file mkdir $bddconf(dirlog)}
   catch {file mkdir $bddconf(dirtmp)}

   #--- Defini les variables audace indispensables
   set audace(rep_images) $bddconf(dirtmp)
   gren_info "audace(rep_images) -> $audace(rep_images)\n"
   set audace(rep_travail) $bddconf(dirtmp)
   gren_info "audace(rep_travail) -> $audace(rep_travail)\n"

   #--- Va dans le repertoire tmp
   cd $bddconf(dirtmp)

   #--- Tentative de connection a la bdd
   set ::bdi_tools_config::ok_mysql_connect 0
   set errconn [catch {::bddimages_sql::connect} connectstatus]
   if { $errconn } {
      gren_erreur "Connexion echouee : $connectstatus\n"
   } else {
      set ::bdi_tools_config::ok_mysql_connect 1
      gren_info "Connexion reussie : $connectstatus\n"
   }

   return $bddconf(name)

}

#------------------------------------------------------------
## Sauvegarde des config XML de bddimages
# @return void
#
proc ::bdi_tools_config::save { } {

   global audace
   global conf bddconf

   set bddconf(name) $bddconf(dbname)
   set bddconf(current_config) $bddconf(name)
   set bddconf(default_config) $bddconf(name)

   # Sauve les preferences bddimages dans audace.ini
   foreach param $::bdi_tools_config::allparams {
      if {[info exists bddconf($param)]} {
         set conf(bddimages,$param) $bddconf($param)
      }
   }

   # Defini la structure de la config courante a partir des champs de saisie
   ::bdi_tools_xml::set_config $bddconf(current_config)
   # Enregistre la config XML
   ::bdi_tools_xml::save_xml_config 

}

#------------------------------------------------------------
## Retourne le nom absolu des repertoires de travail de bddimages
# a partir d'un nom de repertoire de base
# @param base string Le chemin du repertoire de base
# @return void
#
proc ::bdi_tools_config::checkOtherDir { base } {

   global bddconf

   # Defini un repertoire de base -> rep_images
   foreach d $::bdi_tools_config::bddimages_workdirs {
      if {[file isdirectory [file join $base $d]]} { 
         switch $d {
            "cata"     { set bddconf(dircata) [file join $base $d] }
            "fits"     { set bddconf(dirfits) [file join $base $d] }
            "incoming" { set bddconf(dirinco) [file join $base $d] }
            "error"    -
            "errors"   { set bddconf(direrr)  [file join $base $d] }
            "log"      -
            "logs"     { set bddconf(dirlog)  [file join $base $d] }
            "tmp"      { set bddconf(dirtmp)  [file join $base $d] }
         }
      }
   }

}
