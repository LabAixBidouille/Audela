#
# Fichier : ros_xml.tcl
# Description : Manipulation des fichiers de config XML de ros
#
# Auteur : J. Berthier & F. Vachier
# Mise à jour $Id: ros_webservice.tcl,v 1.1 2011-02-19 20:43:49 fredvachier Exp $
#

namespace eval ::ros_webservice {
   package provide ros_webservice 1.0
   global audace

   # Compatibilite ascendante
   if { [ package require dom ] == "2.6" } {
      interp alias {} ::dom::parse {} ::dom::tcl::parse
      interp alias {} ::dom::selectNode {} ::dom::tcl::selectNode
      interp alias {} ::dom::node {} ::dom::tcl::node
   }
   
   # Lecture des captions
   #source [ file join [file dirname [info script]] ros_webservice.cap ]

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

   
   proc ::ros_webservice::dom_mini { monlogin monpassword } {
   
      # --- Cree un objet DOM vide
      catch {unset doc}
      set doc [dom::DOMImplementation create]
      
      # --- Cree une balise <depotcador> fille de l'objet DOM au plus haut niveau
      set xmlroot [dom::document createElement $doc depotcador]
      
      # --- Cree une balise <description> fille vide de l'objet DOM de la balise <depotcador>
      set description [dom::document createElement $xmlroot description]
      # --- On ajoute une value a la balise <description> 
      dom::document createTextNode $description "Information a completer ulterieurement"
      
      # --- Cree une balise <versionmsg> fille vide de l'objet DOM de la balise <depotcador>
      set versionmsg [dom::document createElement $xmlroot versionmsg]
      # --- On ajoute une value a la balise <versionmsg> 
      dom::document createTextNode $versionmsg "0.1"
      
      # --- Cree une balise <login> fille vide de l'objet DOM de la balise <depotcador>
      set login [dom::document createElement $xmlroot login]
      # --- On ajoute une value a la balise <login> 
      dom::document createTextNode $login "$monlogin"
      
      # --- Cree une balise <passwd> fille vide de l'objet DOM de la balise <depotcador>
      set passwd [dom::document createElement $xmlroot passwd]
      
      # --- On ajoute une value a la balise <passwd> 
      dom::document createTextNode $passwd "$monpassword"
      
      return $doc      
   }
   
   #--------------------------------------------------
   # ::ros_webservice::alive_ping {  }
   #--------------------------------------------------
   # Methode publique et verifie que le serveur repond
   # 
   # @return 0 si tout se passe bien
   #--------------------------------------------------
   proc ::ros_webservice::alive_ping { } {
      global audace
      # appel a curl sur cador/ping
      #set url [::xml_config::get_root]/ping
      set url http://cador.obs-hp.fr/ros/manage/rest/cador/ping
      set toeval "exec $audace(rep_install)/bin/curl.exe $url"
      set err [catch {eval $toeval} msg]
      if {($err==0)&&($msg==0)} {
         return "Actif" 
      } else {
         ::console::affiche_erreur "err=$err msg=$msg\n"
         return "Inactif"
      }
   }

   #--------------------------------------------------
   # ::ros_webservice::request_list {  }
   #--------------------------------------------------
   # Methode publique et verifie que le serveur repond
   # 
   # @return 0 si tout se passe bien
   #--------------------------------------------------
   proc ::ros_webservice::request_list { } {
      global audace
      # appel a curl sur cador/ping
      set url http://cador.obs-hp.fr/ros/manage/rest/cador/list
      set doc [::ros_webservice::dom_mini user paswd ]            
      # --- On fabrique le texte du fichier XML
      set xmlstring [dom::DOMImplementation serialize $doc -indent true]
      # --- ecrit le message XML dans un fichier
      set fname identity
      set fullname ${fname}.xml
      set fid [open $fullname w]
      puts -nonewline $fid $xmlstring
      close $fid
      set toeval "exec $audace(rep_install)/bin/curl.exe -F \"file=@${fullname}\" $url"
      set err [catch {eval $toeval} msg]
      set key0 "<?"
      set k0 [string first $key0 $msg]
      set key1 "?>"
      set k1 [string first $key1 $msg]
      set key2 "</depotcador>"
      set k2 [string last $key2 $msg]
      if {($k1>0)&&($k2>=0)} {
         incr k1 [string length $key1]
         incr k2 [string length $key2]
         set xmldoc [string range $msg $k0 $k2]
      }
      # --- Analyse du doc XML
      catch {unset xml}
      set xmldom [::dom::parse $xmldoc]
      set res ""
      foreach requests [::dom::selectNode $xmldom {descendant::requests}] {
         foreach request [::dom::selectNode $requests {descendant::request}] {
            lappend res [::dom::node stringValue [::dom::selectNode $request {descendant::rname/text()}]]
         }      
      }
      return $res
   }

}
