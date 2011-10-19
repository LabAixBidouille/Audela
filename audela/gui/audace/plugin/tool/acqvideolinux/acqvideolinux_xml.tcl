#
# Fichier : acqvideolinux_xml.tcl
# Description : Manipulation des fichiers de config XML de acqvideolinux
#
# Auteur : J. Berthier & F. Vachier
# Mise à jour $Id: acqvideolinux_xml.tcl 6795 2011-02-26 16:05:27Z michelpujol $
#

namespace eval ::acqvideolinuxXML {
   package provide acqvideolinuxXML 1.0
   global audace

   # Compatibilite ascendante
   if { [ package require dom ] == "2.6" } {
      interp alias {} ::dom::parse {} ::dom::tcl::parse
      interp alias {} ::dom::selectNode {} ::dom::tcl::selectNode
      interp alias {} ::dom::node {} ::dom::tcl::node
   }
   
   # Lecture des captions
   source [ file join [file dirname [info script]] acqvideolinux_xml.cap ]

   # Structure contenant les config xml
   variable xmlConfig
   # Defini le nom du fichier de config XML
   variable xmlConfigFile [file join $audace(rep_home) acqvideolinux_ini.xml]
   # Defini le fichier par defaut de config XML
   variable xmlDefaultConfigFile [file join $audace(rep_plugin) tool acqvideolinux config acqvideolinux_ini.xml]

   # Liste des acqvideolinux lues dans la config : xmlConfig(i,name)
   variable list_acqvideolinux
   # Nom de la config par defaut
   variable default_config
   # Nom de la config courante
   variable current_config

   # Variable de definition du schema XML de config acqvideolinux
   variable xml_config_docroot "config"
   variable xml_config_version "1.0"
   variable xml_nsxsi "http://www.w3.org/2001/XMLSchema-instance"

   #--------------------------------------------------
   # ::acqvideolinuxXML::get_default_dir { base dir }
   #--------------------------------------------------
   # Methode privee pour construire le chemin d'un repertoire base/dir
   # si base=='' alors le repertoire de base est audace(rep_images)
   # @param base repertoire de base
   # @param dir repertoire cible
   # @return fullpath le chemin complet du repertoire cible
   #--------------------------------------------------
   proc get_default_dir { base dir } {
      global audace
      set fullpath ""
      if {[string length [string trim $base]] > 0} {
         set fullpath [file join $base]
      } else {
         set fullpath [file join $audace(rep_images) $dir]
      }
      return $fullpath 
   }

   #--------------------------------------------------
   # ::acqvideolinuxXML::get_id_from_name { name }
   #--------------------------------------------------
   # Methode privee fournissant l'id d'une config a partir de son nom
   # Renvoie id=1 si la config demandee n'est pas trouvee
   # @param name nom de la config
   # @return id de la config correspondante
   #--------------------------------------------------
   proc get_id_from_name { name } {
      set id 1
      foreach l $::acqvideolinuxXML::list_acqvideolinux {
         if {[lindex $l 1] == $name} {
            set id [lindex $l 0]
         }
      }
      return $id
   }

   #--------------------------------------------------
   # ::acqvideolinuxXML::get_name_from_id { id }
   #--------------------------------------------------
   # Methode privee fournissant le nom d'une config a partir de son id
   # Renvoie name="?" si la config demandee n'est pas trouvee
   # @param id id de la config
   # @return nom de la config correspondante
   #--------------------------------------------------
   proc get_name_from_id { id } {
      set name ""
      foreach l $::acqvideolinuxXML::list_acqvideolinux {
         if {[lindex $l 0] == $id} {
            set name [lindex $l 1]
         }
      }
      return $name
   }

   #--------------------------------------------------
   # ::acqvideolinuxXML::get_last_id_config { }
   #--------------------------------------------------
   # Methode privee fournissant l'id le plus grand
   # Renvoie id=1 si la config demandee n'est pas trouvee
   # @return id le plus grand
   #--------------------------------------------------
   proc get_last_id_config { } {
      set id 1
      foreach l $::acqvideolinuxXML::list_acqvideolinux {
         if {[lindex $l 0] >= $id} {
            set id [lindex $l 0]
         }
      }
      return $id
   }

}

#--------------------------------------------------
#  ::acqvideolinuxXML::load_xml_config { }
#--------------------------------------------------
# Chargement de la config XML de acqvideolinux
# @return -code err
#--------------------------------------------------
proc ::acqvideolinuxXML::load_xml_config {  } {

   # Verifie que le fichier xml existe, et s'il n'existe pas
   # on le cree a partir du fichier par defaut config/acqvideolinux_ini.xml
   if {[file exists $::acqvideolinuxXML::xmlConfigFile] == 0} {
      ::console::affiche_resultat "$::caption(acqvideolinux_xml,defaultxml)"
      set errnum [catch {file copy $::acqvideolinuxXML::xmlDefaultConfigFile $::acqvideolinuxXML::xmlConfigFile} msg ]
   }

   # Charge la config xml
   set err [::acqvideolinuxXML::read_xml_config $::acqvideolinuxXML::xmlConfigFile]
   return -code $err ""

}

#--------------------------------------------------
# ::acqvideolinuxXML::read_xml_config { file_config }
#--------------------------------------------------
# Lecture de la config XML
# @param file_config nom du fichier de config XML
# @return 0
#--------------------------------------------------
proc ::acqvideolinuxXML::read_xml_config { file_config } {

   # Force la mise a null, car array set arrayName list ne le fait
   # que si la variable n'existe pas
   array unset ::acqvideolinuxXML::xmlConfig
   array unset ::acqvideolinuxXML::list_acqvideolinux

   # Structure contenant la config: force la mise a null
   array set ::acqvideolinuxXML::xmlConfig {}
   # Par defaut on considere la config id=1
   set ::acqvideolinuxXML::xmlConfigDef(default_id) 1
   # Par defaut il n'y a aucune config
   set ::acqvideolinuxXML::xmlConfigDef(nb_id) 0
   # Structure contenant la liste des config sous la forme {id name}
   set ::acqvideolinuxXML::list_acqvideolinux {}
   # Nom de la config par defaut
   set ::acqvideolinuxXML::default_config ""
   # Nom de la config courante
   set ::acqvideolinuxXML::current_config ""
   
   # Lecture du fichier
   set xmldoc ""
   set f [open $file_config r]
   while {![eof $f]} {
      append xmldoc [gets $f]
   }
   close $f

   # Analyse du doc XML pour charger la config dans xmlConfig
   set xml [::dom::parse $xmldoc]
   foreach node [::dom::selectNode $xml {descendant::acqvideolinux}] {

      if { [catch {::dom::node stringValue [::dom::selectNode $node {attribute::id}]} val] == 0 } {
         # id de la config
         set id $val
         set ::acqvideolinuxXML::xmlConfig($id,id) $id
         # compteur de config
         set ::acqvideolinuxXML::xmlConfigDef(nb_id) [expr $::acqvideolinuxXML::xmlConfigDef(nb_id) + 1]
      }
      if { [catch {::dom::node stringValue [::dom::selectNode $node {attribute::default}]} val] == 0 } { 
         set ::acqvideolinuxXML::xmlConfig($id,default) $val
         set ::acqvideolinuxXML::xmlConfigDef(default_id) $id
      } else {
         set ::acqvideolinuxXML::xmlConfig($id,default) "no"
      }
      if { [catch {::dom::node stringValue [::dom::selectNode $node {descendant::name/text()}]} val] == 0 } { 
         set ::acqvideolinuxXML::xmlConfig($id,name) $val
      }
      if { [catch {::dom::node stringValue [::dom::selectNode $node {descendant::dbname/text()}]} val] == 0 } { 
         set ::acqvideolinuxXML::xmlConfig($id,dbname) $val
      }
      if { [catch {::dom::node stringValue [::dom::selectNode $node {descendant::login/text()}]} val] == 0 } { 
         set ::acqvideolinuxXML::xmlConfig($id,login) $val
      }
      if { [catch {::dom::node stringValue [::dom::selectNode $node {descendant::pass/text()}]} val] == 0 } { 
         set ::acqvideolinuxXML::xmlConfig($id,pass) $val
      }
      if { [catch {::dom::node stringValue [::dom::selectNode $node {descendant::server/text()}]} val] == 0 } { 
         set ::acqvideolinuxXML::xmlConfig($id,server) $val
      }
      if { [catch {::dom::node stringValue [::dom::selectNode $node {descendant::port/text()}]} val] == 0 } { 
         set ::acqvideolinuxXML::xmlConfig($id,port) $val
      }
      if { [catch {::dom::node stringValue [::dom::selectNode $node {descendant::root/text()}]} val] == 0 } { 
         set ::acqvideolinuxXML::xmlConfig($id,dirbase) [::acqvideolinuxXML::get_default_dir $val ""]
      }
      if { [catch {::dom::node stringValue [::dom::selectNode $node {descendant::incoming/text()}]} val] == 0 } { 
         set ::acqvideolinuxXML::xmlConfig($id,dirinco) [::acqvideolinuxXML::get_default_dir $val "incoming"]
      }
      if { [catch {::dom::node stringValue [::dom::selectNode $node {descendant::fits/text()}]} val] == 0 } { 
         set ::acqvideolinuxXML::xmlConfig($id,dirfits) [::acqvideolinuxXML::get_default_dir $val "fits"]
      }
      if { [catch {::dom::node stringValue [::dom::selectNode $node {descendant::cata/text()}]} val] == 0 } { 
         set ::acqvideolinuxXML::xmlConfig($id,dircata) [::acqvideolinuxXML::get_default_dir $val "cata"]
      }
      if { [catch {::dom::node stringValue [::dom::selectNode $node {descendant::error/text()}]} val] == 0 } { 
         set ::acqvideolinuxXML::xmlConfig($id,direrr) [::acqvideolinuxXML::get_default_dir $val "error"]
      }
      if { [catch {::dom::node stringValue [::dom::selectNode $node {descendant::log/text()}]} val] == 0 } { 
         set ::acqvideolinuxXML::xmlConfig($id,dirlog) [::acqvideolinuxXML::get_default_dir $val "log"]
      }
      if { [catch {::dom::node stringValue [::dom::selectNode $node {descendant::screenlimit/text()}]} val] == 0 } {
         set ::acqvideolinuxXML::xmlConfig($id,limit) $val
      }

   }

   # Defini la liste des acqvideolinux disponibles [list id name]
   set prev_k 0
   foreach key [lsort [array names ::acqvideolinuxXML::xmlConfig]] {
      set k [lindex [split $key ","] 0]
      if {$k != $prev_k} {
         lappend ::acqvideolinuxXML::list_acqvideolinux [list $::acqvideolinuxXML::xmlConfig($k,id) $::acqvideolinuxXML::xmlConfig($k,name)]
         set prev_k $k
      }
   }

   # Charge la config par defaut
   set def_conf $::acqvideolinuxXML::xmlConfig($::acqvideolinuxXML::xmlConfigDef(default_id),name)
   set ::acqvideolinuxXML::default_config [::acqvideolinuxXML::get_config $def_conf]

   # Defini la config courante comme etant celle par defaut
   set ::acqvideolinuxXML::current_config $::acqvideolinuxXML::default_config

   return 0
}

#--------------------------------------------------
#  ::acqvideolinuxXML::get_config { }
#--------------------------------------------------
# Selectionne la configuration d'index = id 
# @param lconf liste contenant l'id et le nom de la config a charger
# @return id et nom de la config chargee (liste)
#--------------------------------------------------
proc ::acqvideolinuxXML::get_config { name } {

   global acqvideolinuxconf

   # Cherche l'id de la config demandee
   set id [::acqvideolinuxXML::get_id_from_name $name]
   
   # Defini les parametres de la config demandee
   set err [catch {set acqvideolinuxconf(name)    $::acqvideolinuxXML::xmlConfig($id,name)    }]
   set err [catch {set acqvideolinuxconf(dbname)  $::acqvideolinuxXML::xmlConfig($id,dbname)  }]
   set err [catch {set acqvideolinuxconf(login)   $::acqvideolinuxXML::xmlConfig($id,login)   }]
   set err [catch {set acqvideolinuxconf(pass)    $::acqvideolinuxXML::xmlConfig($id,pass)    }]
   set err [catch {set acqvideolinuxconf(server)  $::acqvideolinuxXML::xmlConfig($id,server)  }]
   set err [catch {set acqvideolinuxconf(port)    $::acqvideolinuxXML::xmlConfig($id,port)    }]
   set err [catch {set acqvideolinuxconf(dirbase) $::acqvideolinuxXML::xmlConfig($id,dirbase) }]
   set err [catch {set acqvideolinuxconf(dirinco) $::acqvideolinuxXML::xmlConfig($id,dirinco) }]
   set err [catch {set acqvideolinuxconf(dirfits) $::acqvideolinuxXML::xmlConfig($id,dirfits) }]
   set err [catch {set acqvideolinuxconf(dircata) $::acqvideolinuxXML::xmlConfig($id,dircata) }]
   set err [catch {set acqvideolinuxconf(direrr)  $::acqvideolinuxXML::xmlConfig($id,direrr)  }]
   set err [catch {set acqvideolinuxconf(dirlog)  $::acqvideolinuxXML::xmlConfig($id,dirlog)  }]
   set err [catch {set acqvideolinuxconf(limit)   $::acqvideolinuxXML::xmlConfig($id,limit)   }]
   
   # Retourne le nom de la config chargee
   return $acqvideolinuxconf(name)
}

#--------------------------------------------------
#  ::acqvideolinuxXML::add_config { }
#--------------------------------------------------
# Ajoute une config 
# @return nom de la config a charger
#--------------------------------------------------
proc ::acqvideolinuxXML::add_config { } {
   
   # Valeur de l'id existant le plus grand
   set max_id [::acqvideolinuxXML::get_last_id_config]
   # Nouvel id = max + 1
   set new_id [expr $max_id + 1]
   # Defini un template de nom pour la nouvelle config
   set new_name "acqvideolinux$new_id"

   # Incremente le nombre de config
   set ::acqvideolinuxXML::xmlConfigDef(nb_id) [expr $::acqvideolinuxXML::xmlConfigDef(nb_id) + 1]
   # Defini le template de la nouvelle config
   set ::acqvideolinuxXML::xmlConfig($new_id,id)      $new_id 
   set ::acqvideolinuxXML::xmlConfig($new_id,default) "no"
   set ::acqvideolinuxXML::xmlConfig($new_id,name)    $new_name
   set ::acqvideolinuxXML::xmlConfig($new_id,dbname)  $new_name
   set ::acqvideolinuxXML::xmlConfig($new_id,login)   "?"  
   set ::acqvideolinuxXML::xmlConfig($new_id,pass)    ""   
   set ::acqvideolinuxXML::xmlConfig($new_id,server)  ""   
   set ::acqvideolinuxXML::xmlConfig($new_id,port)    ""   
   set ::acqvideolinuxXML::xmlConfig($new_id,dirbase) "?"  
   set ::acqvideolinuxXML::xmlConfig($new_id,dirinco) "?"  
   set ::acqvideolinuxXML::xmlConfig($new_id,dirfits) "?"  
   set ::acqvideolinuxXML::xmlConfig($new_id,dircata) "?"  
   set ::acqvideolinuxXML::xmlConfig($new_id,direrr)  "?"  
   set ::acqvideolinuxXML::xmlConfig($new_id,dirlog)  "?"  
   set ::acqvideolinuxXML::xmlConfig($new_id,limit)   "10" 

   # Met a jour la liste des config
   set new_config [list $new_id $new_name]
   lappend ::acqvideolinuxXML::list_acqvideolinux $new_config

   # Retourne le nom de la nouvelle config
   return $new_name
}

#--------------------------------------------------
# ::acqvideolinuxXML::delete_config { name }
#--------------------------------------------------
# Efface la config de nom name 
# @param name nom de la config a effacer
# @return nom de la config a charger
#--------------------------------------------------
proc ::acqvideolinuxXML::delete_config { name } {
   
   # S'il ne reste qu'une config alors impossible de l'effacer
   if {$::acqvideolinuxXML::xmlConfigDef(nb_id) == 1} {
      return -code 1
   }

   # Cherche l'id de la config demandee
   set id [::acqvideolinuxXML::get_id_from_name $name]

   # Creation d'une nouvelle structure des config
   array set new_xmlConfig {}
   # Recopie toutes les config sauf celle a effacer
   foreach key [lsort [array names ::acqvideolinuxXML::xmlConfig]] {
      set k [split $key ","]
      if {[lindex $k 0] != $id} {
         set err [catch {set new_xmlConfig($key) $::acqvideolinuxXML::xmlConfig($key)}]
      }
   }
   # Mise a jour de la structure des config
   array unset ::acqvideolinuxXML::xmlConfig
   array set ::acqvideolinuxXML::xmlConfig [array get new_xmlConfig]
   
   # Decremente le nombre de config
   set ::acqvideolinuxXML::xmlConfigDef(nb_id) [expr $::acqvideolinuxXML::xmlConfigDef(nb_id) - 1]

   # Re-initialise la liste des config
   set ::acqvideolinuxXML::list_acqvideolinux {}
   # Defini la liste des acqvideolinux disponibles [list id name]
   set prev_k 0
   foreach key [lsort [array names ::acqvideolinuxXML::xmlConfig]] {
      set k [lindex [split $key ","] 0]
      if {$k != $prev_k} {
         lappend ::acqvideolinuxXML::list_acqvideolinux [list $::acqvideolinuxXML::xmlConfig($k,id) $::acqvideolinuxXML::xmlConfig($k,name)]
         set prev_k $k
      }
   }

# DEBUG
#puts "-- WRITE ------------------------------------------"
#foreach k [lsort [array names ::acqvideolinuxXML::xmlConfig]] {
#   puts "xmlConfig: $k --> $::acqvideolinuxXML::xmlConfig($k)"
#}
   
   # Defini la config chargee comme etant la derniere de la liste
   set last_id [::acqvideolinuxXML::get_last_id_config]
   # Recupere le nom de cette config
   set new_name [::acqvideolinuxXML::get_name_from_id $last_id]
   
   # Retourne le nom de la config chargee
   return $new_name
}


#--------------------------------------------------
#  ::acqvideolinuxXML::save_xml_config { }
#--------------------------------------------------
# Sauvegarde la config XML de acqvideolinux
# @return -code err
#--------------------------------------------------
proc ::acqvideolinuxXML::save_xml_config {  } {

   # Enregistre la config xml
   if {[catch {::acqvideolinuxXML::write_xml_config $::acqvideolinuxXML::xmlConfigFile} bck] != 0} {
      ::console::affiche_erreur "$::caption(acqvideolinux_xml,errorxml)\n"
      return -code 1
   } else {
      ::console::affiche_resultat "$::caption(acqvideolinux_xml,successxml)\n"
      return -code 0
   }

}

#--------------------------------------------------
#  ::acqvideolinuxXML::write_xml_config { file_config }
#--------------------------------------------------
# Ecriture de la config XML de acqvideolinux
# @param file_config nom du fichier de config XML
# @return 0
#--------------------------------------------------
proc ::acqvideolinuxXML::write_xml_config { file_config  } {

# DEBUG
#puts "-- WRITE ------------------------------------------"
#foreach k [lsort [array names ::acqvideolinuxXML::xmlConfig]] {
#   puts "xmlConfig: $k --> $::acqvideolinuxXML::xmlConfig($k)"
#}

   # Verifie que 2 config ne portent pas le meme nom
#   if {[catch {} ok] != 0} {
#      
#   }
   
   # Cree le doc xml
   set docxml [::dom::DOMImplementation create]

   # Cree la racine du document /config
   set root [::dom::document createElement $docxml $::acqvideolinuxXML::xml_config_docroot]
   ::dom::element setAttribute $root "version" $::acqvideolinuxXML::xml_config_version
   ::dom::element setAttribute $root "xmlns:xsi" $::acqvideolinuxXML::xml_nsxsi

   # Cree l'element /config/document
   set node [::dom::document createElement $root "document"]
    # --- element /config/document/version
    set subnode [::dom::document createElement $node "version"]
    ::dom::document createTextNode $subnode "0.1" 
    # --- element /config/document/date
    set subnode [::dom::document createElement $node "date"]
    ::dom::document createTextNode $subnode [::fitsdate]
    # --- element /config/document/ticket
    set subnode [::dom::document createElement $node "ticket"]
    ::dom::document createTextNode $subnode "1"
    # --- element /config/document/author
    set subnode [::dom::document createElement $node "author"]
    ::dom::document createTextNode $subnode "F. Vachier et J. Berthier"

   # Cree les elements /config/acqvideolinux
   foreach conf $::acqvideolinuxXML::list_acqvideolinux {

      # id, name
      set i [lindex $conf 0]
      set n [lindex $conf 1]

      # Cree l'element /config/acqvideolinux
      set node [::dom::document createElement $root "acqvideolinux"]
      ::dom::element setAttribute $node "id" $::acqvideolinuxXML::xmlConfig($i,id)
      if {$::acqvideolinuxXML::xmlConfig($i,name) == $::acqvideolinuxXML::default_config} {
         ::dom::element setAttribute $node "default" "yes"
      }
      
      # --- /config/acqvideolinux/name
      set subnode [::dom::document createElement $node "name"]
      if {[info exists ::acqvideolinuxXML::xmlConfig($i,name)]} {
         ::dom::document createTextNode $subnode $::acqvideolinuxXML::xmlConfig($i,name)
      }

      # --- /config/acqvideolinux/sql
      set subnode [::dom::document createElement $node "sql"]
        # --- /config/acqvideolinux/sql/dbname
        set subsubnode [::dom::document createElement $subnode "dbname"]
        if {[info exists ::acqvideolinuxXML::xmlConfig($i,dbname)]} {
           ::dom::document createTextNode $subsubnode $::acqvideolinuxXML::xmlConfig($i,dbname)
        }
        # --- /config/acqvideolinux/sql/login
        set subsubnode [::dom::document createElement $subnode "login"]
        if {[info exists ::acqvideolinuxXML::xmlConfig($i,login)]} {
           ::dom::document createTextNode $subsubnode $::acqvideolinuxXML::xmlConfig($i,login)
        }
        # --- /config/acqvideolinux/sql/pass
        set subsubnode [::dom::document createElement $subnode "pass"]
        if {[info exists ::acqvideolinuxXML::xmlConfig($i,pass)]} {
           ::dom::document createTextNode $subsubnode $::acqvideolinuxXML::xmlConfig($i,pass)
        }
        # --- /config/acqvideolinux/sql/ip
        set subsubnode [::dom::document createElement $subnode "server"]
        if {[info exists ::acqvideolinuxXML::xmlConfig($i,server)]} {
           ::dom::document createTextNode $subsubnode $::acqvideolinuxXML::xmlConfig($i,server)
        }
        # --- /config/acqvideolinux/sql/port
        set subsubnode [::dom::document createElement $subnode "port"]
        if {[info exists ::acqvideolinuxXML::xmlConfig($i,port)]} {
           ::dom::document createTextNode $subsubnode $::acqvideolinuxXML::xmlConfig($i,port)
        }

      # --- /config/acqvideolinux/files
      set subnode [::dom::document createElement $node "files"]
        # --- /config/acqvideolinux/files/root
        set subsubnode [::dom::document createElement $subnode "root"]
        if {[info exists ::acqvideolinuxXML::xmlConfig($i,dirbase)]} {
           ::dom::document createTextNode $subsubnode $::acqvideolinuxXML::xmlConfig($i,dirbase)
        }
        # --- /config/acqvideolinux/files/incoming
        set subsubnode [::dom::document createElement $subnode "incoming"]
        if {[info exists ::acqvideolinuxXML::xmlConfig($i,dirbase)]} {
           ::dom::document createTextNode $subsubnode $::acqvideolinuxXML::xmlConfig($i,dirinco)
        }
        # --- /config/acqvideolinux/files/fits
        set subsubnode [::dom::document createElement $subnode "fits"]
        if {[info exists ::acqvideolinuxXML::xmlConfig($i,dirbase)]} {
           ::dom::document createTextNode $subsubnode $::acqvideolinuxXML::xmlConfig($i,dirfits)
        }
        # --- /config/acqvideolinux/files/cata
        set subsubnode [::dom::document createElement $subnode "cata"]
        if {[info exists ::acqvideolinuxXML::xmlConfig($i,dirbase)]} {
           ::dom::document createTextNode $subsubnode $::acqvideolinuxXML::xmlConfig($i,dircata)
        }
        # --- /config/acqvideolinux/files/error
        set subsubnode [::dom::document createElement $subnode "error"]
        if {[info exists ::acqvideolinuxXML::xmlConfig($i,dirbase)]} {
           ::dom::document createTextNode $subsubnode $::acqvideolinuxXML::xmlConfig($i,direrr)
        }
        # --- /config/acqvideolinux/files/log
        set subsubnode [::dom::document createElement $subnode "log"]
        if {[info exists ::acqvideolinuxXML::xmlConfig($i,dirbase)]} {
           ::dom::document createTextNode $subsubnode $::acqvideolinuxXML::xmlConfig($i,dirlog)
        }
  
      # --- /config/acqvideolinux/screenlimit
      set subnode [::dom::document createElement $node "screenlimit"]
      if {[info exists ::acqvideolinuxXML::xmlConfig($i,limit)]} {
         ::dom::document createTextNode $subnode $::acqvideolinuxXML::xmlConfig($i,limit)
      }
   }
   
   # Sauve le fichier XML de config
   set fxml [open $file_config "w"]
   puts $fxml [::dom::DOMImplementation serialize $docxml -indent true]
   close $fxml

   return 0
}   

#--------------------------------------------------
#  ::acqvideolinuxXML::set_config { name }
#--------------------------------------------------
# Defini la config a partir de son nom 
# @param name nom de la config a charger
# @return void
#--------------------------------------------------
proc ::acqvideolinuxXML::set_config { name } {

   global acqvideolinuxconf

   # Defini l'id de la config
   set id [::acqvideolinuxXML::get_id_from_name $name]
   
   # Defini les parametres de la config demandee
   set err [catch {set ::acqvideolinuxXML::xmlConfig($id,name)    $acqvideolinuxconf(name)    }]
   set err [catch {set ::acqvideolinuxXML::xmlConfig($id,dbname)  $acqvideolinuxconf(dbname)  }]
   set err [catch {set ::acqvideolinuxXML::xmlConfig($id,login)   $acqvideolinuxconf(login)   }]
   set err [catch {set ::acqvideolinuxXML::xmlConfig($id,pass)    $acqvideolinuxconf(pass)    }]
   set err [catch {set ::acqvideolinuxXML::xmlConfig($id,server)  $acqvideolinuxconf(server)  }]
   set err [catch {set ::acqvideolinuxXML::xmlConfig($id,port)    $acqvideolinuxconf(port)    }]
   set err [catch {set ::acqvideolinuxXML::xmlConfig($id,dirbase) $acqvideolinuxconf(dirbase) }]
   set err [catch {set ::acqvideolinuxXML::xmlConfig($id,dirinco) $acqvideolinuxconf(dirinco) }]
   set err [catch {set ::acqvideolinuxXML::xmlConfig($id,dirfits) $acqvideolinuxconf(dirfits) }]
   set err [catch {set ::acqvideolinuxXML::xmlConfig($id,dircata) $acqvideolinuxconf(dircata) }]
   set err [catch {set ::acqvideolinuxXML::xmlConfig($id,direrr)  $acqvideolinuxconf(direrr)  }]
   set err [catch {set ::acqvideolinuxXML::xmlConfig($id,dirlog)  $acqvideolinuxconf(dirlog)  }]
   set err [catch {set ::acqvideolinuxXML::xmlConfig($id,limit)   $acqvideolinuxconf(limit)   }]
   return 0
}
