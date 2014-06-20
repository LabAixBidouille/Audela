## @file bdi_gui_reports.tcl
#  @brief     GUI dediee aux rapports d'analyse
#  @author    Frederic Vachier and Jerome Berthier
#  @version   1.0
#  @date      2014
#  @copyright GNU Public License.
#  @par Ressource 
#  @code  source [file join $audace(rep_install) gui audace plugin tool bddimages bdi_gui_reports.tcl]
#  @endcode

# Mise à jour $Id: bdi_gui_reports.tcl 9215 2013-03-15 15:36:44Z jberthier $

#============================================================
## Declaration du namespace \c bdi_gui_reports .
#  @brief     GUI dediee aux rapports d'analyse
#  @pre       Requiert bdi_tools_xml 1.0 et bddimagesAdmin 1.0
#  @warning   Pour developpeur seulement
#
namespace eval bdi_gui_reports {

}


   #------------------------------------------------------------
   ## Creation de la GUI de gestion des configurations
   #  @return void
   #
   proc ::bdi_gui_reports::inittoconf {  } {


   }

   #------------------------------------------------------------
   ## Fermeture et destruction de la GUI
   #  @return void
   #
   proc ::bdi_gui_reports::fermer { } {

      #::bdi_gui_reports::closetoconf
      ::bdi_gui_reports::recup_position
      destroy $::bdi_gui_reports::fen

   }

   #------------------------------------------------------------
   ## Recuperation de la position d'affichage de la GUI
   #  @return void
   #
   proc ::bdi_gui_reports::recup_position { } {

      global conf bddconf

      set bddconf(geometry_reports) [ wm geometry $::bdi_gui_reports::fen ]
      set conf(bddimages,geometry_reports) $bddconf(geometry_reports)

   }

   #----------------------------------------------------------------------------
   ## Relance l outil
   # Les variables utilisees sont affectees a la variable globale
   # \c conf
   proc ::bdi_gui_reports::relance {  } {

      ::bddimages::ressource
      ::bdi_gui_reports::fermer
      ::bdi_gui_reports::run

   }


   # On click
   proc ::bdi_gui_reports::cmdButton1Click_data_objects { w args } {
      
      global bddconf
      
      set curselection [$::bdi_tools_reports::data_objects curselection]
      set nb [llength $curselection]
      #gren_info "nb select = $nb\n"

      if {$nb == 0 } {return}
      if {$nb > 1 } {
         tk_messageBox -message "Veuillez selectionner 1 seul objet" -type ok
         return
      }
      
      set cpt 0
      foreach line [$::bdi_tools_reports::data_objects get 0 end] {
         $::bdi_tools_reports::data_objects cellconfigure $cpt,0 -font $bddconf(font,arial_10)
         incr cpt
      }
      
      foreach select $curselection {
         $::bdi_tools_reports::data_objects cellconfigure $select,0 -font $bddconf(font,arial_10_b)
         set obj [lindex [$::bdi_tools_reports::data_objects get $select] 0]
         gren_info "Info sur l objet : $obj\n"
      }
      set ::bdi_gui_reports::selected_obj $obj
      
      
      $::bdi_tools_reports::data_firstdate delete 0 end

      foreach firstdate $::bdi_tools_reports::list_blocks($obj) {
         
         $::bdi_tools_reports::data_firstdate insert end $firstdate

      }

      $::bdi_tools_reports::data_reports delete 0 end

   }



   # On click
   proc ::bdi_gui_reports::cmdButton1Click_data_firstdate { w args } {
      
      global bddconf
      
      set objects $::bdi_gui_reports::fen.appli.buttons.objects
      set dates   $::bdi_gui_reports::fen.appli.buttons.dates

      if {[$objects cget -relief] == "raised"} {

         gren_info "choose dates\n"



      } else {
         gren_info "choose objects\n"
         #gren_info "1Click : ($w) ($args)\n"

         set curselection [$::bdi_tools_reports::data_firstdate curselection]
         set nb [llength $curselection]
         if {$nb == 0 } {return}
         if {$nb > 1 } {
            tk_messageBox -message "Veuillez selectionner 1 seule date" -type ok
            return
         }

         set cpt 0
         foreach line [$::bdi_tools_reports::data_firstdate get 0 end] {
            $::bdi_tools_reports::data_firstdate cellconfigure $cpt,0 -font $bddconf(font,arial_10)
            incr cpt
         }
         set select [lindex $curselection 0]
         $::bdi_tools_reports::data_firstdate cellconfigure $select,0 -font $bddconf(font,arial_10_b)
         set ::bdi_gui_reports::selected_firstdate [lindex [$::bdi_tools_reports::data_firstdate get $select] 0]

         set obj       $::bdi_gui_reports::selected_obj
         set firstdate $::bdi_gui_reports::selected_firstdate

         $::bdi_tools_reports::data_reports delete 0 end

         foreach batch $::bdi_tools_reports::list_reports($obj,$firstdate,batch) {
            set line ""

            lappend line $batch
            lappend line $::bdi_tools_reports::list_reports($obj,$firstdate,$batch,astrom,txt)
            lappend line $::bdi_tools_reports::list_reports($obj,$firstdate,$batch,astrom,xml)
            lappend line $::bdi_tools_reports::list_reports($obj,$firstdate,$batch,astrom,mpc)
            lappend line $::bdi_tools_reports::list_reports($obj,$firstdate,$batch,photom,txt)
            lappend line $::bdi_tools_reports::list_reports($obj,$firstdate,$batch,photom,xml)
            lappend line $::bdi_tools_reports::list_reports($obj,$firstdate,$batch,astrom,mpc,submit)
            if {![info exists ::bdi_tools_reports::list_reports($obj,$firstdate,$batch,comment)]} {
               lappend line ""
            } else {
               lappend line $::bdi_tools_reports::list_reports($obj,$firstdate,$batch,comment)
            }


            $::bdi_tools_reports::data_reports insert end $line
         }
         $::bdi_tools_reports::data_reports sortbycolumn 0 -decreasing

      }
      
   }




   proc ::bdi_gui_reports::cmdButton1Click_data_reports { w args } {

      #gren_info "1Click : ($w) ($args)\n"
   }





   proc ::bdi_gui_reports::get_submit { file } {

      set pos [string last "submit." $file]
      if {$pos == -1} {return no}
      set pos [expr $pos + 7 ]
      set file [string range $file $pos end]
      set pos [expr [string first "." $file] -1 ]
      return [string range $file 0 $pos]
   }


   proc ::bdi_gui_reports::switch_submit { file } {
      
      set pos [string last "submit." $file]
      if {$pos == -1} {return -1}
      
      set deb  [string range $file 0 [expr $pos - 1]]
      set last [string range $file [expr $pos + 7] end]
      set pos [expr [string first "." $last] -1 ]
      set flag [string range $last 0 $pos]
      
      set pos [expr [string first "." $last] ]
      set last [string range $last $pos end]
      
      switch $flag {
         "no" {
            set newflag "yes"
         }
         "yes" {
            set newflag "no"
         }
         default {
            return -1
         }
      }
      return "${deb}submit.${newflag}${last}"
   }



   proc ::bdi_gui_reports::get_batch { file } {
   
      set pos [expr [string last "Batch" $file] + 6]
      set batch [string range $file $pos end]
      set pos [expr [string first "." $batch] -1]
      set batch [string range $batch 0 $pos]
      return $batch
      
   }

   proc ::bdi_gui_reports::get_uaicode { line char } {
       
      set pos [string last "IAU code" $line]
      if {$pos == -1} {return -1}
      set pos [expr [string last $char $line] +1]
      set uaicode [string trim [string range $line $pos end]]
      
   }


   proc ::bdi_gui_reports::charge { } {
      
      global bddconf

      set tt0 [clock clicks -milliseconds]

      $::bdi_tools_reports::data_objects   delete 0 end
      $::bdi_tools_reports::data_firstdate delete 0 end
      $::bdi_tools_reports::data_reports   delete 0 end
      
      gren_info "Analyse du repertoire des Rapports : $bddconf(dirreports)\n"
      set err [catch {set liste [glob $bddconf(dirreports)/*]} msg ]
      
      if {$err} {
         gren_erreur "$msg\n"
         return
      }
      
      # Recupere la liste des objets
      set ::bdi_tools_reports::list_objects ""
      foreach i $liste {
         if {[file type $i]=="directory"} {
            lappend ::bdi_tools_reports::list_objects [file tail $i]
         }
      }      

      # Recupere la liste des nuits
      array unset ::bdi_tools_reports::list_blocks 
      set ::bdi_tools_reports::list_dates ""
      foreach obj $::bdi_tools_reports::list_objects {
         set dir [file join $bddconf(dirreports) $obj]
         set liste [glob $dir/*]
         foreach i $liste {
            if {[file type $i]=="directory"} {
               lappend ::bdi_tools_reports::list_blocks($obj) [file tail $i]
               lappend ::bdi_tools_reports::list_dates [file tail $i]
            }
         }
      }
      
      # construit la liste des dates
      set ::bdi_tools_reports::list_dates [lsort -dic -unique $::bdi_tools_reports::list_dates]
       
      # Recupere la liste des rapports
      foreach obj $::bdi_tools_reports::list_objects {
         foreach block $::bdi_tools_reports::list_blocks($obj) {
            set ::bdi_tools_reports::list_reports($obj,$block,batch) ""
            set dir [file join $bddconf(dirreports) $obj $block]
            set err [catch {set liste [glob $dir/*]} msg]
            if {$err} {continue}
            array unset tab
            foreach i $liste {
               if {[file type $i]=="directory"} {
                  #gren_info "i = $i\n"
                  
                  # astrometrie TXT
                  set err [catch {set zliste [glob $i/*]} msg]
                  if {!$err} {
                     foreach j $zliste {
                        
                        set file [file tail $j]
                        gren_info "file = $file\n"
                        set ext  [file extension $file]
                        set batch [::bdi_gui_reports::get_batch $file]
                        set tab($batch) 1
                        
                        if {![info exists ::bdi_tools_reports::list_reports($obj,$block,$batch,submit)]} {
                           #gren_info "list_reports($obj,$block,$batch,astrom,mpc,submit) not exist -> no\n"
                           set ::bdi_tools_reports::list_reports($obj,$block,$batch,astrom,mpc,submit) "no"
                        } else {
                           #gren_info "list_reports($obj,$block,$batch,astrom,mpc,submit) exist == $::bdi_tools_reports::list_reports($obj,$block,$batch,astrom,mpc,submit)\n"
                        }
                        if {$::bdi_tools_reports::list_reports($obj,$block,$batch,astrom,mpc,submit)!="yes"} {
                           set ::bdi_tools_reports::list_reports($obj,$block,$batch,astrom,mpc,submit) [::bdi_gui_reports::get_submit $file]
                           #gren_info "list_reports($obj,$block,$batch,astrom,mpc,submit) <> yes -> $::bdi_tools_reports::list_reports($obj,$block,$batch,astrom,mpc,submit)\n"
                        }

                        if {![info exists ::bdi_tools_reports::list_reports($obj,$block,$batch,astrom,mpc)]} {set ::bdi_tools_reports::list_reports($obj,$block,$batch,astrom,mpc) "-"}
                        if {![info exists ::bdi_tools_reports::list_reports($obj,$block,$batch,astrom,txt)]} {set ::bdi_tools_reports::list_reports($obj,$block,$batch,astrom,txt) "-"}
                        if {![info exists ::bdi_tools_reports::list_reports($obj,$block,$batch,astrom,xml)]} {set ::bdi_tools_reports::list_reports($obj,$block,$batch,astrom,xml) "-"}
                        if {![info exists ::bdi_tools_reports::list_reports($obj,$block,$batch,photom,txt)]} {set ::bdi_tools_reports::list_reports($obj,$block,$batch,photom,txt) "-"}
                        if {![info exists ::bdi_tools_reports::list_reports($obj,$block,$batch,photom,xml)]} {set ::bdi_tools_reports::list_reports($obj,$block,$batch,photom,xml) "-"}

                        if {$ext == ".mpc" && [file tail $i]=="astrom_mpc"} {
                           set ::bdi_tools_reports::list_reports($obj,$block,$batch,astrom,mpc,file) $j
                           set ::bdi_tools_reports::list_reports($obj,$block,$batch,astrom,mpc) "Y"
                        }
                        if {$ext == ".txt" && [file tail $i]=="astrom_txt"} {
                           set ::bdi_tools_reports::list_reports($obj,$block,$batch,astrom,txt,file) $j
                           set ::bdi_tools_reports::list_reports($obj,$block,$batch,astrom,txt) "Y"
                        }
                        if {$ext == ".xml" && [file tail $i]=="astrom_xml"} {
                           set ::bdi_tools_reports::list_reports($obj,$block,$batch,astrom,xml,file) $j
                           set ::bdi_tools_reports::list_reports($obj,$block,$batch,astrom,xml) "Y"
                        }
                        if {$ext == ".txt" && [file tail $i]=="photom_txt"} {
                           set ::bdi_tools_reports::list_reports($obj,$block,$batch,photom,txt,file) $j
                           set ::bdi_tools_reports::list_reports($obj,$block,$batch,photom,txt) "Y"
                        }
                        if {$ext == ".xml" && [file tail $i]=="photom_xml"} {
                           set ::bdi_tools_reports::list_reports($obj,$block,$batch,photom,xml,file) $j
                           set ::bdi_tools_reports::list_reports($obj,$block,$batch,photom,xml) "Y"
                        }
                        
                     }
                  } else {
                     #gren_erreur "$msg\n"
                     
                  }
                  
               } else {
                  # Lecture des commentaires
                  
                  set batch [::bdi_gui_reports::get_batch [file tail $i]]
                  set chan [open $i r]
                  while {[gets $chan line] >= 0} {
                     set ::bdi_tools_reports::list_reports($obj,$block,$batch,comment)  [string trim $line]
                  }
                  close $chan
                  gren_info "comment = ::bdi_tools_reports::list_reports($obj,$block,$batch,comment)\n"
                  gren_info "comment = $::bdi_tools_reports::list_reports($obj,$block,$batch,comment)\n"
               }
            }
            set ::bdi_tools_reports::list_reports($obj,$block,batch) ""
            foreach { x y } [array get tab] {
               lappend ::bdi_tools_reports::list_reports($obj,$block,batch) $x
            }
         }
      }

      
      # set ::bdi_tools_reports::data_objects
      
      # Fin de visualisation des donnees
      set tt [format "%.3f" [expr ([clock clicks -milliseconds] - $tt0)/1000.]]
      gren_info "Chargement complet en $tt sec \n"
      
      ::bdi_gui_reports::affiche_data
   }



   #------------------------------------------------------------
   ## Affichage des donnees dans la GUI
   #  @return void
   #
   proc ::bdi_gui_reports::affiche_data { } {
      
      set tt0 [clock clicks -milliseconds]

      $::bdi_tools_reports::data_objects   delete 0 end
      $::bdi_tools_reports::data_firstdate delete 0 end
      $::bdi_tools_reports::data_reports   delete 0 end

      set objects $::bdi_gui_reports::fen.appli.buttons.objects
      set dates   $::bdi_gui_reports::fen.appli.buttons.dates

      if {[$objects cget -relief] == "raised"} {
      
         gren_info "choose dates\n"

         set cpt 0
         foreach block $::bdi_tools_reports::list_dates {
            $::bdi_tools_reports::data_firstdate insert end $block
            if {[info exists ::bdi_gui_reports::selected_firstdate]} {
               if {$::bdi_gui_reports::selected_firstdate==$block} {
                  $::bdi_tools_reports::data_firstdate  cellselection  set $cpt,0 $cpt,end
               }
            }
            incr cpt
         }      

         if {[info exists ::bdi_gui_reports::selected_firstdate]} {

            ::bdi_gui_reports::cmdButton1Click_data_firstdate ::bdi_tools_reports::data_firstdate

            if {[info exists ::bdi_gui_reports::selected_obj]} {

               set cpt 0
               foreach object [$::bdi_tools_reports::data_objects get 0 end] {
                  gren_info "line // $object\n"
                  if  { $object == $::bdi_gui_reports::selected_obj} {
                     $::bdi_tools_reports::data_objects cellselection  set $cpt,0 $cpt,end
                  }
                  incr cpt
               }
               ::bdi_gui_reports::cmdButton1Click_data_objects ::bdi_tools_reports::data_objects

            }

         }


      } else {

         gren_info "choose objects\n"

         set cpt 0
         foreach obj $::bdi_tools_reports::list_objects {
            $::bdi_tools_reports::data_objects insert end $obj
            if {[info exists ::bdi_gui_reports::selected_obj]} {
               if {$::bdi_gui_reports::selected_obj==$obj} {
                  $::bdi_tools_reports::data_objects  cellselection  set $cpt,0 $cpt,end
               }
            }
            incr cpt
         }      

         if {[info exists ::bdi_gui_reports::selected_obj]} {

            ::bdi_gui_reports::cmdButton1Click_data_objects ::bdi_tools_reports::data_objects

            if {[info exists ::bdi_gui_reports::selected_firstdate]} {

               set cpt 0
               foreach firstdate [$::bdi_tools_reports::data_firstdate get 0 end] {
                  gren_info "line // $firstdate\n"
                  if  { $firstdate == $::bdi_gui_reports::selected_firstdate} {
                     $::bdi_tools_reports::data_firstdate cellselection  set $cpt,0 $cpt,end
                  }
                  incr cpt
               }
               ::bdi_gui_reports::cmdButton1Click_data_firstdate ::bdi_tools_reports::data_firstdate

            }

         }
            
      }


      


      
      # Fin de visualisation des donnees
      set tt [format "%.3f" [expr ([clock clicks -milliseconds] - $tt0)/1000.]]
      gren_info "Affichage complet en $tt sec \n"
      
   }






   proc ::bdi_gui_reports::close_reports2 {  } {
      global conf bddconf 

      set bddconf(geometry_reports2) [ wm geometry .reports2 ]
      set conf(bddimages,geometry_reports2) $bddconf(geometry_reports2)
      destroy .reports2
      
   }
   #------------------------------------------------------------
   ## Affichage des rapports dans une GUI
   #  @return void
   #
   proc ::bdi_gui_reports::affiche_rapport { type } {

      global conf bddconf 

      gren_info "Obj = $::bdi_gui_reports::selected_obj\n"
      set obj $::bdi_gui_reports::selected_obj
      
      set curselection [$::bdi_tools_reports::data_reports curselection]
      set nb [llength $curselection]
      if {$nb !=1 } {
         tk_messageBox -message "Veuillez selectionner 1 seule entree" -type ok
         return
      }
      
      set firstdate $::bdi_gui_reports::selected_firstdate
      
      foreach select $curselection {
         set batch [lindex [$::bdi_tools_reports::data_reports get $select] 0]
      }
      gren_info "firstdate = $firstdate\n"
      gren_info "batch = $batch\n"
      gren_info "type = $type\n"

      if {$::bdi_tools_reports::list_reports($obj,$firstdate,$batch,$type)=="-"} {
         tk_messageBox -message "Le rapport $type n existe pas" -type ok
         return
      }
      set file $::bdi_tools_reports::list_reports($obj,$firstdate,$batch,$type,file)
      gren_info "file = $file\n"
      
      
      
      #--- Geometry
      if { ! [ info exists conf(bddimages,geometry_reports2) ] } {
         set conf(bddimages,geometry_reports2) "100x100+400+200"
      }
      set bddconf(geometry_reports2) $conf(bddimages,geometry_reports2)

      #--- Declare la GUI
      set fen .reports2
      if { [ winfo exists .reports2 ] } {
         wm withdraw .reports2
         wm deiconify .reports2
         return
      }

      #--- GUI
      toplevel .reports2 -class Toplevel
      wm geometry .reports2 $bddconf(geometry_reports2)
      wm resizable .reports2 1 1
      wm title .reports2 $file
      wm protocol .reports2 WM_DELETE_WINDOW "::bdi_gui_reports::close_reports2"

      set frm .reports2.appli

      frame $frm  -cursor arrow -relief groove
      pack $frm -in .reports2 -anchor s -side top -expand yes -fill both -padx 10 -pady 5

      set rapport $frm.text
      text $rapport -height 30 -width 80 \
           -xscrollcommand "$rapport.xscroll set" \
           -yscrollcommand "$rapport.yscroll set" \
           -wrap none
      pack $rapport -expand yes -fill both -padx 5 -pady 5

      scrollbar $rapport.xscroll -orient horizontal -cursor arrow -command "$rapport xview"
      pack $rapport.xscroll -side bottom -fill x

      scrollbar $rapport.yscroll -orient vertical -cursor arrow -command "$rapport yview"
      pack $rapport.yscroll -side right -fill y

      $rapport delete 0.0 end

      set chan [open $file r]

      while {[gets $chan line] >= 0} {
         $rapport insert end "$line\n"
      }
      close $chan
   }
   
   
   #------------------------------------------------------------
   ## Effacement des entrees
   #  @return void
   #
   proc ::bdi_gui_reports::delete_reports { } {

      global  bddconf 
      
      if {![info exists ::bdi_gui_reports::selected_obj]} {
         tk_messageBox -message "Veuillez selectionner un objet dans la liste haute" -type ok
         return
      }
      if {$::bdi_gui_reports::selected_obj==""} {
         tk_messageBox -message "Veuillez selectionner un objet dans la liste haute" -type ok
         return
      }
      
      set obj $::bdi_gui_reports::selected_obj
      set firstdate $::bdi_gui_reports::selected_firstdate
      
      set curselection [$::bdi_tools_reports::data_reports curselection]
      foreach select $curselection {


         set batch [lindex [$::bdi_tools_reports::data_reports get $select] 0]
         #gren_info "block = $firstdate\n"
         #gren_info "batch = $batch\n"
         
         set dir [file join $bddconf(dirreports) $obj $firstdate]
         #gren_info "dir = $dir batch = $batch\n"
         set liste [globr $dir]
         foreach file $liste {
            set pos [string first $batch $file]
            if {$pos !=-1} {
               gren_info "Delete: $file\n"
               set err [catch {file delete -force $file} msg]
                if {$err} {gren_erreur $msg}
            }
         }

         $::bdi_tools_reports::data_reports delete $select

      }
      
      ::bdi_gui_reports::charge
      
   }

   proc ::bdi_gui_reports::build_mail { type batch file } {
      
      global conf
      
      switch $type {
         "astrom_mpc" {
            set desti $conf(bddimages,astrometry,reports,mail)
            
         }
         "photom_txt" {
            set desti $conf(bddimages,photometry,reports,mail)
         }
      }

      set chan [open $file r]
      set strl ""
      while {[gets $chan line] >= 0} {
         append strl "$line\n"
      }
      close $chan
      puts $strl

     ::bdi_tools::sendmail::compose_with_thunderbird $desti $batch $strl

   }
   
   #------------------------------------------------------------
   ## Soumission quelconque
   #  @return void
   #
   proc ::bdi_gui_reports::submit_reports { } {


      global conf
      global bddconf
      
      if {![info exists ::bdi_gui_reports::selected_obj]} {
         tk_messageBox -message "Veuillez selectionner un objet dans la liste haute" -type ok
         return
      }
      if {$::bdi_gui_reports::selected_obj==""} {
         tk_messageBox -message "Veuillez selectionner un objet dans la liste haute" -type ok
         return
      }
      
      set obj $::bdi_gui_reports::selected_obj
      set firstdate $::bdi_gui_reports::selected_firstdate
      
      
      set curselection [$::bdi_tools_reports::data_reports curselection]
      foreach select $curselection {

         set batch [lindex [$::bdi_tools_reports::data_reports get $select] 0]
         set flag  [lindex [$::bdi_tools_reports::data_reports get $select] 6]
         
         #gren_info "firstdate = $firstdate\n"
         #gren_info "batch = $batch\n"
         #gren_info "flag  = $flag\n"
         
         switch $flag {
            "no" {
               set newflag "yes"
            }
            "yes" {
               set newflag "no"
            }
            default {
               set newflag "yes"
            }
         }
         #gren_info "newflag  = $newflag\n"
         
         set file_astrom ""
         set file_photom ""
         set dir [file join $bddconf(dirreports) $obj $firstdate]
         #gren_info "dir = $dir batch = $batch\n"
         set liste [globr $dir]
         set attachment ""
         foreach file $liste {
            set pos [string first $batch $file]
            if {$pos !=-1} {
               append attachment "file://${file},"

               set ext  [file extension $file]
               if {$ext == ".txt" && [string last "astrom_txt" $file]>0} { set file_astrom $file }
               if {$ext == ".txt" && [string last "photom_txt" $file]>0} { set file_photom $file }
            }
         }
         set uaicode -1

         set body "Hi !\n"
         append body "\n"
         append body "You should find attached all files corresponding to the reduction of this set of observations.\n"
         append body "A short header are present here :\n"
         append body "\n"
         
         set type ""
         
         if {$file_astrom!=""} {
            
            append body "** ASTROMETRY REPORTS **\n"
            append body "\n"

            set chan [open $file_astrom r]
            set cpt 0
            while {[gets $chan line] >= 0} {
               if {$uaicode == -1} {set uaicode [::bdi_gui_reports::get_uaicode $line ":"]}
               if {$cpt >0} {append body "$line\n"}
               incr cpt
               if {$cpt >10} {break}
            }
            close $chan
            
            set type "ASTROM"
            set to $conf(bddimages,astrometry,reports,mail)
            
         }
            
         if {$file_photom!=""} {
        
            append body "** PHOTOMETRY REPORTS **\n"
            append body "\n"

            set chan [open $file_photom r]
            set cpt 0
            while {[gets $chan line] >= 0} {
               if {$uaicode == -1} {set uaicode [::bdi_gui_reports::get_uaicode $line "="]}
               append body "$line\n"
               incr cpt
               if {$cpt >10} {break}
            }
            close $chan
            
            set type "PHOTOM"
            set to $conf(bddimages,photometry,reports,mail)
            
         }
         
         set subject "\[OBSERVATION\]\[${type}\]\[$uaicode\]\[$firstdate\]\[$obj\] $batch"
         
         
         if {$attachment != "" } {
            set attachment [string range $attachment 0 end-1]
            set attachment ",attachment='${attachment}'"
         }
         set err [catch {exec $::bdi_tools::sendmail::thunderbird --compose "to='${to}',subject='${subject}',body='${body}'${attachment}"} msg]
         if {$err != 0} {
            gren_erreur "ERROR: unable to launch thunderbird ($msg)"
         }
         
      }
   
   
   
   
   }
   #------------------------------------------------------------
   ## Soumission au MPC
   #  @return void
   #
   proc ::bdi_gui_reports::submit_reports_mpc { } {


      global conf
      global bddconf
      
      if {![info exists ::bdi_gui_reports::selected_obj]} {
         tk_messageBox -message "Veuillez selectionner un objet dans la liste haute" -type ok
         return
      }
      if {$::bdi_gui_reports::selected_obj==""} {
         tk_messageBox -message "Veuillez selectionner un objet dans la liste haute" -type ok
         return
      }
      
      set obj $::bdi_gui_reports::selected_obj
      set firstdate $::bdi_gui_reports::selected_firstdate
      
      
      set curselection [$::bdi_tools_reports::data_reports curselection]
      foreach select $curselection {

         set batch [lindex [$::bdi_tools_reports::data_reports get $select] 0]
         set flag  [lindex [$::bdi_tools_reports::data_reports get $select] 6]
         
         #gren_info "firstdate = $firstdate\n"
         #gren_info "batch = $batch\n"
         #gren_info "flag  = $flag\n"
         
         switch $flag {
            "no" {
               set newflag "yes"
            }
            "yes" {
               set newflag "no"
            }
            default {
               set newflag "yes"
            }
         }
         #gren_info "newflag  = $newflag\n"
         
         set dir [file join $bddconf(dirreports) $obj $firstdate]
         #gren_info "dir = $dir batch = $batch\n"
         set liste [globr $dir]
         foreach file $liste {
            set pos [string first $batch $file]
            if {$pos !=-1} {
               #gren_info "file: $file\n"
               set ext  [file extension $file]
               if {$ext == ".mpc" && [string last "astrom_mpc" $file]>0} {
                  gren_info "envoyer au mpc : $file\n"
                  ::bdi_gui_reports::build_window $batch $file
               }
            }
         }
         
         
      }
   
   
   
   
   }

   
   
   #------------------------------------------------------------
   ## Flag du MPC
   #  @return void
   #
   proc ::bdi_gui_reports::submit_flag { } {

      global bddconf
      
      if {![info exists ::bdi_gui_reports::selected_obj]} {
         tk_messageBox -message "Veuillez selectionner un objet dans la liste haute" -type ok
         return
      }
      if {$::bdi_gui_reports::selected_obj==""} {
         tk_messageBox -message "Veuillez selectionner un objet dans la liste haute" -type ok
         return
      }
      
      set obj $::bdi_gui_reports::selected_obj
      set firstdate $::bdi_gui_reports::selected_firstdate
      
      
      set curselection [$::bdi_tools_reports::data_reports curselection]
      foreach select $curselection {

         set batch [lindex [$::bdi_tools_reports::data_reports get $select] 0]
         set flag  [lindex [$::bdi_tools_reports::data_reports get $select] 6]
         
         #gren_info "firstdate = $firstdate\n"
         #gren_info "batch = $batch\n"
         #gren_info "flag  = $flag\n"
         
         switch $flag {
            "no" {
               set newflag "yes"
            }
            "yes" {
               set newflag "no"
            }
            default {
               set newflag "yes"
            }
         }
         #gren_info "newflag  = $newflag\n"
         
         set dir [file join $bddconf(dirreports) $obj $firstdate]
         #gren_info "dir = $dir batch = $batch\n"
         set liste [globr $dir]
         foreach file $liste {
            set pos [string first $batch $file]
            if {$pos !=-1} {
               #gren_info "file: $file\n"
               set newfile [::bdi_gui_reports::switch_submit $file]
               #gren_info "newfile: $newfile\n"
               if {$newfile!=-1} {
                  set err [catch {file rename -force $file $newfile} msg]
                  if {$err} {gren_erreur $msg}
               }
            }
         }
         
         
         
         
         
         $::bdi_tools_reports::data_reports cellconfigure $select,6 -text $newflag
         
      }
      
      #::bdi_gui_reports::charge
   }
   
   #------------------------------------------------------------
   ## affiche dans la console le repertoire des donnees
   #  @return void
   #
   proc ::bdi_gui_reports::get_workdir_reports { } {

      global  bddconf 
      
      if {![info exists ::bdi_gui_reports::selected_obj]} {
         tk_messageBox -message "Veuillez selectionner un objet dans la liste haute" -type ok
         return
      }
      if {$::bdi_gui_reports::selected_obj==""} {
         tk_messageBox -message "Veuillez selectionner un objet dans la liste haute" -type ok
         return
      }
      
      set obj $::bdi_gui_reports::selected_obj
      set firstdate $::bdi_gui_reports::selected_firstdate
      
      set curselection [$::bdi_tools_reports::data_reports curselection]
      foreach select $curselection {

         set batch [lindex [$::bdi_tools_reports::data_reports get $select] 0]
         #gren_info "firstdate = $firstdate\n"
         #gren_info "batch = $batch\n"
         
         set dir [file join $bddconf(dirreports) $obj $firstdate]
         gren_info "Repertoire de travail = $dir \n"
      }
   }
   
   #------------------------------------------------------------
   ## Lancement de la GUI
   #  @return void
   #
   proc ::bdi_gui_reports::run { } {

      global audace caption color
      global conf bddconf 

      set widthlab 30
      set widthentry 30
      set ::bdi_gui_reports::fen .reports
      #--- Initialisation des parametres
      ::bdi_gui_reports::inittoconf

      #--- Geometry
      if { ! [ info exists conf(bddimages,geometry_reports) ] } {
         set conf(bddimages,geometry_reports) "+400+800"
      }
      set bddconf(geometry_reports) $conf(bddimages,geometry_reports)

      #--- Declare la GUI
      if { [ winfo exists $::bdi_gui_reports::fen ] } {
         wm withdraw $::bdi_gui_reports::fen
         wm deiconify $::bdi_gui_reports::fen
         focus $::bdi_gui_reports::fen.buttons.but_fermer
         return
      }

      #--- GUI
      toplevel $::bdi_gui_reports::fen -class Toplevel
      wm geometry $::bdi_gui_reports::fen $bddconf(geometry_reports)
      wm resizable $::bdi_gui_reports::fen 1 1
      wm title $::bdi_gui_reports::fen $caption(bddimages_go,reports)
      wm protocol $::bdi_gui_reports::fen WM_DELETE_WINDOW { ::bdi_gui_reports::fermer }

      set frm $::bdi_gui_reports::fen.appli
      frame $frm  -cursor arrow -relief groove
      pack $frm -in $::bdi_gui_reports::fen -anchor s -side top -expand yes -fill both -padx 10 -pady 5

     set buttons [frame $frm.buttons  -borderwidth 1 -relief groove]
     pack $buttons -in $frm -expand yes -fill both
     
     
         button $buttons.objects -state active -text "Objects" -relief "sunken" \
            -command "::bdi_gui_reports::switch_buttons_list"
         button $buttons.dates   -state active -text "Dates" -relief "raised" \
            -command "::bdi_gui_reports::switch_buttons_list"
         
         grid $buttons.objects $buttons.dates
     

     set doubletable [frame $frm.doubletable  -borderwidth 1 -relief groove]
     pack $doubletable -in $frm -expand yes -fill both


        set objects [frame $doubletable.objects  -borderwidth 1 -relief groove]
        pack $objects -in $doubletable -expand yes -fill both -side left

               set cols [list 0 "Objet"    left  \
                        ]

               # Table
               set ::bdi_tools_reports::data_objects $objects.table
               tablelist::tablelist $::bdi_tools_reports::data_objects \
                 -columns $cols \
                 -labelcommand tablelist::sortByColumn \
                 -xscrollcommand [ list $objects.hsb set ] \
                 -yscrollcommand [ list $objects.vsb set ] \
                 -selectmode extended \
                 -activestyle none \
                 -stripebackground "#e0e8f0" \
                 -showseparators 1

               # Scrollbar
               scrollbar $objects.hsb -orient horizontal -command [list $::bdi_tools_reports::data_objects xview]
               pack $objects.hsb -in $objects -side bottom -fill x
               scrollbar $objects.vsb -orient vertical -command [list $::bdi_tools_reports::data_objects yview]
               pack $objects.vsb -in $objects -side right -fill y 

               # Pack la Table
               pack $::bdi_tools_reports::data_objects -in $objects -expand yes -fill both

               # Binding
               bind $::bdi_tools_reports::data_objects <<ListboxSelect>> [ list ::bdi_gui_reports::cmdButton1Click_data_objects %W ]
               bind [$::bdi_tools_reports::data_objects bodypath] <ButtonPress-3> [ list tk_popup $objects.popupTbl %X %Y ]

               # tri des colonnes (ascii|asciinocase|command|dictionary|integer|real)
               #    Ascii
               foreach ncol [list "Objet"] {
                  set pcol [expr int ([lsearch $cols $ncol]/3)]
                  $::bdi_tools_reports::data_objects columnconfigure $pcol -sortmode ascii
               }

        set firstdate [frame $doubletable.firstdate  -borderwidth 1 -relief groove]
        pack $firstdate -in $doubletable -expand yes -fill both -side left

               set cols [list 0 "1ere Date"    left  \
                        ]

               # Table
               set ::bdi_tools_reports::data_firstdate $firstdate.table
               tablelist::tablelist $::bdi_tools_reports::data_firstdate \
                 -columns $cols \
                 -labelcommand tablelist::sortByColumn \
                 -xscrollcommand [ list $firstdate.hsb set ] \
                 -yscrollcommand [ list $firstdate.vsb set ] \
                 -selectmode extended \
                 -activestyle none \
                 -stripebackground "#e0e8f0" \
                 -showseparators 1

               # Scrollbar
               scrollbar $firstdate.hsb -orient horizontal -command [list $::bdi_tools_reports::data_firstdate xview]
               pack $firstdate.hsb -in $firstdate -side bottom -fill x
               scrollbar $firstdate.vsb -orient vertical -command [list $::bdi_tools_reports::data_firstdate yview]
               pack $firstdate.vsb -in $firstdate -side right -fill y 

               # Pack la Table
               pack $::bdi_tools_reports::data_firstdate -in $firstdate -expand yes -fill both

               # Binding
               bind $::bdi_tools_reports::data_firstdate <<ListboxSelect>> [ list ::bdi_gui_reports::cmdButton1Click_data_firstdate %W ]
               bind [$::bdi_tools_reports::data_firstdate bodypath] <ButtonPress-3> [ list tk_popup $firstdate.popupTbl %X %Y ]

               # tri des colonnes (ascii|asciinocase|command|dictionary|integer|real)
               #    Ascii
               foreach ncol [list "1ere Date"] {
                  set pcol [expr int ([lsearch $cols $ncol]/3)]
                  $::bdi_tools_reports::data_firstdate columnconfigure $pcol -sortmode ascii
               }



     set reports [frame $frm.reports  -borderwidth 1 -relief groove]
     pack $reports -in $frm -expand yes -fill both

            set cols [list 0 "Batch"       left \
                           0 "Astrom\n  TXT"  center \
                           0 "Astrom\n  XML"  center \
                           0 "Astrom\n  MPC"  center \
                           0 "Photom\n  TXT"  center \
                           0 "Photom\n  XML"  center \
                           0 "Soumis"      center \
                           0 "Commentaire" left \
                     ]

            # Table
            set ::bdi_tools_reports::data_reports $reports.table
            tablelist::tablelist $::bdi_tools_reports::data_reports \
              -columns $cols \
              -labelcommand tablelist::sortByColumn \
              -xscrollcommand [ list $reports.hsb set ] \
              -yscrollcommand [ list $reports.vsb set ] \
              -selectmode extended \
              -activestyle none \
              -stripebackground "#e0e8f0" \
              -showseparators 1

            # Scrollbar
            scrollbar $reports.hsb -orient horizontal -command [list $::bdi_tools_reports::data_reports xview]
            pack $reports.hsb -in $reports -side bottom -fill x
            scrollbar $reports.vsb -orient vertical -command [list $::bdi_tools_reports::data_reports yview]
            pack $reports.vsb -in $reports -side right -fill y 

            # Pack la Table
            pack $::bdi_tools_reports::data_reports -in $reports -expand yes -fill both

            # Popup
            menu $reports.popupTbl -title "Actions"

               $reports.popupTbl add command -label "Voir astrometrie TXT" \
                   -command "::bdi_gui_reports::affiche_rapport astrom,txt" 
               $reports.popupTbl add command -label "Voir astrometrie XML" \
                   -command "::bdi_gui_reports::affiche_rapport astrom,xml" 
               $reports.popupTbl add command -label "Voir astrometrie MPC" \
                   -command "::bdi_gui_reports::affiche_rapport astrom,mpc" 
               $reports.popupTbl add command -label "Voir photometrie TXT" \
                   -command "::bdi_gui_reports::affiche_rapport photom,txt" 
               $reports.popupTbl add command -label "Voir photometrie XML" \
                   -command "::bdi_gui_reports::affiche_rapport photom,xml" 

               $reports.popupTbl add separator
 
               $reports.popupTbl add command -label "Repertoire de travail" \
                   -command "::bdi_gui_reports::get_workdir_reports" 
               
               $reports.popupTbl add command -label "Effacer Entree" \
                   -command "::bdi_gui_reports::delete_reports" 
               
               $reports.popupTbl add separator

               $reports.popupTbl add command -label "Soumettre rapport MPC" \
                   -command "::bdi_gui_reports::submit_reports_mpc" 
               
               $reports.popupTbl add command -label "Soumettre rapport" \
                   -command "::bdi_gui_reports::submit_reports" 
               
               $reports.popupTbl add command -label "Flag de soumission" \
                   -command "::bdi_gui_reports::submit_flag" 
               
 
               
            # Binding
            bind $::bdi_tools_reports::data_reports <<ListboxSelect>> [ list ::bdi_gui_reports::cmdButton1Click_data_reports %W ]
            bind [$::bdi_tools_reports::data_reports bodypath] <ButtonPress-3> [ list tk_popup $reports.popupTbl %X %Y ]

            # tri des colonnes (ascii|asciinocase|command|dictionary|integer|real)
            #    Ascii
            foreach ncol [list "Batch"] {
               set pcol [expr int ([lsearch $cols $ncol]/3)]
               $::bdi_tools_reports::data_reports columnconfigure $pcol -sortmode ascii
            }
            #    Reel
            foreach ncol [list "Astrom\n  TXT" "Astrom\n  XML" "Astrom\n  MPC" "Photom\n  TXT" "Photom\n  XML"] {
               set pcol [expr int ([lsearch $cols $ncol]/3)]
               $::bdi_tools_reports::data_reports columnconfigure $pcol -sortmode ascii
            }


     # Develop
     set actions [frame $frm.actions  -borderwidth 1 -relief groove]
     pack $actions -in $frm -expand no -fill none


          button $actions.charge -text "Charge" -borderwidth 2 -takefocus 1 \
             -command "::bdi_gui_reports::charge"
          button $actions.ressource -text "Ressource les scripts" -borderwidth 2 -takefocus 1 \
             -command "::bddimages::ressource"
          button $actions.relance -text "Relance la GUI" -borderwidth 2 -takefocus 1 \
             -command "::bdi_gui_reports::relance"
          button $actions.clean -text "Efface le contenu de la console" -borderwidth 2 -takefocus 1 \
             -command "console::clear"


         grid $actions.charge $actions.ressource $actions.relance $actions.clean -sticky news


   }

   #------------------------------------------------------------
   ## gere la selection du type de tri, objects our dates 
   #  @return void
   #
   proc ::bdi_gui_reports::switch_buttons_list { } {
      set objects $::bdi_gui_reports::fen.appli.buttons.objects
      set dates   $::bdi_gui_reports::fen.appli.buttons.dates
      if {[$objects cget -relief] == "sunken"} {
         gren_info "choose dates\n"
         $objects configure -relief "raised"
         $dates   configure -relief "sunken"
      } else {
         gren_info "choose objects\n"
         $objects configure -relief "sunken"
         $dates   configure -relief "raised"
      }
      ::bdi_gui_reports::affiche_data
   }

   #------------------------------------------------------------
   ## Fenetre de clicouillage avant soumission par email
   #  @return void
   #
   proc ::bdi_gui_reports::build_window { batch file} {
   
      global audace caption color
      global conf bddconf 
      
      set ::bdi_gui_reports::mpc_to      "obs@cfa.harvard.edu;$conf(bddimages,astrometry,reports,mail)"
      set ::bdi_gui_reports::mpc_subject "\[OBSERVATION\]\[MPC\]$batch"
   
      gren_info "Soumission MPC\n"
      gren_info "to : $::bdi_gui_reports::mpc_to\n"
      gren_info "subject : $::bdi_gui_reports::mpc_subject\n"


      set widthlab 30
      set widthentry 30
      set ::bdi_gui_reports::fen_mpc .mpc_reports
      #--- Initialisation des parametres
      ::bdi_gui_reports::inittoconf

      #--- Geometry
      if { ! [ info exists conf(bddimages,geometry_reports) ] } {
         set conf(bddimages,geometry_reports) "+400+800"
      }
      set bddconf(geometry_reports) $conf(bddimages,geometry_reports)

      #--- Declare la GUI
      if { [ winfo exists $::bdi_gui_reports::fen_mpc ] } {
         wm withdraw $::bdi_gui_reports::fen_mpc
         wm deiconify $::bdi_gui_reports::fen_mpc
         focus $::bdi_gui_reports::fen_mpc.buttons.but_fermer
         return
      }

      #--- GUI
      toplevel $::bdi_gui_reports::fen_mpc -class Toplevel
      wm geometry $::bdi_gui_reports::fen_mpc $bddconf(geometry_reports)
      wm resizable $::bdi_gui_reports::fen_mpc 1 1
      wm title $::bdi_gui_reports::fen_mpc $caption(bddimages_go,reports)
      wm protocol $::bdi_gui_reports::fen_mpc WM_DELETE_WINDOW { destroy $::bdi_gui_reports::fen_mpc }

      set frm $::bdi_gui_reports::fen_mpc.appli
      frame $frm  -cursor arrow -relief groove
      pack $frm -in $::bdi_gui_reports::fen_mpc -anchor s -side top -expand yes -fill both -padx 10 -pady 5

      set mpc $frm
      set wdth 10
      
         #--- Onglet RAPPORT - MPC
         set block [frame $mpc.exped  -borderwidth 0 -cursor arrow -relief groove]
         pack $block  -in $mpc -side top -expand 0 -fill x -padx 2 -pady 5

               label  $block.lab -text "Destinataire : " -borderwidth 1 -width $wdth
               pack   $block.lab -side left -padx 3 -pady 1 -anchor w

               entry  $block.val -relief sunken -width 80 -textvariable ::bdi_gui_reports::mpc_to
               pack   $block.val -side left -padx 3 -pady 1 -anchor w

         set block [frame $mpc.subj  -borderwidth 0 -cursor arrow -relief groove]
         pack $block  -in $mpc -side top -expand 0 -fill x -padx 2 -pady 5

               label  $block.lab -text "Sujet : " -borderwidth 1 -width $wdth
               pack   $block.lab -side left -padx 3 -pady 1 -anchor w

               entry  $block.val -relief sunken -width 80 -textvariable ::bdi_gui_reports::mpc_subject
               pack   $block.val -side left -padx 3 -pady 1 -anchor w

         set ::bdi_gui_reports::rapport_mpc $mpc.text
         text $::bdi_gui_reports::rapport_mpc -height 30 -width 80 \
              -xscrollcommand "$::bdi_gui_reports::rapport_mpc.xscroll set" \
              -yscrollcommand "$::bdi_gui_reports::rapport_mpc.yscroll set" \
              -wrap none
         pack $::bdi_gui_reports::rapport_mpc -expand yes -fill both -padx 5 -pady 5

         scrollbar $::bdi_gui_reports::rapport_mpc.xscroll -orient horizontal -cursor arrow -command "$::bdi_gui_reports::rapport_mpc xview"
         pack $::bdi_gui_reports::rapport_mpc.xscroll -side bottom -fill x

         scrollbar $::bdi_gui_reports::rapport_mpc.yscroll -orient vertical -cursor arrow -command "$::bdi_gui_reports::rapport_mpc yview"
         pack $::bdi_gui_reports::rapport_mpc.yscroll -side right -fill y

         $::bdi_gui_reports::rapport_mpc delete 0.0 end

         # Lecture du fichier mpc
         set chan [open $file r]
         set strl ""
         while {[gets $chan line] >= 0} {
            $::bdi_gui_reports::rapport_mpc insert end "$line\n"
            # append strl "$line\n"
         }
         close $chan

         set block [frame $mpc.pied  -borderwidth 0 -cursor arrow -relief groove]
         pack $block  -in $mpc -side top -expand 0 -fill x -padx 2 -pady 5

               label  $block.lab -text "Veuillez copier et coller les champs ci-dessus apres avoir cree un nouveau mail dans votre messagerie" -borderwidth 1 -font $bddconf(font,arial_10_b)
               pack   $block.lab -side left -padx 3 -pady 1 -anchor w
   }
   

