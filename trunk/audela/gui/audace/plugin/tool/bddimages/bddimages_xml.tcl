#
# Fichier : bddimages_xml.tcl
# Description : Manipulation des fichiers de config XML de bddimages
#
# Auteur : J. Berthier & F. Vachier
# Mise à jour $Id: bddimages_xml.tcl,v 1.1 2011-01-23 01:20:51 jberthier Exp $
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
#
proc ::bddimagesXML::read_xml_config { file_config } {
   
   # Structure contenant la config
   array set ::bddimagesXML::xmlConfig {}
   # Structure contenant la liste des bdd
   set ::bddimagesXML::list_bddimages {}
   # Nom de la config par defaut
   set ::bddimagesXML::default_config ""

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

      if { [catch {::dom::node stringValue [::dom::selectNode $node {attribute::id}]} current_id] == 0 } { 
         set idx [expr $idx + 1]
         set ::bddimagesXML::xmlConfig($idx,id) $current_id
         set ::bddimagesXML::xmlConfig(nb_id) $idx
      }
      if { [catch {::dom::node stringValue [::dom::selectNode $node {attribute::default}]} default] == 0 } { 
         set ::bddimagesXML::xmlConfig($idx,default) $default
         set ::bddimagesXML::xmlConfig(default_id) $idx
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
      if { [catch {::dom::node stringValue [::dom::selectNode $node {descendant::serv/text()}]} val] == 0 } { 
         set ::bddimagesXML::xmlConfig($idx,serv) $val
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
   for { set i 1 } { $i <= $::bddimagesXML::xmlConfig(nb_id) } { incr i } {
      lappend ::bddimagesXML::list_bddimages [list $::bddimagesXML::xmlConfig($i,id) $::bddimagesXML::xmlConfig($i,name)]
   }

   # Charge la config par defaut et defini le nom de la bdd par defaut
   set ::bddimagesXML::default_config [::bddimagesXML::get_config $::bddimagesXML::xmlConfig($::bddimagesXML::xmlConfig(default_id),name)]
   
   return 0
}

#--------------------------------------------------
#  ::bddimagesXML::get_config { }
#--------------------------------------------------
# Selectionne la configuration d'index = id 
# @param id numero d'id de la config a charger
# @return le nom de la config chargee
#--------------------------------------------------
proc ::bddimagesXML::get_config { name } {

   global bddconf

   # Cherche l'id de la config demandee
   set id 0
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
   set err [catch {set bddconf(serv)    $::bddimagesXML::xmlConfig($id,serv)    }]
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
# @return le nom de la config chargee
#--------------------------------------------------
proc ::bddimagesXML::add_config { } {
   
   # Recherche la valeur max de l'id (xmlConfig($i,id))
   set max_id 0
   for { set i 1 } { $i <= $::bddimagesXML::xmlConfig(nb_id) } { incr i } {
       if {$::bddimagesXML::xmlConfig($i,id) > $max_id} {
          set max_id $::bddimagesXML::xmlConfig($i,id)
       }
   }
   # Incremente le nombre de config
   set ::bddimagesXML::xmlConfig(nb_id) [expr $::bddimagesXML::xmlConfig(nb_id) + 1]
   # Increment le nombre max de config pour donner un id a la nouvelle config
   set new_id [expr $max_id + 1]
   set new_name "new$new_id"

   # Defini le template de la nouvelle config
   set ::bddimagesXML::xmlConfig($new_id,id)      $new_id 
   set ::bddimagesXML::xmlConfig($new_id,default) "no"
   set ::bddimagesXML::xmlConfig($new_id,name)    $new_name
   set ::bddimagesXML::xmlConfig($new_id,dbname)  "?"  
   set ::bddimagesXML::xmlConfig($new_id,login)   "?"  
   set ::bddimagesXML::xmlConfig($new_id,pass)    ""   
   set ::bddimagesXML::xmlConfig($new_id,serv)    ""   
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
# @return void
#--------------------------------------------------
proc ::bddimagesXML::delete_config { } {

   global bddconf
   
   set ::bddimagesXML::xmlConfig(nb_id) [expr $::bddimagesXML::xmlConfig(nb_id) - 1]

   return
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
   return -code $err

}

#--------------------------------------------------
#  ::bddimagesXML::write_xml_config { file_config }
#--------------------------------------------------
# Ecriture de la config XML de bddimages
# @param file_config nom du fichier de config XML
# @return -code err
#--------------------------------------------------
proc ::bddimagesXML::write_xml_config { file_config  } {

   package require tdom
   global bddconf
   global current_config

   #      <config version="1.0" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance">
   set docxml [dom createDocument config]
   set xmlroot [$docxml documentElement]
   $xmlroot setAttribute version 1.0
   $xmlroot setAttribute xmlns:xsi "http://www.w3.org/2001/XMLSchema-instance"

   # --- element document
   set subnode [$docxml createElement document]
   $xmlroot appendChild $subnode
      # --- element version
      set node [$docxml createElement version]
      $node appendChild [$docxml createTextNode 0.1]
      $subnode appendChild $node
      # --- element date
      set node [$docxml createElement date]
      $node appendChild [$docxml createTextNode xx/xx/xx]
      $subnode appendChild $node
      # --- element ticket
      set node [$docxml createElement ticket]
      $node appendChild [$docxml createTextNode 1]
      $subnode appendChild $node
      # --- element author
      set node [$docxml createElement author]
      $node appendChild [$docxml createTextNode "F. Vachier et J. Berthier"]
      $subnode appendChild $node

   # --- element bddimages
   set subnode [$docxml createElement bddimages]
   $subnode setAttribute id 1
   $subnode setAttribute default yes
   $xmlroot appendChild $subnode
      # --- element name
      set node [$docxml createElement name]
      $node appendChild [$docxml createTextNode bddimagesDEMO]
      $subnode appendChild $node

   set fxml [open "/tmp/toto.xml" "w"]
   puts $fxml [$xmlroot asXML]
   close $fxml

   
   #      <config version="1.0" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance">
   #      
   #        <document>
   #          <version>0.1</version>
   #          <date>2011-01-21T19:00:00</date>
   #          <ticket>1</ticket>
   #          <author>F.Vachier</author>
   #        </document>
   #      
   #        <bddimages id="1" default="yes">
   #           <name>bddimages</name>
   #           <sql>
   #              <dbname>bddimages</dbname>
   #              <login>bddimagesAdmin</login>
   #              <pass>1bddimages0</pass>
   #              <ip>localhost</ip>
   #              <port>3306</port>
   #           </sql>
   #           <files>
   #             <root></root>
   #             <incoming></incoming>
   #             <fits></fits>
   #             <cata></cata>
   #             <error></error>
   #             <log></log>
   #           </files>
   #           <screenlimit>10</screenlimit>
   #        </bddimages>
   #      
   #      </config>
   
}   

