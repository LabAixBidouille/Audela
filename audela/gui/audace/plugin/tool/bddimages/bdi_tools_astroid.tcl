#--------------------------------------------------
# source audace/plugin/tool/bddimages/tools_astroid.tcl
#--------------------------------------------------
#
# Fichier        : tools_astroid.tcl
# Description    : Environnement d analyse de la photometrie et astrometrie  
#                  pour des images qui ont un cata
# Auteur         : Frederic Vachier
# Mise à jour $Id: tools_astroid.tcl 6858 2011-03-06 14:19:15Z fredvachier $
#
namespace eval bdi_tools_astroid {

   variable id

}

   proc ::bdi_tools_astroid::test_astroid { } {
    
      global bddconf
    
      cleanmark
    
      set cataexist [::bddimages_liste::lget $::tools_cata::current_image "cataexist"]
      if {$cataexist==0} {
        set ::tools_cata::current_image [::bddimages_liste_gui::add_info_cata $::tools_cata::current_image]
        set cataexist [::bddimages_liste::lget $::tools_cata::current_image "cataexist"]
      }
      if {$cataexist} {
         set catafilename [::bddimages_liste::lget $::tools_cata::current_image "catafilename"]
         set catadirfilename [::bddimages_liste::lget $::tools_cata::current_image "catadirfilename"]
         set catafile [file join $bddconf(dirbase) $catadirfilename $catafilename] 
         gren_info "cataexist = $cataexist\n"
         gren_info "catafile = $catafile\n"
         set catafile [extract_cata_xml $catafile]
         gren_info "READ catafile = $catafile\n"
         set listsources [get_cata_xml $catafile]
         ::manage_source::imprim_3_sources $listsources
         set listsources [::manage_source::set_common_fields $listsources USNOA2 {ra dec poserr mag magerr }]
         affich_rond $listsources USNOA2 $::tools_cata::color_usnoa2  1
         set listsources [::manage_source::set_common_fields $listsources UCAC2 { ra_deg dec_deg e_pos_deg U2Rmag_mag 0.5 }]
         affich_rond $listsources UCAC2 $::tools_cata::color_ucac2 2
      }
    
   }




# procedure lancee par le maitre qui retourne la liste des id des thread
   proc ::bdi_tools_astroid::get_list_threadId {  } {

      set zlist ""
      foreach threadName [thread::names] {
         lappend zlist $::bdi_tools_astroid::tabthread(name,$threadName)
      }
      return $zlist  
   }

   proc ::bdi_tools_astroid::release_all {  } {

      foreach threadName [thread::names] {
         ::thread::release $threadName
      }

   }

   proc ::bdi_tools_astroid::get_dispo {  } {

      foreach threadName [thread::names] {
         set threadId $::bdi_tools_astroid::tabthread(name,$threadName)
         if {$threadId>0} {
            tsv::get dispo $threadId disp
            #puts "$threadId dispo = $disp"
            if {$disp} {
               return $threadName
            }
         }
      }
      return ""
   }
   proc ::bdi_tools_astroid::get_nb_dispo {  } {

      set cpt 0
      foreach threadName [thread::names] {
         set threadId $::bdi_tools_astroid::tabthread(name,$threadName)
         if {$threadId>0} {
            tsv::get dispo $threadId disp
            if {$disp} {
               incr cpt
            }
         }
      }
      return $cpt
   }

   proc ::bdi_tools_astroid::set_progress { cur max } {
      set ::bdi_tools_astroid::progress [format "%0.0f" [expr $cur * 100. / $max ] ]
      update
   }

# procedure lancee par le maitre pour initialiser l'environnement 
# des variables globales sur les esclaves

   proc ::bdi_tools_astroid::setenv { threadName threadId } {

      # audela
      global audela
      set a [array get audela]
      ::thread::send $threadName [list array set audela $a]

      # Audace
      global audace
      set a [array get audace]
      ::thread::send $threadName [list array set audace $a]

      # Bddconf
      global bddconf
      set a [array get bddconf]
      ::thread::send $threadName [list array set bddconf $a]

      # Bddconf
      global private
      set a [array get private]
      ::thread::send $threadName [list array set private $a]

      # langage
      global langage
      ::thread::send $threadName [list set langage $langage]
      
#      puts "\[$threadId\] SETENV: audace(rep_plugin) = $audace(rep_plugin)"

      ::thread::send $threadName [list uplevel #0 source \"[ file join $audace(rep_gui) audace console.tcl ]\"] msg
#      puts "\[$threadId\] SETENV: audace console.tcl : $msg"

      set sourceFileName [file join $audace(rep_plugin) tool bddimages bddimages_go.tcl ]
      ::thread::send $threadName [list uplevel #0 source \"$sourceFileName\"] msg
#      puts "\[$threadId\] SETENV: source bddimages_go.tcl : $msg"

      ::thread::send $threadName [list package require bddimages] msg
#      puts "\[$threadId\] SETENV: package require bddimages : $msg"

      ::thread::send $threadName [list ::bddimages::ressource] msg
      if {$msg!=""} {puts "\[$threadId\] SETENV: bdi ressource : $msg"}
      
#      thread::send $threadName [list proc gren_info { l } { puts $l}]
#      thread::send $threadName [list proc gren_erreur { l } { puts $l}]

# mode prod
      thread::send $threadName [list proc gren_info { l } { }]
      thread::send $threadName [list proc gren_erreur { l } { }]
   }
 




# procedure lancee par les esclaves pour charger eux memes leur environnement
   proc ::bdi_tools_astroid::set_own_env {  } {

      global audela
      global audace
      global langage
      global threadId
      global threadDispo

      package require math::statistics

      set ::audela_start_dir [file join $audace(rep_install) bin]
      cd $::audela_start_dir
#      puts "\[$threadId\] PWD = [pwd]"

      set audelaLibPath [file join [file join [file dirname [file dirname [info nameofexecutable]] ] lib]]
#      puts "\[$threadId\] SET_OWN_ENV: audelaLibPath = $audelaLibPath"
      if { [lsearch $::auto_path $audelaLibPath] == -1 } {
         lappend ::auto_path $audelaLibPath
      }

      set err [catch {load libgzip[info sharedlibextension]} msg]
      if {$err} { puts "\[$threadId\] SET_OWN_ENV: libgzip = $msg" }

      set err [catch {load libaudela[info sharedlibextension]} msg]
      if {$err} { puts "\[$threadId\] SET_OWN_ENV: libaudela = $msg" }

      set err [catch {load libfitstcl[info sharedlibextension]} msg]
      if {$err} { puts "\[$threadId\] SET_OWN_ENV: libfitstcl = $msg" }

      set err [catch {load libmc[info sharedlibextension]} msg]
      if {$err} { puts "\[$threadId\] SET_OWN_ENV: libmc = $msg" }

      set err [catch {load libgsltcl[info sharedlibextension]} msg]
      if {$err} { puts "\[$threadId\] SET_OWN_ENV: libgsltcl = $msg" }


         
      
      #puts "\[$threadId\] audace(rep_gui) = $audace(rep_gui)"

      set dir [file join $audace(rep_gui) audace]

#      uplevel #0 "source \"[ file join $dir confvisu.tcl            ]\""

      uplevel #0 "source \"[ file join $dir menu.tcl                ]\""

      uplevel #0 "source \"[ file join $dir aud_menu_1.tcl          ]\""
      uplevel #0 "source \"[ file join $dir aud_menu_2.tcl          ]\""
      uplevel #0 "source \"[ file join $dir aud_menu_3.tcl          ]\""
      uplevel #0 "source \"[ file join $dir aud_menu_5.tcl          ]\""
      uplevel #0 "source \"[ file join $dir aud_menu_6.tcl          ]\""
      uplevel #0 "source \"[ file join $dir aud_menu_7.tcl          ]\""
      uplevel #0 "source \"[ file join $dir aud_menu_8.tcl          ]\""
      uplevel #0 "source \"[ file join $dir aud_proc.tcl            ]\""
      uplevel #0 "source \"[ file join $dir console.tcl             ]\""
      uplevel #0 "source \"[ file join $dir confgene.tcl            ]\""
      uplevel #0 "source \"[ file join $dir surchaud.tcl            ]\""
      uplevel #0 "source \"[ file join $dir planetography.tcl       ]\""
      uplevel #0 "source \"[ file join $dir ftp.tcl                 ]\""
      uplevel #0 "source \"[ file join $dir bifsconv.tcl            ]\""
      uplevel #0 "source \"[ file join $dir compute_stellaire.tcl   ]\""
      uplevel #0 "source \"[ file join $dir divers.tcl              ]\""
      uplevel #0 "source \"[ file join $dir iris.tcl                ]\""
      uplevel #0 "source \"[ file join $dir poly.tcl                ]\""
      uplevel #0 "source \"[ file join $dir filtrage.tcl            ]\""
      uplevel #0 "source \"[ file join $dir mauclaire.tcl           ]\""
      uplevel #0 "source \"[ file join $dir help.tcl                ]\""
      uplevel #0 "source \"[ file join $dir vo_tools.tcl            ]\""
      uplevel #0 "source \"[ file join $dir sectiongraph.tcl        ]\""
      uplevel #0 "source \"[ file join $dir polydraw.tcl            ]\""
      uplevel #0 "source \"[ file join $dir ros.tcl                 ]\""
      uplevel #0 "source \"[ file join $dir socket_tools.tcl        ]\""
      uplevel #0 "source \"[ file join $dir gcn_tools.tcl           ]\""
      uplevel #0 "source \"[ file join $dir celestial_mechanics.tcl ]\""
      uplevel #0 "source \"[ file join $dir diaghr.tcl              ]\""
      uplevel #0 "source \"[ file join $dir satel.tcl               ]\""
      uplevel #0 "source \"[ file join $dir miscellaneous.tcl       ]\""
      uplevel #0 "source \"[ file join $dir google_earth.tcl        ]\""
      uplevel #0 "source \"[ file join $dir photompsf.tcl           ]\""
      uplevel #0 "source \"[ file join $dir prtr.tcl                ]\""
      uplevel #0 "source \"[ file join $dir photcal.tcl             ]\""
      uplevel #0 "source \"[ file join $dir etc_tools.tcl           ]\""
      uplevel #0 "source \"[ file join $dir meteosensor_tools.tcl   ]\""
      uplevel #0 "source \"[ file join $dir photrel.tcl             ]\""
      uplevel #0 "source \"[ file join $dir fly.tcl                 ]\""
      uplevel #0 "source \"[ file join $dir grb_tools.tcl           ]\""
      uplevel #0 "source \"[ file join $dir speckle_tools.tcl       ]\""
      
      #--- Chargement des legendes et textes pour differentes langues
      set audace(rep_caption) [ file join $audace(rep_gui) audace caption ]
      uplevel #0 "source \"[ file join $audace(rep_caption) aud_menu_5.cap      ]\""

      # connexion Mysql
      ::bddimages_sql::mysql_init
      set errconn [catch {::bddimages_sql::connect} connectstatus]
      if { $errconn } {
         puts "\[$threadId\] SET_OWN_ENV: Connexion MYSQL echouee : $connectstatus\n"
      } else {
         set ::bdi_tools_config::ok_mysql_connect 1
#         puts "\[$threadId\] SET_OWN_ENV: Connexion MYSQL reussie : $connectstatus\n"
      }

      tsv::set dispo $threadId 1
      
   }

# procedure lancee par les esclaves qui lance le travail a faire
   proc ::bdi_tools_astroid::launch {  } {

      global audace
      global bddconf
      global threadId
      global threadDispo

      tsv::set dispo $threadId 0
      #set monimage [file join /astrodata/Observations/Images/bddimages/bddimages_local/fits/t1m/2013/01/06 tT1M_20130106_230100_665_varuna_Filtre_Rs_bin1x1.13.fits.gz]
      #::buf::create 1
      #load libgzip[info sharedlibextension]
      #puts "lecture de l image : $monimage"
      #buf1 load $monimage
#      set tt0 [clock clicks -milliseconds]

      set err [catch {::gui_cata::load_cata} msg ]
      if {$err} {
         puts "\[$threadId\] Erreur chargement du cata"
      } else {
         
         set imgfilename    [::bddimages_liste::lget $::tools_cata::current_image filename]
         set imgdirfilename [::bddimages_liste::lget $::tools_cata::current_image dirfilename]
         set f [file join $bddconf(dirbase) $imgdirfilename $imgfilename ]
         if {[file exists $f]} {
            
            set bufno [::buf::create]
            buf$bufno load $f
            ::bdi_tools_psf::get_psf_listsources ::tools_cata::current_listsources
#            puts "\[$threadId\] rollup = [::manage_source::get_nb_sources_rollup $::tools_cata::current_listsources]"
            set idbddimg [::bddimages_liste::lget $::tools_cata::current_image "idbddimg"]
            set tabkey [::bddimages_liste::lget $::tools_cata::current_image "tabkey"]
            # Noms du fichier cata
            set f [file join $bddconf(dirtmp) [file rootname [file rootname $imgfilename]]]
            set cataxml "${f}_cata.xml"
            ::tools_cata::save_cata $::tools_cata::current_listsources $tabkey $cataxml
            buf::delete $bufno

         } else {
            puts "\[$threadId\] file does not exist : ${f}"
         }
      }
      
           
#      ::buf::create 1
#      set monimage [file join /astrodata/Observations/Images/bddimages/bddimages_local/fits/t1m/2013/01/06 tT1M_20130106_230100_665_varuna_Filtre_Rs_bin1x1.13.fits.gz]
#      buf1 load $monimage
#      puts "\[$threadId\] [buf1 psfimcce {403 557 437 593}]"
      
      after [expr 1000 + round(rand()*4000)] ; # on attend de 1 a 5 secondes
#      after [expr round(rand()*400)] ; # on attend de 1 a 5 secondes
#      set tt [format "%.3f" [expr ([clock clicks -milliseconds] - $tt0)/1000.]]
#      puts "\[$threadId\] end in $tt sec"
#      puts "\[$threadId\] end"
 
      tsv::set dispo $threadId 1
   }



   proc ::bdi_tools_astroid::logError {id error} {

      puts "Error in thread $id :$error "
      set ::bdi_tools_astroid::stop 2
   }




   proc ::bdi_tools_astroid::go {  } {
      
      array unset ::bdi_tools_astroid::tabthread
      array unset ::bdi_tools_astroid::res

      set ::bdi_tools_astroid::stop 0

      set tt0 [clock clicks -milliseconds]
#      gren_info "\n\n\n\n\n\n"
#      puts "\n\n\n\n\n\n"
      set nbexistthread [llength [thread::names]]
#      gren_info "*** $nbexistthread threads exists\n"
      set threadId -1
      foreach threadName [thread::names] {
         set ::bdi_tools_astroid::tabthread(id,$threadId) $threadName
         set ::bdi_tools_astroid::tabthread(name,$threadName) $threadId
         incr threadId -1
      }
#      gren_info "* Existing threads: [::bdi_tools_astroid::get_list_threadId]\n"
#      gren_info "* I'm MASTER thread $::bdi_tools_astroid::tabthread(name,[thread::id])\n"
      
      # 
      # Create threads
      # 

      for {set threadId 1} {$threadId <= $::bdi_tools_astroid::nb_threads} {incr threadId} {
         set threadName [thread::create {
            thread::wait
         }]
         
               
         set ::bdi_tools_astroid::tabthread(id,$threadId) $threadName
         set ::bdi_tools_astroid::tabthread(name,$threadName) $threadId
#         gren_info "**** Existing threads: [::bdi_tools_astroid::get_list_threadId]\n"
         
         ::thread::send $threadName [list set threadId $threadId]
         ::bdi_tools_astroid::setenv $threadName $threadId

         thread::configure $threadName -unwindonerror 1
         thread::errorproc ::bdi_tools_astroid::logError
         
         ::thread::send $threadName "::bdi_tools_astroid::set_own_env"
         
#         puts "\[$threadId\] Started thread"
#         gren_info "*** Started thread $threadId \n"
      }

      ::bdi_tools_astroid::get_dispo

      # 
      # boucle de travail
      # 

#      gren_info "Nombre d'images a traiter : $::tools_cata::nb_img_list \n"

      set idcata 0
      foreach ::tools_cata::current_image $::tools_cata::img_list {

         incr idcata

         set out 1
         while {$out} {
            if {$::bdi_tools_astroid::stop} {break}
            set threadName [::bdi_tools_astroid::get_dispo]
            if {$threadName == ""} {
               update
               after 1000
            } else {
               break
            }
         }
         if {$::bdi_tools_astroid::stop} {break}

#         gren_info "WORK $idcata\n"
         set threadId $::bdi_tools_astroid::tabthread(name,$threadName)
         set ex [thread::exists $threadName]
         if {$ex} {
            ::thread::send $threadName [list set ::tools_cata::current_image $::tools_cata::current_image]
            after 500
            ::thread::send -async $threadName "::bdi_tools_astroid::launch" res($threadId)
            after 500
         }
         ::bdi_tools_astroid::set_progress $idcata $::tools_cata::nb_img_list
      }
      
      
      

      # 
      # Attendre l arret de tous les threads
      # 

      if {$::bdi_tools_astroid::stop!=2} {
#         puts "Dispo ?"
         set out 1
         while {$out} {
            set threadName [::bdi_tools_astroid::get_nb_dispo]
            if {[::bdi_tools_astroid::get_nb_dispo] != $::bdi_tools_astroid::nb_threads} {
               after 1000
            } else {
               break
            }
         }
      }

#      puts  "Finish"
#      gren_info "Finish\n"

      # 
      # detachement des threads
      # 

      catch {
      for {set threadId 1} {$threadId <= $::bdi_tools_astroid::nb_threads} {incr threadId} {
         set threadName $::bdi_tools_astroid::tabthread(id,$threadId)
         set ex [thread::exists $threadName]
#         puts "\[$threadId\] exist ? = [thread::exists $threadName]"
         if {$ex} {
            ::thread::release $threadName
#            puts "\[$threadId\] release"
         }
      }
      }
      
      # 
      # Fin
      # 
#      puts "*** That's all, folks!"
      set tt [format "%.3f" [expr ([clock clicks -milliseconds] - $tt0)/1000.]]
      gren_info "Traitement ASTROID complet en $tt sec \n"
#      puts "Traitement complet en $tt sec \n"

      array unset ::bdi_tools_astroid::tabthread
      array unset ::bdi_tools_astroid::res
      unset ::bdi_tools_astroid::nb_threads
   }







