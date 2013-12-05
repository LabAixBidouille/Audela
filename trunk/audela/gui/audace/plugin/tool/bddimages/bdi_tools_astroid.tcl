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

# procedure lancee par le maitre pour initialiser l'environnement 
# des variables globales sur les esclaves

   proc ::bdi_tools_astroid::setenv { threadName threadId } {

      global audace
      global langage

      set a [array get audace]
      ::thread::send $threadName [list array set audace $a]
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
#      puts "\[$threadId\] SETENV: bdi ressource : $msg"
      

   }
 




# procedure lancee par les esclaves pour charger eux memes leur environnement
   proc ::bdi_tools_astroid::set_own_env {  } {

      global audace
      global threadId
      global threadDispo
      
      cd [file join $audace(rep_install) bin]
#      puts "\[$threadId\] PWD = [pwd]"

      set audelaLibPath [file join [file join [file dirname [file dirname [info nameofexecutable]] ] lib]]
#      puts "\[$threadId\] SET_OWN_ENV: audelaLibPath = $audelaLibPath"
      if { [lsearch $::auto_path $audelaLibPath] == -1 } {
         lappend ::auto_path $audelaLibPath
      }
      
      #puts "\[$threadId\] audace(rep_gui) = $audace(rep_gui)"

      set dir [file join $audace(rep_gui) audace]

      uplevel #0 "source \"[ file join $dir console.tcl ]\""
      uplevel #0 "source \"[ file join $dir vo_tools.tcl ]\""
      uplevel #0 "source \"[ file join $dir surchaud.tcl ]\""

      set err [catch {load libgzip[info sharedlibextension]} msg]
      if {$err} { puts "\[$threadId\] SET_OWN_ENV: libgzip = $msg" }

      set err [catch {load libaudela[info sharedlibextension]} msg]
      if {$err} { puts "\[$threadId\] SET_OWN_ENV: libaudela = $msg" }

      tsv::set dispo $threadId 1
      
   }

# procedure lancee par les esclaves qui lance le travail a faire
   proc ::bdi_tools_astroid::launch {  } {

      global audace
      global threadId
      global threadDispo

      tsv::set dispo $threadId 0
      #set monimage [file join /astrodata/Observations/Images/bddimages/bddimages_local/fits/t1m/2013/01/06 tT1M_20130106_230100_665_varuna_Filtre_Rs_bin1x1.13.fits.gz]
      #::buf::create 1
      #load libgzip[info sharedlibextension]
      #puts "lecture de l image : $monimage"
      #buf1 load $monimage
#      puts "\[$threadId\] wait"
#      set tt0 [clock clicks -milliseconds]
           
      ::buf::create 1
      set monimage [file join /astrodata/Observations/Images/bddimages/bddimages_local/fits/t1m/2013/01/06 tT1M_20130106_230100_665_varuna_Filtre_Rs_bin1x1.13.fits.gz]
      buf1 load $monimage
      puts "\[$threadId\] [buf1 psfimcce {403 557 437 593}]"
      
      after [expr 1000 + round(rand()*4000)] ; # on attend de 1 a 5 secondes
#      set tt [format "%.3f" [expr ([clock clicks -milliseconds] - $tt0)/1000.]]
#      puts "\[$threadId\] end in $tt sec"
#      puts "\[$threadId\] end"
 
      tsv::set dispo $threadId 1
   }


   proc ::bdi_tools_astroid::go {  } {
      
      array unset ::bdi_tools_astroid::tabthread
      array unset ::bdi_tools_astroid::res

      set tt0 [clock clicks -milliseconds]
      gren_info "\n\n\n\n\n\n"
      puts "\n\n\n\n\n\n"
      set nbexistthread [llength [thread::names]]
      gren_info "*** $nbexistthread threads exists\n"
      set threadId -1
      foreach threadName [thread::names] {
         set ::bdi_tools_astroid::tabthread(id,$threadId) $threadName
         set ::bdi_tools_astroid::tabthread(name,$threadName) $threadId
         incr threadId -1
      }
      gren_info "* Existing threads: [::bdi_tools_astroid::get_list_threadId]\n"
      gren_info "* I'm MASTER thread $::bdi_tools_astroid::tabthread(name,[thread::id])\n"
      
       # Create threads
      for {set threadId 1} {$threadId <= $::bdi_tools_astroid::nb_threads} {incr threadId} {
         set threadName [thread::create {
            thread::wait
         }]
         
         set ::bdi_tools_astroid::tabthread(id,$threadId) $threadName
         set ::bdi_tools_astroid::tabthread(name,$threadName) $threadId
         gren_info "**** Existing threads: [::bdi_tools_astroid::get_list_threadId]\n"
         
         ::thread::send $threadName [list set threadId $threadId]
         ::bdi_tools_astroid::setenv $threadName $threadId
         
         ::thread::send $threadName "::bdi_tools_astroid::set_own_env"
         
         puts "\[$threadId\] Started thread"
         gren_info "*** Started thread $threadId \n"
      }

      ::bdi_tools_astroid::get_dispo

      # boucle de travail
#      for {set threadId 1} {$threadId <= $::bdi_tools_astroid::nb_threads} {incr threadId} {
#         set threadName $::bdi_tools_astroid::tabthread(id,$threadId)
#         set ex [thread::exists $threadName]
#         if {$ex} {
#            ::thread::send -async $threadName "::bdi_tools_astroid::launch" res($threadId)
#            ::bdi_tools_astroid::get_dispo
#            after 100
#         }
#      }
#
#      ::bdi_tools_astroid::get_dispo
    
      
      for {set i 1} {$i <= 10} {incr i} {

         set out 1
         while {$out} {
            set threadName [::bdi_tools_astroid::get_dispo]
            if {$threadName == ""} {
               after 1000
            } else {
               break
            }
         }
         gren_info "WORK $i\n"
         set threadId $::bdi_tools_astroid::tabthread(name,$threadName)
         set ex [thread::exists $threadName]
         if {$ex} {
            ::thread::send -async $threadName "::bdi_tools_astroid::launch" res($threadId)
            after 100
         }
      }
      
      
      

      # Attendre l arret de tous les threads

         set out 1
         while {$out} {
            set threadName [::bdi_tools_astroid::get_nb_dispo]
            if {[::bdi_tools_astroid::get_nb_dispo] != $::bdi_tools_astroid::nb_threads} {
               after 1000
            } else {
               break
            }
         }
         gren_info "Finish\n"



      #for {set threadId 1} {$threadId <= $::bdi_tools_astroid::nb_threads} {incr threadId} {
      #   vwait res($threadId)
      #}
      
      # Attendre l arret de tous les threads
      catch {
      for {set threadId 1} {$threadId <= $::bdi_tools_astroid::nb_threads} {incr threadId} {
         set threadName $::bdi_tools_astroid::tabthread(id,$threadId)
         set ex [thread::exists $threadName]
         puts "\[$threadId\] exist ? = [thread::exists $threadName]"
         if {$ex} {
            ::thread::release $threadName
            puts "\[$threadId\] release"
         }
      }
      }
      
      puts "*** That's all, folks!"
      set tt [format "%.3f" [expr ([clock clicks -milliseconds] - $tt0)/1000.]]
      gren_info "Traitement complet en $tt sec \n"
      puts "Traitement complet en $tt sec \n"

      array unset ::bdi_tools_astroid::tabthread
      array unset ::bdi_tools_astroid::res
      unset ::bdi_tools_astroid::nb_threads
   }









