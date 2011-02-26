#
# Fichier : ros_xml.tcl
# Description : Manipulation des fichiers de config XML de ros
#
# Auteur : J. Berthier & F. Vachier
# Mise à jour $Id$
#

namespace eval ::rosXML {
   package provide rosXML 1.0
   global audace

   # Compatibilite ascendante
   if { [ package require dom ] == "2.6" } {
      interp alias {} ::dom::parse {} ::dom::tcl::parse
      interp alias {} ::dom::selectNode {} ::dom::tcl::selectNode
      interp alias {} ::dom::node {} ::dom::tcl::node
   }
   
   # Lecture des captions
   source [ file join [file dirname [info script]] ros_xml.cap ]

   # Structure contenant les config xml
   variable xmlConfig
   # Defini le nom du fichier de config XML
   variable xmlConfigFile [file join $audace(rep_home) ros_ini.xml]
   # Defini le fichier par defaut de config XML
   variable xmlDefaultConfigFile [file join $audace(rep_plugin) tool ros config ros_ini.xml]

   # Liste des ros lues dans la config : xmlConfig(i,name)
   variable list_ros
   # Nom de la config par defaut
   variable default_config
   # Nom de la config courante
   variable current_config

   # Variable de definition du schema XML de config ros
   variable xml_config_docroot "config"
   variable xml_config_version "1.0"
   variable xml_nsxsi "http://www.w3.org/2001/XMLSchema-instance"

   #--------------------------------------------------
   # ::rosXML::get_default_dir { base dir }
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
   # ::rosXML::get_id_from_name { name }
   #--------------------------------------------------
   # Methode privee fournissant l'id d'une config a partir de son nom
   # Renvoie id=1 si la config demandee n'est pas trouvee
   # @param name nom de la config
   # @return id de la config correspondante
   #--------------------------------------------------
   proc get_id_from_name { name } {
      set id 1
      foreach l $::rosXML::list_ros {
         if {[lindex $l 1] == $name} {
            set id [lindex $l 0]
         }
      }
      return $id
   }

   #--------------------------------------------------
   # ::rosXML::get_name_from_id { id }
   #--------------------------------------------------
   # Methode privee fournissant le nom d'une config a partir de son id
   # Renvoie name="?" si la config demandee n'est pas trouvee
   # @param id id de la config
   # @return nom de la config correspondante
   #--------------------------------------------------
   proc get_name_from_id { id } {
      set name ""
      foreach l $::rosXML::list_ros {
         if {[lindex $l 0] == $id} {
            set name [lindex $l 1]
         }
      }
      return $name
   }

   #--------------------------------------------------
   # ::rosXML::get_last_id_config { }
   #--------------------------------------------------
   # Methode privee fournissant l'id le plus grand
   # Renvoie id=1 si la config demandee n'est pas trouvee
   # @return id le plus grand
   #--------------------------------------------------
   proc get_last_id_config { } {
      set id 1
      foreach l $::rosXML::list_ros {
         if {[lindex $l 0] >= $id} {
            set id [lindex $l 0]
         }
      }
      return $id
   }

}

#--------------------------------------------------
#  ::rosXML::load_xml_config { }
#--------------------------------------------------
# Chargement de la config XML de ros
# @return -code err
#--------------------------------------------------
proc ::rosXML::load_xml_config {  } {

   # Verifie que le fichier xml existe, et s'il n'existe pas
   # on le cree a partir du fichier par defaut config/ros_ini.xml
   if {[file exists $::rosXML::xmlConfigFile] == 0} {
      ::console::affiche_resultat "$::caption(ros_xml,defaultxml)"
      set errnum [catch {file copy $::rosXML::xmlDefaultConfigFile $::rosXML::xmlConfigFile} msg ]
   }

   # Charge la config xml
   set err [::rosXML::read_xml_config $::rosXML::xmlConfigFile]
   return -code $err ""

}

#--------------------------------------------------
# ::rosXML::read_xml_config { file_config }
#--------------------------------------------------
# Lecture de la config XML
# @param file_config nom du fichier de config XML
# @return 0
#--------------------------------------------------
proc ::rosXML::read_xml_config { file_config } {

   # Force la mise a null, car array set arrayName list ne le fait
   # que si la variable n'existe pas
   array unset ::rosXML::xmlConfig
   array unset ::rosXML::list_ros

   # Structure contenant la config: force la mise a null
   array set ::rosXML::xmlConfig {}
   # Par defaut on considere la config id=1
   set ::rosXML::xmlConfigDef(default_id) 1
   # Par defaut il n'y a aucune config
   set ::rosXML::xmlConfigDef(nb_id) 0
   # Structure contenant la liste des config sous la forme {id name}
   set ::rosXML::list_ros {}
   # Nom de la config par defaut
   set ::rosXML::default_config ""
   # Nom de la config courante
   set ::rosXML::current_config ""
   
   # Lecture du fichier
   set xmldoc ""
   set f [open $file_config r]
   while {![eof $f]} {
      append xmldoc [gets $f]
   }
   close $f

   # Analyse du doc XML pour charger la config dans xmlConfig
   set xml [::dom::parse $xmldoc]
   foreach node [::dom::selectNode $xml {descendant::ros}] {

      if { [catch {::dom::node stringValue [::dom::selectNode $node {attribute::id}]} val] == 0 } {
         # id de la config
         set id $val
         set ::rosXML::xmlConfig($id,id) $id
         # compteur de config
         set ::rosXML::xmlConfigDef(nb_id) [expr $::rosXML::xmlConfigDef(nb_id) + 1]
      }
      if { [catch {::dom::node stringValue [::dom::selectNode $node {attribute::default}]} val] == 0 } { 
         set ::rosXML::xmlConfig($id,default) $val
         set ::rosXML::xmlConfigDef(default_id) $id
      } else {
         set ::rosXML::xmlConfig($id,default) "no"
      }
      if { [catch {::dom::node stringValue [::dom::selectNode $node {descendant::name/text()}]} val] == 0 } { 
         set ::rosXML::xmlConfig($id,name) $val
      }
      if { [catch {::dom::node stringValue [::dom::selectNode $node {descendant::dbname/text()}]} val] == 0 } { 
         set ::rosXML::xmlConfig($id,dbname) $val
      }
      if { [catch {::dom::node stringValue [::dom::selectNode $node {descendant::login/text()}]} val] == 0 } { 
         set ::rosXML::xmlConfig($id,login) $val
      }
      if { [catch {::dom::node stringValue [::dom::selectNode $node {descendant::pass/text()}]} val] == 0 } { 
         set ::rosXML::xmlConfig($id,pass) $val
      }
      if { [catch {::dom::node stringValue [::dom::selectNode $node {descendant::server/text()}]} val] == 0 } { 
         set ::rosXML::xmlConfig($id,server) $val
      }
      if { [catch {::dom::node stringValue [::dom::selectNode $node {descendant::port/text()}]} val] == 0 } { 
         set ::rosXML::xmlConfig($id,port) $val
      }
      if { [catch {::dom::node stringValue [::dom::selectNode $node {descendant::root/text()}]} val] == 0 } { 
         set ::rosXML::xmlConfig($id,dirbase) [::rosXML::get_default_dir $val ""]
      }
      if { [catch {::dom::node stringValue [::dom::selectNode $node {descendant::incoming/text()}]} val] == 0 } { 
         set ::rosXML::xmlConfig($id,dirinco) [::rosXML::get_default_dir $val "incoming"]
      }
      if { [catch {::dom::node stringValue [::dom::selectNode $node {descendant::fits/text()}]} val] == 0 } { 
         set ::rosXML::xmlConfig($id,dirfits) [::rosXML::get_default_dir $val "fits"]
      }
      if { [catch {::dom::node stringValue [::dom::selectNode $node {descendant::cata/text()}]} val] == 0 } { 
         set ::rosXML::xmlConfig($id,dircata) [::rosXML::get_default_dir $val "cata"]
      }
      if { [catch {::dom::node stringValue [::dom::selectNode $node {descendant::error/text()}]} val] == 0 } { 
         set ::rosXML::xmlConfig($id,direrr) [::rosXML::get_default_dir $val "error"]
      }
      if { [catch {::dom::node stringValue [::dom::selectNode $node {descendant::log/text()}]} val] == 0 } { 
         set ::rosXML::xmlConfig($id,dirlog) [::rosXML::get_default_dir $val "log"]
      }
      if { [catch {::dom::node stringValue [::dom::selectNode $node {descendant::screenlimit/text()}]} val] == 0 } {
         set ::rosXML::xmlConfig($id,limit) $val
      }

   }

   # Defini la liste des ros disponibles [list id name]
   set prev_k 0
   foreach key [lsort [array names ::rosXML::xmlConfig]] {
      set k [lindex [split $key ","] 0]
      if {$k != $prev_k} {
         lappend ::rosXML::list_ros [list $::rosXML::xmlConfig($k,id) $::rosXML::xmlConfig($k,name)]
         set prev_k $k
      }
   }

   # Charge la config par defaut
   set def_conf $::rosXML::xmlConfig($::rosXML::xmlConfigDef(default_id),name)
   set ::rosXML::default_config [::rosXML::get_config $def_conf]

   # Defini la config courante comme etant celle par defaut
   set ::rosXML::current_config $::rosXML::default_config

   return 0
}

#--------------------------------------------------
#  ::rosXML::get_config { }
#--------------------------------------------------
# Selectionne la configuration d'index = id 
# @param lconf liste contenant l'id et le nom de la config a charger
# @return id et nom de la config chargee (liste)
#--------------------------------------------------
proc ::rosXML::get_config { name } {

   global rosconf

   # Cherche l'id de la config demandee
   set id [::rosXML::get_id_from_name $name]
   
   # Defini les parametres de la config demandee
   set err [catch {set rosconf(name)    $::rosXML::xmlConfig($id,name)    }]
   set err [catch {set rosconf(dbname)  $::rosXML::xmlConfig($id,dbname)  }]
   set err [catch {set rosconf(login)   $::rosXML::xmlConfig($id,login)   }]
   set err [catch {set rosconf(pass)    $::rosXML::xmlConfig($id,pass)    }]
   set err [catch {set rosconf(server)  $::rosXML::xmlConfig($id,server)  }]
   set err [catch {set rosconf(port)    $::rosXML::xmlConfig($id,port)    }]
   set err [catch {set rosconf(dirbase) $::rosXML::xmlConfig($id,dirbase) }]
   set err [catch {set rosconf(dirinco) $::rosXML::xmlConfig($id,dirinco) }]
   set err [catch {set rosconf(dirfits) $::rosXML::xmlConfig($id,dirfits) }]
   set err [catch {set rosconf(dircata) $::rosXML::xmlConfig($id,dircata) }]
   set err [catch {set rosconf(direrr)  $::rosXML::xmlConfig($id,direrr)  }]
   set err [catch {set rosconf(dirlog)  $::rosXML::xmlConfig($id,dirlog)  }]
   set err [catch {set rosconf(limit)   $::rosXML::xmlConfig($id,limit)   }]
   
   # Retourne le nom de la config chargee
   return $rosconf(name)
}

#--------------------------------------------------
#  ::rosXML::add_config { }
#--------------------------------------------------
# Ajoute une config 
# @return nom de la config a charger
#--------------------------------------------------
proc ::rosXML::add_config { } {
   
   # Valeur de l'id existant le plus grand
   set max_id [::rosXML::get_last_id_config]
   # Nouvel id = max + 1
   set new_id [expr $max_id + 1]
   # Defini un template de nom pour la nouvelle config
   set new_name "ros$new_id"

   # Incremente le nombre de config
   set ::rosXML::xmlConfigDef(nb_id) [expr $::rosXML::xmlConfigDef(nb_id) + 1]
   # Defini le template de la nouvelle config
   set ::rosXML::xmlConfig($new_id,id)      $new_id 
   set ::rosXML::xmlConfig($new_id,default) "no"
   set ::rosXML::xmlConfig($new_id,name)    $new_name
   set ::rosXML::xmlConfig($new_id,dbname)  $new_name
   set ::rosXML::xmlConfig($new_id,login)   "?"  
   set ::rosXML::xmlConfig($new_id,pass)    ""   
   set ::rosXML::xmlConfig($new_id,server)  ""   
   set ::rosXML::xmlConfig($new_id,port)    ""   
   set ::rosXML::xmlConfig($new_id,dirbase) "?"  
   set ::rosXML::xmlConfig($new_id,dirinco) "?"  
   set ::rosXML::xmlConfig($new_id,dirfits) "?"  
   set ::rosXML::xmlConfig($new_id,dircata) "?"  
   set ::rosXML::xmlConfig($new_id,direrr)  "?"  
   set ::rosXML::xmlConfig($new_id,dirlog)  "?"  
   set ::rosXML::xmlConfig($new_id,limit)   "10" 

   # Met a jour la liste des config
   set new_config [list $new_id $new_name]
   lappend ::rosXML::list_ros $new_config

   # Retourne le nom de la nouvelle config
   return $new_name
}

#--------------------------------------------------
# ::rosXML::delete_config { name }
#--------------------------------------------------
# Efface la config de nom name 
# @param name nom de la config a effacer
# @return nom de la config a charger
#--------------------------------------------------
proc ::rosXML::delete_config { name } {
   
   # S'il ne reste qu'une config alors impossible de l'effacer
   if {$::rosXML::xmlConfigDef(nb_id) == 1} {
      return -code 1
   }

   # Cherche l'id de la config demandee
   set id [::rosXML::get_id_from_name $name]

   # Creation d'une nouvelle structure des config
   array set new_xmlConfig {}
   # Recopie toutes les config sauf celle a effacer
   foreach key [lsort [array names ::rosXML::xmlConfig]] {
      set k [split $key ","]
      if {[lindex $k 0] != $id} {
         set err [catch {set new_xmlConfig($key) $::rosXML::xmlConfig($key)}]
      }
   }
   # Mise a jour de la structure des config
   array unset ::rosXML::xmlConfig
   array set ::rosXML::xmlConfig [array get new_xmlConfig]
   
   # Decremente le nombre de config
   set ::rosXML::xmlConfigDef(nb_id) [expr $::rosXML::xmlConfigDef(nb_id) - 1]

   # Re-initialise la liste des config
   set ::rosXML::list_ros {}
   # Defini la liste des ros disponibles [list id name]
   set prev_k 0
   foreach key [lsort [array names ::rosXML::xmlConfig]] {
      set k [lindex [split $key ","] 0]
      if {$k != $prev_k} {
         lappend ::rosXML::list_ros [list $::rosXML::xmlConfig($k,id) $::rosXML::xmlConfig($k,name)]
         set prev_k $k
      }
   }

# DEBUG
#puts "-- WRITE ------------------------------------------"
#foreach k [lsort [array names ::rosXML::xmlConfig]] {
#   puts "xmlConfig: $k --> $::rosXML::xmlConfig($k)"
#}
   
   # Defini la config chargee comme etant la derniere de la liste
   set last_id [::rosXML::get_last_id_config]
   # Recupere le nom de cette config
   set new_name [::rosXML::get_name_from_id $last_id]
   
   # Retourne le nom de la config chargee
   return $new_name
}


#--------------------------------------------------
#  ::rosXML::save_xml_config { }
#--------------------------------------------------
# Sauvegarde la config XML de ros
# @return -code err
#--------------------------------------------------
proc ::rosXML::save_xml_config {  } {

   # Enregistre la config xml
   if {[catch {::rosXML::write_xml_config $::rosXML::xmlConfigFile} bck] != 0} {
      ::console::affiche_erreur "$::caption(ros_xml,errorxml)\n"
      return -code 1
   } else {
      ::console::affiche_resultat "$::caption(ros_xml,successxml)\n"
      return -code 0
   }

}

#--------------------------------------------------
#  ::rosXML::write_xml_config { file_config }
#--------------------------------------------------
# Ecriture de la config XML de ros
# @param file_config nom du fichier de config XML
# @return 0
#--------------------------------------------------
proc ::rosXML::write_xml_config { file_config  } {

# DEBUG
#puts "-- WRITE ------------------------------------------"
#foreach k [lsort [array names ::rosXML::xmlConfig]] {
#   puts "xmlConfig: $k --> $::rosXML::xmlConfig($k)"
#}

   # Verifie que 2 config ne portent pas le meme nom
#   if {[catch {} ok] != 0} {
#      
#   }
   
   # Cree le doc xml
   set docxml [::dom::DOMImplementation create]

   # Cree la racine du document /config
   set root [::dom::document createElement $docxml $::rosXML::xml_config_docroot]
   ::dom::element setAttribute $root "version" $::rosXML::xml_config_version
   ::dom::element setAttribute $root "xmlns:xsi" $::rosXML::xml_nsxsi

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

   # Cree les elements /config/ros
   foreach conf $::rosXML::list_ros {

      # id, name
      set i [lindex $conf 0]
      set n [lindex $conf 1]

      # Cree l'element /config/ros
      set node [::dom::document createElement $root "ros"]
      ::dom::element setAttribute $node "id" $::rosXML::xmlConfig($i,id)
      if {$::rosXML::xmlConfig($i,name) == $::rosXML::default_config} {
         ::dom::element setAttribute $node "default" "yes"
      }
      
      # --- /config/ros/name
      set subnode [::dom::document createElement $node "name"]
      if {[info exists ::rosXML::xmlConfig($i,name)]} {
         ::dom::document createTextNode $subnode $::rosXML::xmlConfig($i,name)
      }

      # --- /config/ros/sql
      set subnode [::dom::document createElement $node "sql"]
        # --- /config/ros/sql/dbname
        set subsubnode [::dom::document createElement $subnode "dbname"]
        if {[info exists ::rosXML::xmlConfig($i,dbname)]} {
           ::dom::document createTextNode $subsubnode $::rosXML::xmlConfig($i,dbname)
        }
        # --- /config/ros/sql/login
        set subsubnode [::dom::document createElement $subnode "login"]
        if {[info exists ::rosXML::xmlConfig($i,login)]} {
           ::dom::document createTextNode $subsubnode $::rosXML::xmlConfig($i,login)
        }
        # --- /config/ros/sql/pass
        set subsubnode [::dom::document createElement $subnode "pass"]
        if {[info exists ::rosXML::xmlConfig($i,pass)]} {
           ::dom::document createTextNode $subsubnode $::rosXML::xmlConfig($i,pass)
        }
        # --- /config/ros/sql/ip
        set subsubnode [::dom::document createElement $subnode "server"]
        if {[info exists ::rosXML::xmlConfig($i,server)]} {
           ::dom::document createTextNode $subsubnode $::rosXML::xmlConfig($i,server)
        }
        # --- /config/ros/sql/port
        set subsubnode [::dom::document createElement $subnode "port"]
        if {[info exists ::rosXML::xmlConfig($i,port)]} {
           ::dom::document createTextNode $subsubnode $::rosXML::xmlConfig($i,port)
        }

      # --- /config/ros/files
      set subnode [::dom::document createElement $node "files"]
        # --- /config/ros/files/root
        set subsubnode [::dom::document createElement $subnode "root"]
        if {[info exists ::rosXML::xmlConfig($i,dirbase)]} {
           ::dom::document createTextNode $subsubnode $::rosXML::xmlConfig($i,dirbase)
        }
        # --- /config/ros/files/incoming
        set subsubnode [::dom::document createElement $subnode "incoming"]
        if {[info exists ::rosXML::xmlConfig($i,dirbase)]} {
           ::dom::document createTextNode $subsubnode $::rosXML::xmlConfig($i,dirinco)
        }
        # --- /config/ros/files/fits
        set subsubnode [::dom::document createElement $subnode "fits"]
        if {[info exists ::rosXML::xmlConfig($i,dirbase)]} {
           ::dom::document createTextNode $subsubnode $::rosXML::xmlConfig($i,dirfits)
        }
        # --- /config/ros/files/cata
        set subsubnode [::dom::document createElement $subnode "cata"]
        if {[info exists ::rosXML::xmlConfig($i,dirbase)]} {
           ::dom::document createTextNode $subsubnode $::rosXML::xmlConfig($i,dircata)
        }
        # --- /config/ros/files/error
        set subsubnode [::dom::document createElement $subnode "error"]
        if {[info exists ::rosXML::xmlConfig($i,dirbase)]} {
           ::dom::document createTextNode $subsubnode $::rosXML::xmlConfig($i,direrr)
        }
        # --- /config/ros/files/log
        set subsubnode [::dom::document createElement $subnode "log"]
        if {[info exists ::rosXML::xmlConfig($i,dirbase)]} {
           ::dom::document createTextNode $subsubnode $::rosXML::xmlConfig($i,dirlog)
        }
  
      # --- /config/ros/screenlimit
      set subnode [::dom::document createElement $node "screenlimit"]
      if {[info exists ::rosXML::xmlConfig($i,limit)]} {
         ::dom::document createTextNode $subnode $::rosXML::xmlConfig($i,limit)
      }
   }
   
   # Sauve le fichier XML de config
   set fxml [open $file_config "w"]
   puts $fxml [::dom::DOMImplementation serialize $docxml -indent true]
   close $fxml

   return 0
}   

#--------------------------------------------------
#  ::rosXML::set_config { name }
#--------------------------------------------------
# Defini la config a partir de son nom 
# @param name nom de la config a charger
# @return void
#--------------------------------------------------
proc ::rosXML::set_config { name } {

   global rosconf

   # Defini l'id de la config
   set id [::rosXML::get_id_from_name $name]
   
   # Defini les parametres de la config demandee
   set err [catch {set ::rosXML::xmlConfig($id,name)    $rosconf(name)    }]
   set err [catch {set ::rosXML::xmlConfig($id,dbname)  $rosconf(dbname)  }]
   set err [catch {set ::rosXML::xmlConfig($id,login)   $rosconf(login)   }]
   set err [catch {set ::rosXML::xmlConfig($id,pass)    $rosconf(pass)    }]
   set err [catch {set ::rosXML::xmlConfig($id,server)  $rosconf(server)  }]
   set err [catch {set ::rosXML::xmlConfig($id,port)    $rosconf(port)    }]
   set err [catch {set ::rosXML::xmlConfig($id,dirbase) $rosconf(dirbase) }]
   set err [catch {set ::rosXML::xmlConfig($id,dirinco) $rosconf(dirinco) }]
   set err [catch {set ::rosXML::xmlConfig($id,dirfits) $rosconf(dirfits) }]
   set err [catch {set ::rosXML::xmlConfig($id,dircata) $rosconf(dircata) }]
   set err [catch {set ::rosXML::xmlConfig($id,direrr)  $rosconf(direrr)  }]
   set err [catch {set ::rosXML::xmlConfig($id,dirlog)  $rosconf(dirlog)  }]
   set err [catch {set ::rosXML::xmlConfig($id,limit)   $rosconf(limit)   }]
   return 0
}
