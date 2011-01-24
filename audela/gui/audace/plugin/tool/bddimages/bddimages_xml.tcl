#
# Fichier : bddimages_xml.tcl
# Description : Manipulation des fichiers de config XML de bddimages
#
# Auteur : J. Berthier & F. Vachier
# Mise à jour $Id: bddimages_xml.tcl,v 1.2 2011-01-24 00:35:08 jberthier Exp $
#

namespace eval ::bddimagesXML {
   package provide bddimagesXML 1.0
   global audace
   global bddconf

   # Compatibilite ascendante
   if { [ package require dom ] == "2.6" } {
      interp alias {} ::dom::parse {} ::dom::tcl::parse
      interp alias {} ::dom::selectNode {} ::dom::tcl::selectNode
      interp alias {} ::dom::node {} ::dom::tcl::node
   }
   
   # Lecture des captions
   source [ file join [file dirname [info script]] bddimages_xml.cap ]

   # Structure contenant la config xml
   variable xmlConfig
   # Defini le nom du fichier de config XML
   variable xmlConfigFile [ file join $audace(rep_home) bddimages_ini.xml ]
   # Defini le fichier par defaut de config XML
   variable xmlDefaultConfigFile [ file join $audace(rep_plugin) tool bddimages config bddimages_ini.xml]

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
   #  get_default_dir { base dir }
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
   
   # Structure contenant la config
   array set ::bddimagesXML::xmlConfig {}
   # Structure contenant la liste des bdd
   set ::bddimagesXML::list_bddimages {}
   # Initialise le nom de la config par defaut
   set ::bddimagesXML::default_config ""
   # Par defaut c'est la config id=1
   set ::bddimagesXML::xmlConfigDef(default_id) 1
   # Initialise le nom de la config courante
   set ::bddimagesXML::current_config ""
   
   # Lecture du fichier
   set xmldoc ""
   set f [open $file_config r]
   while {![eof $f]} {
      append xmldoc [gets $f]
   }
   close $f

   # Parse le doc XML pour charger la config par defaut dans bddconf
   set idx 0
   set xml [::dom::parse $xmldoc]
   foreach node [::dom::selectNode $xml {descendant::bddimages}] {

      if { [catch {::dom::node stringValue [::dom::selectNode $node {attribute::id}]} val] == 0 } { 
         set idx [expr $idx + 1]
         set ::bddimagesXML::xmlConfig($idx,id) $val
         set ::bddimagesXML::xmlConfigDef(nb_id) $idx
      }
      if { [catch {::dom::node stringValue [::dom::selectNode $node {attribute::default}]} val] == 0 } { 
         set ::bddimagesXML::xmlConfig($idx,default) $val
         set ::bddimagesXML::xmlConfigDef(default_id) $idx
      } else {
         set ::bddimagesXML::xmlConfig($idx,default) "no"
      }
      if { [catch {::dom::node stringValue [::dom::selectNode $node {descendant::name/text()}]} val] == 0 } { 
         set ::bddimagesXML::xmlConfig($idx,name) $val
      }
      if { [catch {::dom::node stringValue [::dom::selectNode $node {descendant::dbname/text()}]} val] == 0 } { 
         set ::bddimagesXML::xmlConfig($idx,dbname) $val
      }
      if { [catch {::dom::node stringValue [::dom::selectNode $node {descendant::login/text()}]} val] == 0 } { 
         set ::bddimagesXML::xmlConfig($idx,login) $val
      }
      if { [catch {::dom::node stringValue [::dom::selectNode $node {descendant::pass/text()}]} val] == 0 } { 
         set ::bddimagesXML::xmlConfig($idx,pass) $val
      }
      if { [catch {::dom::node stringValue [::dom::selectNode $node {descendant::server/text()}]} val] == 0 } { 
         set ::bddimagesXML::xmlConfig($idx,server) $val
      }
      if { [catch {::dom::node stringValue [::dom::selectNode $node {descendant::port/text()}]} val] == 0 } { 
         set ::bddimagesXML::xmlConfig($idx,port) $val
      }
      if { [catch {::dom::node stringValue [::dom::selectNode $node {descendant::root/text()}]} val] == 0 } { 
         set ::bddimagesXML::xmlConfig($idx,dirbase) [::bddimagesXML::get_default_dir $val ""]
      }
      if { [catch {::dom::node stringValue [::dom::selectNode $node {descendant::incoming/text()}]} val] == 0 } { 
         set ::bddimagesXML::xmlConfig($idx,dirinco) [::bddimagesXML::get_default_dir $val "incoming"]
      }
      if { [catch {::dom::node stringValue [::dom::selectNode $node {descendant::fits/text()}]} val] == 0 } { 
         set ::bddimagesXML::xmlConfig($idx,dirfits) [::bddimagesXML::get_default_dir $val "fits"]
      }
      if { [catch {::dom::node stringValue [::dom::selectNode $node {descendant::cata/text()}]} val] == 0 } { 
         set ::bddimagesXML::xmlConfig($idx,dircata) [::bddimagesXML::get_default_dir $val "cata"]
      }
      if { [catch {::dom::node stringValue [::dom::selectNode $node {descendant::error/text()}]} val] == 0 } { 
         set ::bddimagesXML::xmlConfig($idx,direrr) [::bddimagesXML::get_default_dir $val "error"]
      }
      if { [catch {::dom::node stringValue [::dom::selectNode $node {descendant::log/text()}]} val] == 0 } { 
         set ::bddimagesXML::xmlConfig($idx,dirlog) [::bddimagesXML::get_default_dir $val "log"]
      }
      if { [catch {::dom::node stringValue [::dom::selectNode $node {descendant::screenlimit/text()}]} val] == 0 } {
         set ::bddimagesXML::xmlConfig($idx,limit) $val
      }

   }
   
   # Liste des bddimages disponibles
   for { set i 1 } { $i <= $::bddimagesXML::xmlConfigDef(nb_id) } { incr i } {
      lappend ::bddimagesXML::list_bddimages [list $::bddimagesXML::xmlConfig($i,id) $::bddimagesXML::xmlConfig($i,name)]
   }

   # Charge la config par defaut et defini son nom
   set ::bddimagesXML::default_config [::bddimagesXML::get_config $::bddimagesXML::xmlConfig($::bddimagesXML::xmlConfigDef(default_id),name)]
   # et defini la config courante comme etant celle par defaut
   set ::bddimagesXML::current_config $::bddimagesXML::default_config

   return 0
}

#--------------------------------------------------
#  ::bddimagesXML::get_config { }
#--------------------------------------------------
# Selectionne la configuration d'index = id 
# @param id numero d'id de la config a charger
# @return nom de la config chargee
#--------------------------------------------------
proc ::bddimagesXML::get_config { name } {

   global bddconf

   # Cherche l'id de la config demandee
   set id 1
   foreach l $::bddimagesXML::list_bddimages {
      if {[lindex $l 1] == $name} {
         set id [lindex $l 0]
      }
   }
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
   set err [catch {set bddconf(limit)   $::bddimagesXML::xmlConfig($id,limit)   }]
   # Retourne le nom de la bddimages chargee
   return $bddconf(name)
}

#--------------------------------------------------
#  ::bddimagesXML::add_config { }
#--------------------------------------------------
# Ajoute une config 
# @return nom de la config chargee
#--------------------------------------------------
proc ::bddimagesXML::add_config { } {
   
   # Recherche la valeur max de l'id (xmlConfig($i,id))
   set max_id 1
   for { set i 1 } { $i <= $::bddimagesXML::xmlConfigDef(nb_id) } { incr i } {
      set cid [lindex [array get ::bddimagesXML::xmlConfig "$i,id"] 1]
       if {$cid > $max_id} {
          set max_id $::bddimagesXML::xmlConfig($i,id)
       }
   }
   # Incremente le nombre de config
   set ::bddimagesXML::xmlConfigDef(nb_id) [expr $::bddimagesXML::xmlConfigDef(nb_id) + 1]
   # Increment le nombre max de config pour donner un id a la nouvelle config
   set new_id [expr $max_id + 1]
   # Defini un template de nouveau nom
   set new_name "new$new_id"
   # Defini le template de la nouvelle config
   set ::bddimagesXML::xmlConfig($new_id,id)      $new_id 
   set ::bddimagesXML::xmlConfig($new_id,default) "no"
   set ::bddimagesXML::xmlConfig($new_id,name)    $new_name
   set ::bddimagesXML::xmlConfig($new_id,dbname)  "?" 
   set ::bddimagesXML::xmlConfig($new_id,login)   "?"  
   set ::bddimagesXML::xmlConfig($new_id,pass)    ""   
   set ::bddimagesXML::xmlConfig($new_id,server)  ""   
   set ::bddimagesXML::xmlConfig($new_id,port)    ""   
   set ::bddimagesXML::xmlConfig($new_id,dirbase) "?"  
   set ::bddimagesXML::xmlConfig($new_id,dirinco) "?"  
   set ::bddimagesXML::xmlConfig($new_id,dirfits) "?"  
   set ::bddimagesXML::xmlConfig($new_id,dircata) "?"  
   set ::bddimagesXML::xmlConfig($new_id,direrr)  "?"  
   set ::bddimagesXML::xmlConfig($new_id,dirlog)  "?"  
   set ::bddimagesXML::xmlConfig($new_id,limit)   "10" 

   # Met a jour la liste des config
   lappend ::bddimagesXML::list_bddimages [list $::bddimagesXML::xmlConfig($new_id,id) $::bddimagesXML::xmlConfig($new_id,name)]

   # Met a jour la config par defaut
   set new_config [::bddimagesXML::get_config $new_name]
   
   # Retourne le template de nom de la nouvelle config
   return $new_config
}

#--------------------------------------------------
#  ::bddimagesXML::delete_config { }
#--------------------------------------------------
# Efface une config 
# @return nom de la config chargee
#--------------------------------------------------
proc ::bddimagesXML::delete_config { conf } {

   # Nouvelle liste des config
   set new_list_bddimages {}
   # Efface la config selectionnee de la liste des config
   foreach l $::bddimagesXML::list_bddimages {
      if {[lindex $l 1] != $conf} {
         lappend new_list_bddimages $l
      }
   }
   # Mise a jour de la liste des config
   set ::bddimagesXML::list_bddimages $new_list_bddimages

   # Nouvelle structure des config
   array set new_xmlConfig {}
   # Efface la structure de config selectionnee
   for { set i 1 } { $i <= $::bddimagesXML::xmlConfigDef(nb_id) } { incr i } {
       set cname [lindex [array get ::bddimagesXML::xmlConfig "$i,name"] 1]
       if {$cname != $conf} {
          set err [catch {set new_xmlConfig($i,id)      $::bddimagesXML::xmlConfig($i,id)     }]
          set err [catch {set new_xmlConfig($i,default) $::bddimagesXML::xmlConfig($i,default)}]
          set err [catch {set new_xmlConfig($i,name)    $::bddimagesXML::xmlConfig($i,name)   }]
          set err [catch {set new_xmlConfig($i,dbname)  $::bddimagesXML::xmlConfig($i,dbname) }]
          set err [catch {set new_xmlConfig($i,login)   $::bddimagesXML::xmlConfig($i,login)  }]
          set err [catch {set new_xmlConfig($i,pass)    $::bddimagesXML::xmlConfig($i,pass)   }]
          set err [catch {set new_xmlConfig($i,server)  $::bddimagesXML::xmlConfig($i,server) }]
          set err [catch {set new_xmlConfig($i,port)    $::bddimagesXML::xmlConfig($i,port)   }]
          set err [catch {set new_xmlConfig($i,dirbase) $::bddimagesXML::xmlConfig($i,dirbase)}]
          set err [catch {set new_xmlConfig($i,dirinco) $::bddimagesXML::xmlConfig($i,dirinco)}]
          set err [catch {set new_xmlConfig($i,dirfits) $::bddimagesXML::xmlConfig($i,dirfits)}]
          set err [catch {set new_xmlConfig($i,dircata) $::bddimagesXML::xmlConfig($i,dircata)}]
          set err [catch {set new_xmlConfig($i,direrr)  $::bddimagesXML::xmlConfig($i,direrr) }]
          set err [catch {set new_xmlConfig($i,dirlog)  $::bddimagesXML::xmlConfig($i,dirlog) }]
          set err [catch {set new_xmlConfig($i,limit)   $::bddimagesXML::xmlConfig($i,limit)  }]
       }
   }
   # Mise a jour de la structure des config
   array unset ::bddimagesXML::xmlConfig
   array set ::bddimagesXML::xmlConfig [array get new_xmlConfig]
   # Mise a jour du nombre de bdi
   set ::bddimagesXML::xmlConfigDef(nb_id) [expr $::bddimagesXML::xmlConfigDef(nb_id) - 1]

   # DEBUG
#   puts "---------------------------------------------------"
#   foreach k [lsort [array names ::bddimagesXML::xmlConfig]] {
#      puts "xmlConfig: $k --> $::bddimagesXML::xmlConfig($k)"
#   }

   # Defini la config chargee comme etant la premiere
   set ::bddimagesXML::xmlConfigDef(default_id) 1
   set new_name $::bddimagesXML::xmlConfig($::bddimagesXML::xmlConfigDef(default_id),name)
   # Met a jour la config par defaut
   set new_config [::bddimagesXML::get_config $new_name]
   
   # Retourne le nom de la config chargee
   return $new_config
}


#--------------------------------------------------
#  ::bddimagesXML::save_xml_config { }
#--------------------------------------------------
# Sauvegarde la config XML de bddimages
# @return -code err
#--------------------------------------------------
proc ::bddimagesXML::save_xml_config {  } {

   # Enregistre la config xml
   set err [::bddimagesXML::write_xml_config $::bddimagesXML::xmlConfigFile]
   if {$err} {
      ::console::affiche_erreur "$::caption(bddimages_xml,errorxml)\n"
   } else {
      ::console::affiche_resultat "$::caption(bddimages_xml,successxml)\n"
   }
   return -code $err

}

#--------------------------------------------------
#  ::bddimagesXML::write_xml_config { file_config }
#--------------------------------------------------
# Ecriture de la config XML de bddimages
# @param file_config nom du fichier de config XML
# @return 0
#--------------------------------------------------
proc ::bddimagesXML::write_xml_config { file_config  } {

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
    ::dom::document createTextNode $subnode "xx/xx/xx"
    # --- element /config/document/ticket
    set subnode [::dom::document createElement $node "ticket"]
    ::dom::document createTextNode $subnode "1"
    # --- element /config/document/author
    set subnode [::dom::document createElement $node "author"]
    ::dom::document createTextNode $subnode "F. Vachier et J. Berthier"

   # Determine le lien entre index et numero d'id des config a enregistrer
   set idx 0
   set prev 0
   foreach key [lsort [array names ::bddimagesXML::xmlConfig]] {
      set i [lindex [split $key ","] 0]
      if {$i != $prev} {
         set idx [expr $idx + 1]
         set cid($idx) $i
         set prev $i
      }
   }

   # Cree les elements /config/bddimages
   for { set i 1 } { $i <= $::bddimagesXML::xmlConfigDef(nb_id) } { incr i } {
      # Id
      set k $cid($i)

      # Cree l'element /config/bddimages
      set node [::dom::document createElement $root "bddimages"]
      ::dom::element setAttribute $node "id" $i
      if {$::bddimagesXML::xmlConfig($k,name) == $::bddimagesXML::default_config} {
         ::dom::element setAttribute $node "default" "yes"
      }
      
      # --- /config/bddimages/name
      set subnode [::dom::document createElement $node "name"]
      if {[info exists ::bddimagesXML::xmlConfig($k,name)]} {
         ::dom::document createTextNode $subnode $::bddimagesXML::xmlConfig($k,name)
      }

      # --- /config/bddimages/sql
      set subnode [::dom::document createElement $node "sql"]
        # --- /config/bddimages/sql/dbname
        set subsubnode [::dom::document createElement $subnode "dbname"]
        if {[info exists ::bddimagesXML::xmlConfig($k,dbname)]} {
           ::dom::document createTextNode $subsubnode $::bddimagesXML::xmlConfig($k,dbname)
        }
        # --- /config/bddimages/sql/login
        set subsubnode [::dom::document createElement $subnode "login"]
        if {[info exists ::bddimagesXML::xmlConfig($k,login)]} {
           ::dom::document createTextNode $subsubnode $::bddimagesXML::xmlConfig($k,login)
        }
        # --- /config/bddimages/sql/pass
        set subsubnode [::dom::document createElement $subnode "pass"]
        if {[info exists ::bddimagesXML::xmlConfig($k,pass)]} {
           ::dom::document createTextNode $subsubnode $::bddimagesXML::xmlConfig($k,pass)
        }
        # --- /config/bddimages/sql/ip
        set subsubnode [::dom::document createElement $subnode "ip"]
        if {[info exists ::bddimagesXML::xmlConfig($k,server)]} {
           ::dom::document createTextNode $subsubnode $::bddimagesXML::xmlConfig($k,server)
        }
        # --- /config/bddimages/sql/port
        set subsubnode [::dom::document createElement $subnode "port"]
        if {[info exists ::bddimagesXML::xmlConfig($k,port)]} {
           ::dom::document createTextNode $subsubnode $::bddimagesXML::xmlConfig($k,port)
        }

      # --- /config/bddimages/files
      set subnode [::dom::document createElement $node "files"]
        # --- /config/bddimages/files/root
        set subsubnode [::dom::document createElement $subnode "root"]
        if {[info exists ::bddimagesXML::xmlConfig($k,dirbase)]} {
           ::dom::document createTextNode $subsubnode $::bddimagesXML::xmlConfig($k,dirbase)
        }
        # --- /config/bddimages/files/incoming
        set subsubnode [::dom::document createElement $subnode "incoming"]
        if {[info exists ::bddimagesXML::xmlConfig($k,dirbase)]} {
           ::dom::document createTextNode $subsubnode $::bddimagesXML::xmlConfig($k,dirinco)
        }
        # --- /config/bddimages/files/fits
        set subsubnode [::dom::document createElement $subnode "fits"]
        if {[info exists ::bddimagesXML::xmlConfig($k,dirbase)]} {
           ::dom::document createTextNode $subsubnode $::bddimagesXML::xmlConfig($k,dirfits)
        }
        # --- /config/bddimages/files/cata
        set subsubnode [::dom::document createElement $subnode "cata"]
        if {[info exists ::bddimagesXML::xmlConfig($k,dirbase)]} {
           ::dom::document createTextNode $subsubnode $::bddimagesXML::xmlConfig($k,dircata)
        }
        # --- /config/bddimages/files/error
        set subsubnode [::dom::document createElement $subnode "error"]
        if {[info exists ::bddimagesXML::xmlConfig($k,dirbase)]} {
           ::dom::document createTextNode $subsubnode $::bddimagesXML::xmlConfig($k,direrr)
        }
        # --- /config/bddimages/files/log
        set subsubnode [::dom::document createElement $subnode "log"]
        if {[info exists ::bddimagesXML::xmlConfig($k,dirbase)]} {
           ::dom::document createTextNode $subsubnode $::bddimagesXML::xmlConfig($k,dirlog)
        }
  
      # --- /config/bddimages/screenlimit
      set subnode [::dom::document createElement $node "screenlimit"]
      if {[info exists ::bddimagesXML::xmlConfig($k,limit)]} {
         ::dom::document createTextNode $subnode $::bddimagesXML::xmlConfig($k,limit)
      }
   }
   
   # Sauve le fichier XML de config
   set fxml [open $file_config "w"]
   puts $fxml [::dom::DOMImplementation serialize $docxml -indent true]
   close $fxml

   return 0
}   
