#
# Fichier : bddimages_xml.tcl
# Description : Manipulation des fichiers de config XML de bddimages
#
# Auteur : J. Berthier & F. Vachier
# Mise à jour $Id$
#

namespace eval ::bddimagesXML {
   package provide bddimagesXML 1.0
   global audace

   # Compatibilite ascendante
   if { [ package require dom ] == "2.6" } {
      interp alias {} ::dom::parse {} ::dom::tcl::parse
      interp alias {} ::dom::selectNode {} ::dom::tcl::selectNode
      interp alias {} ::dom::node {} ::dom::tcl::node
   }
   
   # Lecture des captions
   source [ file join [file dirname [info script]] bddimages_xml.cap ]

   # Structure contenant les config xml
   variable xmlConfig
   # Defini le nom du fichier de config XML
   variable xmlConfigFile [file join $audace(rep_home) bddimages_ini.xml]
   # Defini le fichier par defaut de config XML
   variable xmlDefaultConfigFile [file join $audace(rep_plugin) tool bddimages config bddimages_ini.xml]

   # Liste des bddimages lues dans la config : xmlConfig(i,name)
   variable list_bddimages
   # Nom de la config par defaut
   variable default_config
   # Nom de la config courante
   variable current_config

   # Variable de definition du schema XML de config bddimages
   variable xml_config_docroot "config"
   variable xml_config_version "1.0"
   variable xml_nsxsi "http://www.w3.org/2001/XMLSchema-instance"

   #--------------------------------------------------
   # ::bddimagesXML::get_default_dir { base dir }
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
   # ::bddimagesXML::get_id_from_name { name }
   #--------------------------------------------------
   # Methode privee fournissant l'id d'une config a partir de son nom
   # Renvoie id=1 si la config demandee n'est pas trouvee
   # @param name nom de la config
   # @return id de la config correspondante
   #--------------------------------------------------
   proc get_id_from_name { name } {
      set id 1
      foreach l $::bddimagesXML::list_bddimages {
         if {[lindex $l 1] == $name} {
            set id [lindex $l 0]
         }
      }
      return $id
   }

   #--------------------------------------------------
   # ::bddimagesXML::get_name_from_id { id }
   #--------------------------------------------------
   # Methode privee fournissant le nom d'une config a partir de son id
   # Renvoie name="?" si la config demandee n'est pas trouvee
   # @param id id de la config
   # @return nom de la config correspondante
   #--------------------------------------------------
   proc get_name_from_id { id } {
      set name ""
      foreach l $::bddimagesXML::list_bddimages {
         if {[lindex $l 0] == $id} {
            set name [lindex $l 1]
         }
      }
      return $name
   }

   #--------------------------------------------------
   # ::bddimagesXML::get_last_id_config { }
   #--------------------------------------------------
   # Methode privee fournissant l'id le plus grand
   # Renvoie id=1 si la config demandee n'est pas trouvee
   # @return id le plus grand
   #--------------------------------------------------
   proc get_last_id_config { } {
      set id 1
      foreach l $::bddimagesXML::list_bddimages {
         if {[lindex $l 0] >= $id} {
            set id [lindex $l 0]
         }
      }
      return $id
   }

}

#--------------------------------------------------
#  ::bddimagesXML::load_xml_config { }
#--------------------------------------------------
# Chargement de la config XML de bddimages
# @return -code err
#--------------------------------------------------
proc ::bddimagesXML::load_xml_config {  } {

   # Verifie que le fichier xml existe, et s'il n'existe pas
   # on le cree a partir du fichier par defaut config/bddimages_ini.xml
   if {[file exists $::bddimagesXML::xmlConfigFile] == 0} {
      ::console::affiche_resultat "$::caption(bddimages_xml,defaultxml)"
      set errnum [catch {file copy $::bddimagesXML::xmlDefaultConfigFile $::bddimagesXML::xmlConfigFile} msg ]
   }

   # Charge la config xml
   set err [::bddimagesXML::read_xml_config $::bddimagesXML::xmlConfigFile]
   return -code $err ""

}

#--------------------------------------------------
# ::bddimagesXML::read_xml_config { file_config }
#--------------------------------------------------
# Lecture de la config XML
# @param file_config nom du fichier de config XML
# @return 0
#--------------------------------------------------
proc ::bddimagesXML::read_xml_config { file_config } {

   # Force la mise a null, car array set arrayName list ne le fait
   # que si la variable n'existe pas
   array unset ::bddimagesXML::xmlConfig
   array unset ::bddimagesXML::list_bddimages

   # Structure contenant la config: force la mise a null
   array set ::bddimagesXML::xmlConfig {}
   # Par defaut on considere la config id=1
   set ::bddimagesXML::xmlConfigDef(default_id) 1
   # Par defaut il n'y a aucune config
   set ::bddimagesXML::xmlConfigDef(nb_id) 0
   # Structure contenant la liste des config sous la forme {id name}
   set ::bddimagesXML::list_bddimages {}
   # Nom de la config par defaut
   set ::bddimagesXML::default_config ""
   # Nom de la config courante
   set ::bddimagesXML::current_config ""
   
   # Lecture du fichier
   set xmldoc ""
   set f [open $file_config r]
   while {![eof $f]} {
      append xmldoc [gets $f]
   }
   close $f

   # Analyse du doc XML pour charger la config dans xmlConfig
   set xml [::dom::parse $xmldoc]
   foreach node [::dom::selectNode $xml {descendant::bddimages}] {

      if { [catch {::dom::node stringValue [::dom::selectNode $node {attribute::id}]} val] == 0 } {
         # id de la config
         set id $val
         set ::bddimagesXML::xmlConfig($id,id) $id
         # compteur de config
         set ::bddimagesXML::xmlConfigDef(nb_id) [expr $::bddimagesXML::xmlConfigDef(nb_id) + 1]
      }
      if { [catch {::dom::node stringValue [::dom::selectNode $node {attribute::default}]} val] == 0 } { 
         set ::bddimagesXML::xmlConfig($id,default) $val
         set ::bddimagesXML::xmlConfigDef(default_id) $id
      } else {
         set ::bddimagesXML::xmlConfig($id,default) "no"
      }
      if { [catch {::dom::node stringValue [::dom::selectNode $node {descendant::name/text()}]} val] == 0 } { 
         set ::bddimagesXML::xmlConfig($id,name) $val
      }
      if { [catch {::dom::node stringValue [::dom::selectNode $node {descendant::dbname/text()}]} val] == 0 } { 
         set ::bddimagesXML::xmlConfig($id,dbname) $val
      }
      if { [catch {::dom::node stringValue [::dom::selectNode $node {descendant::login/text()}]} val] == 0 } { 
         set ::bddimagesXML::xmlConfig($id,login) $val
      }
      if { [catch {::dom::node stringValue [::dom::selectNode $node {descendant::pass/text()}]} val] == 0 } { 
         set ::bddimagesXML::xmlConfig($id,pass) $val
      }
      if { [catch {::dom::node stringValue [::dom::selectNode $node {descendant::server/text()}]} val] == 0 } { 
         set ::bddimagesXML::xmlConfig($id,server) $val
      }
      if { [catch {::dom::node stringValue [::dom::selectNode $node {descendant::port/text()}]} val] == 0 } { 
         set ::bddimagesXML::xmlConfig($id,port) $val
      }
      if { [catch {::dom::node stringValue [::dom::selectNode $node {descendant::root/text()}]} val] == 0 } { 
         set ::bddimagesXML::xmlConfig($id,dirbase) [::bddimagesXML::get_default_dir $val ""]
      }
      if { [catch {::dom::node stringValue [::dom::selectNode $node {descendant::incoming/text()}]} val] == 0 } { 
         set ::bddimagesXML::xmlConfig($id,dirinco) [::bddimagesXML::get_default_dir $val "incoming"]
      }
      if { [catch {::dom::node stringValue [::dom::selectNode $node {descendant::fits/text()}]} val] == 0 } { 
         set ::bddimagesXML::xmlConfig($id,dirfits) [::bddimagesXML::get_default_dir $val "fits"]
      }
      if { [catch {::dom::node stringValue [::dom::selectNode $node {descendant::cata/text()}]} val] == 0 } { 
         set ::bddimagesXML::xmlConfig($id,dircata) [::bddimagesXML::get_default_dir $val "cata"]
      }
      if { [catch {::dom::node stringValue [::dom::selectNode $node {descendant::error/text()}]} val] == 0 } { 
         set ::bddimagesXML::xmlConfig($id,direrr) [::bddimagesXML::get_default_dir $val "error"]
      }
      if { [catch {::dom::node stringValue [::dom::selectNode $node {descendant::log/text()}]} val] == 0 } { 
         set ::bddimagesXML::xmlConfig($id,dirlog) [::bddimagesXML::get_default_dir $val "log"]
      }
      if { [catch {::dom::node stringValue [::dom::selectNode $node {descendant::tmp/text()}]} val] == 0 } { 
         set ::bddimagesXML::xmlConfig($id,dirtmp) [::bddimagesXML::get_default_dir $val "tmp"]
      }
      if { [catch {::dom::node stringValue [::dom::selectNode $node {descendant::screenlimit/text()}]} val] == 0 } {
         set ::bddimagesXML::xmlConfig($id,limit) $val
      }

   }

   # Defini la liste des bddimages disponibles [list id name]
   set prev_k 0
   foreach key [lsort [array names ::bddimagesXML::xmlConfig]] {
      set k [lindex [split $key ","] 0]
      if {$k != $prev_k} {
         lappend ::bddimagesXML::list_bddimages [list $::bddimagesXML::xmlConfig($k,id) $::bddimagesXML::xmlConfig($k,name)]
         set prev_k $k
      }
   }

   # Charge la config par defaut
   set def_conf $::bddimagesXML::xmlConfig($::bddimagesXML::xmlConfigDef(default_id),name)
   set ::bddimagesXML::default_config [::bddimagesXML::get_config $def_conf]

   # Defini la config courante comme etant celle par defaut
   set ::bddimagesXML::current_config $::bddimagesXML::default_config

   return 0
}

#--------------------------------------------------
#  ::bddimagesXML::get_config { }
#--------------------------------------------------
# Selectionne la configuration d'index = id 
# @param lconf liste contenant l'id et le nom de la config a charger
# @return id et nom de la config chargee (liste)
#--------------------------------------------------
proc ::bddimagesXML::get_config { name } {

   global bddconf

   # Cherche l'id de la config demandee
   set id [::bddimagesXML::get_id_from_name $name]
   
   # Defini les parametres de la config demandee
   set err [catch {set bddconf(name)    $::bddimagesXML::xmlConfig($id,name)    }]
   set err [catch {set bddconf(dbname)  $::bddimagesXML::xmlConfig($id,dbname)  }]
   set err [catch {set bddconf(login)   $::bddimagesXML::xmlConfig($id,login)   }]
   set err [catch {set bddconf(pass)    $::bddimagesXML::xmlConfig($id,pass)    }]
   set err [catch {set bddconf(server)  $::bddimagesXML::xmlConfig($id,server)  }]
   set err [catch {set bddconf(port)    $::bddimagesXML::xmlConfig($id,port)    }]
   set err [catch {set bddconf(dirbase) $::bddimagesXML::xmlConfig($id,dirbase) }]
   set err [catch {set bddconf(dirinco) $::bddimagesXML::xmlConfig($id,dirinco) }]
   set err [catch {set bddconf(dirfits) $::bddimagesXML::xmlConfig($id,dirfits) }]
   set err [catch {set bddconf(dircata) $::bddimagesXML::xmlConfig($id,dircata) }]
   set err [catch {set bddconf(direrr)  $::bddimagesXML::xmlConfig($id,direrr)  }]
   set err [catch {set bddconf(dirlog)  $::bddimagesXML::xmlConfig($id,dirlog)  }]
   set err [catch {set bddconf(dirtmp)  $::bddimagesXML::xmlConfig($id,dirtmp)  }]
   set err [catch {set bddconf(limit)   $::bddimagesXML::xmlConfig($id,limit)   }]
   
   # Retourne le nom de la config chargee
   return $bddconf(name)
}

#--------------------------------------------------
#  ::bddimagesXML::add_config { }
#--------------------------------------------------
# Ajoute une config 
# @return nom de la config a charger
#--------------------------------------------------
proc ::bddimagesXML::add_config { } {
   
   # Valeur de l'id existant le plus grand
   set max_id [::bddimagesXML::get_last_id_config]
   # Nouvel id = max + 1
   set new_id [expr $max_id + 1]
   # Defini un template de nom pour la nouvelle config
   set new_name "bddimages$new_id"

   # Incremente le nombre de config
   set ::bddimagesXML::xmlConfigDef(nb_id) [expr $::bddimagesXML::xmlConfigDef(nb_id) + 1]
   # Defini le template de la nouvelle config
   set ::bddimagesXML::xmlConfig($new_id,id)      $new_id 
   set ::bddimagesXML::xmlConfig($new_id,default) "no"
   set ::bddimagesXML::xmlConfig($new_id,name)    $new_name
   set ::bddimagesXML::xmlConfig($new_id,dbname)  $new_name
   set ::bddimagesXML::xmlConfig($new_id,login)   ""  
   set ::bddimagesXML::xmlConfig($new_id,pass)    ""   
   set ::bddimagesXML::xmlConfig($new_id,server)  ""   
   set ::bddimagesXML::xmlConfig($new_id,port)    ""   
   set ::bddimagesXML::xmlConfig($new_id,dirbase) ""  
   set ::bddimagesXML::xmlConfig($new_id,dirinco) ""  
   set ::bddimagesXML::xmlConfig($new_id,dirfits) ""  
   set ::bddimagesXML::xmlConfig($new_id,dircata) ""  
   set ::bddimagesXML::xmlConfig($new_id,direrr)  ""  
   set ::bddimagesXML::xmlConfig($new_id,dirlog)  ""  
   set ::bddimagesXML::xmlConfig($new_id,dirtmp)  ""  
   set ::bddimagesXML::xmlConfig($new_id,limit)   "10" 

   # Met a jour la liste des config
   set new_config [list $new_id $new_name]
   lappend ::bddimagesXML::list_bddimages $new_config

   # Retourne le nom de la nouvelle config
   return $new_name
}

#--------------------------------------------------
# ::bddimagesXML::delete_config { name }
#--------------------------------------------------
# Efface la config de nom name 
# @param name nom de la config a effacer
# @return nom de la config a charger
#--------------------------------------------------
proc ::bddimagesXML::delete_config { name } {
   
   # S'il ne reste qu'une config alors impossible de l'effacer
   if {$::bddimagesXML::xmlConfigDef(nb_id) == 1} {
      return -code 1
   }

   # Cherche l'id de la config demandee
   set id [::bddimagesXML::get_id_from_name $name]

   # Creation d'une nouvelle structure des config
   array set new_xmlConfig {}
   # Recopie toutes les config sauf celle a effacer
   foreach key [lsort [array names ::bddimagesXML::xmlConfig]] {
      set k [split $key ","]
      if {[lindex $k 0] != $id} {
         set err [catch {set new_xmlConfig($key) $::bddimagesXML::xmlConfig($key)}]
      }
   }
   # Mise a jour de la structure des config
   array unset ::bddimagesXML::xmlConfig
   array set ::bddimagesXML::xmlConfig [array get new_xmlConfig]
   
   # Decremente le nombre de config
   set ::bddimagesXML::xmlConfigDef(nb_id) [expr $::bddimagesXML::xmlConfigDef(nb_id) - 1]

   # Re-initialise la liste des config
   set ::bddimagesXML::list_bddimages {}
   # Defini la liste des bddimages disponibles [list id name]
   set prev_k 0
   foreach key [lsort [array names ::bddimagesXML::xmlConfig]] {
      set k [lindex [split $key ","] 0]
      if {$k != $prev_k} {
         lappend ::bddimagesXML::list_bddimages [list $::bddimagesXML::xmlConfig($k,id) $::bddimagesXML::xmlConfig($k,name)]
         set prev_k $k
      }
   }

# DEBUG
#puts "-- WRITE ------------------------------------------"
#foreach k [lsort [array names ::bddimagesXML::xmlConfig]] {
#   puts "xmlConfig: $k --> $::bddimagesXML::xmlConfig($k)"
#}
   
   # Defini la config chargee comme etant la derniere de la liste
   set last_id [::bddimagesXML::get_last_id_config]
   # Recupere le nom de cette config
   set new_name [::bddimagesXML::get_name_from_id $last_id]
   
   # Retourne le nom de la config chargee
   return $new_name
}


#--------------------------------------------------
#  ::bddimagesXML::save_xml_config { }
#--------------------------------------------------
# Sauvegarde la config XML de bddimages
# @return -code err
#--------------------------------------------------
proc ::bddimagesXML::save_xml_config {  } {

   # Enregistre la config xml
   if {[catch {::bddimagesXML::write_xml_config $::bddimagesXML::xmlConfigFile} bck] != 0} {
      ::console::affiche_erreur "$::caption(bddimages_xml,errorxml)\n"
      return -code 1
   } else {
      ::console::affiche_resultat "$::caption(bddimages_xml,successxml)\n"
      return -code 0
   }

}

#--------------------------------------------------
#  ::bddimagesXML::write_xml_config { file_config }
#--------------------------------------------------
# Ecriture de la config XML de bddimages
# @param file_config nom du fichier de config XML
# @return 0
#--------------------------------------------------
proc ::bddimagesXML::write_xml_config { file_config  } {

# DEBUG
#puts "-- WRITE ------------------------------------------"
#foreach k [lsort [array names ::bddimagesXML::xmlConfig]] {
#   puts "xmlConfig: $k --> $::bddimagesXML::xmlConfig($k)"
#}

   # Verifie que 2 config ne portent pas le meme nom
#   if {[catch {} ok] != 0} {
#      
#   }
   
   # Cree le doc xml
   set docxml [::dom::DOMImplementation create]

   # Cree la racine du document /config
   set root [::dom::document createElement $docxml $::bddimagesXML::xml_config_docroot]
   ::dom::element setAttribute $root "version" $::bddimagesXML::xml_config_version
   ::dom::element setAttribute $root "xmlns:xsi" $::bddimagesXML::xml_nsxsi

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

   # Cree les elements /config/bddimages
   foreach conf $::bddimagesXML::list_bddimages {

      # id, name
      set i [lindex $conf 0]
      set n [lindex $conf 1]

      # Cree l'element /config/bddimages
      set node [::dom::document createElement $root "bddimages"]
      ::dom::element setAttribute $node "id" $::bddimagesXML::xmlConfig($i,id)
      if {$::bddimagesXML::xmlConfig($i,name) == $::bddimagesXML::default_config} {
         ::dom::element setAttribute $node "default" "yes"
      }
      
      # --- /config/bddimages/name
      set subnode [::dom::document createElement $node "name"]
      if {[info exists ::bddimagesXML::xmlConfig($i,name)]} {
         ::dom::document createTextNode $subnode $::bddimagesXML::xmlConfig($i,name)
      }

      # --- /config/bddimages/sql
      set subnode [::dom::document createElement $node "sql"]
        # --- /config/bddimages/sql/dbname
        set subsubnode [::dom::document createElement $subnode "dbname"]
        if {[info exists ::bddimagesXML::xmlConfig($i,dbname)]} {
           ::dom::document createTextNode $subsubnode $::bddimagesXML::xmlConfig($i,dbname)
        }
        # --- /config/bddimages/sql/login
        set subsubnode [::dom::document createElement $subnode "login"]
        if {[info exists ::bddimagesXML::xmlConfig($i,login)]} {
           ::dom::document createTextNode $subsubnode $::bddimagesXML::xmlConfig($i,login)
        }
        # --- /config/bddimages/sql/pass
        set subsubnode [::dom::document createElement $subnode "pass"]
        if {[info exists ::bddimagesXML::xmlConfig($i,pass)]} {
           ::dom::document createTextNode $subsubnode $::bddimagesXML::xmlConfig($i,pass)
        }
        # --- /config/bddimages/sql/ip
        set subsubnode [::dom::document createElement $subnode "server"]
        if {[info exists ::bddimagesXML::xmlConfig($i,server)]} {
           ::dom::document createTextNode $subsubnode $::bddimagesXML::xmlConfig($i,server)
        }
        # --- /config/bddimages/sql/port
        set subsubnode [::dom::document createElement $subnode "port"]
        if {[info exists ::bddimagesXML::xmlConfig($i,port)]} {
           ::dom::document createTextNode $subsubnode $::bddimagesXML::xmlConfig($i,port)
        }

      # --- /config/bddimages/files
      set subnode [::dom::document createElement $node "files"]
        # --- /config/bddimages/files/root
        set subsubnode [::dom::document createElement $subnode "root"]
        if {[info exists ::bddimagesXML::xmlConfig($i,dirbase)]} {
           ::dom::document createTextNode $subsubnode $::bddimagesXML::xmlConfig($i,dirbase)
        }
        # --- /config/bddimages/files/incoming
        set subsubnode [::dom::document createElement $subnode "incoming"]
        if {[info exists ::bddimagesXML::xmlConfig($i,dirbase)]} {
           ::dom::document createTextNode $subsubnode $::bddimagesXML::xmlConfig($i,dirinco)
        }
        # --- /config/bddimages/files/fits
        set subsubnode [::dom::document createElement $subnode "fits"]
        if {[info exists ::bddimagesXML::xmlConfig($i,dirbase)]} {
           ::dom::document createTextNode $subsubnode $::bddimagesXML::xmlConfig($i,dirfits)
        }
        # --- /config/bddimages/files/cata
        set subsubnode [::dom::document createElement $subnode "cata"]
        if {[info exists ::bddimagesXML::xmlConfig($i,dirbase)]} {
           ::dom::document createTextNode $subsubnode $::bddimagesXML::xmlConfig($i,dircata)
        }
        # --- /config/bddimages/files/error
        set subsubnode [::dom::document createElement $subnode "error"]
        if {[info exists ::bddimagesXML::xmlConfig($i,dirbase)]} {
           ::dom::document createTextNode $subsubnode $::bddimagesXML::xmlConfig($i,direrr)
        }
        # --- /config/bddimages/files/log
        set subsubnode [::dom::document createElement $subnode "log"]
        if {[info exists ::bddimagesXML::xmlConfig($i,dirbase)]} {
           ::dom::document createTextNode $subsubnode $::bddimagesXML::xmlConfig($i,dirlog)
        }
        # --- /config/bddimages/files/tmp
        set subsubnode [::dom::document createElement $subnode "tmp"]
        if {[info exists ::bddimagesXML::xmlConfig($i,dirbase)]} {
           ::dom::document createTextNode $subsubnode $::bddimagesXML::xmlConfig($i,dirtmp)
        }
  
      # --- /config/bddimages/screenlimit
      set subnode [::dom::document createElement $node "screenlimit"]
      if {[info exists ::bddimagesXML::xmlConfig($i,limit)]} {
         ::dom::document createTextNode $subnode $::bddimagesXML::xmlConfig($i,limit)
      }
   }
   
   # Sauve le fichier XML de config
   set fxml [open $file_config "w"]
   puts $fxml [::dom::DOMImplementation serialize $docxml -indent true]
   close $fxml

   return 0
}   

#--------------------------------------------------
#  ::bddimagesXML::set_config { name }
#--------------------------------------------------
# Defini la config a partir de son nom 
# @param name nom de la config a charger
# @return void
#--------------------------------------------------
proc ::bddimagesXML::set_config { name } {

   global bddconf

   # Defini l'id de la config
   set id [::bddimagesXML::get_id_from_name $name]
   
   # Defini les parametres de la config demandee
   set err [catch {set ::bddimagesXML::xmlConfig($id,name)    $bddconf(name)    }]
   set err [catch {set ::bddimagesXML::xmlConfig($id,dbname)  $bddconf(dbname)  }]
   set err [catch {set ::bddimagesXML::xmlConfig($id,login)   $bddconf(login)   }]
   set err [catch {set ::bddimagesXML::xmlConfig($id,pass)    $bddconf(pass)    }]
   set err [catch {set ::bddimagesXML::xmlConfig($id,server)  $bddconf(server)  }]
   set err [catch {set ::bddimagesXML::xmlConfig($id,port)    $bddconf(port)    }]
   set err [catch {set ::bddimagesXML::xmlConfig($id,dirbase) $bddconf(dirbase) }]
   set err [catch {set ::bddimagesXML::xmlConfig($id,dirinco) $bddconf(dirinco) }]
   set err [catch {set ::bddimagesXML::xmlConfig($id,dirfits) $bddconf(dirfits) }]
   set err [catch {set ::bddimagesXML::xmlConfig($id,dircata) $bddconf(dircata) }]
   set err [catch {set ::bddimagesXML::xmlConfig($id,direrr)  $bddconf(direrr)  }]
   set err [catch {set ::bddimagesXML::xmlConfig($id,dirlog)  $bddconf(dirlog)  }]
   set err [catch {set ::bddimagesXML::xmlConfig($id,dirtmp)  $bddconf(dirtmp)  }]
   set err [catch {set ::bddimagesXML::xmlConfig($id,limit)   $bddconf(limit)   }]
   return 0
}
