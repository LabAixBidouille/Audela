#
# Fichier : rmtctrlccd.tcl
# Description : Script pour le controle de la camera CCD
# Auteur : Raymond ZACHANTKE
# Mise a jour $Id: rmtctrlccd.tcl,v 1.1 2010-01-30 14:47:56 robertdelmas Exp $
#

   proc fillCCDPanel {} {
      global panneau caption
      variable This

      set panneau(remotectrl,exptime)   "2"
      set panneau(remotectrl,secondes)  "$caption(remotectrl,seconde)"
      set panneau(remotectrl,bin)       "$caption(remotectrl,binning)"
      set panneau(remotectrl,choix_bin) "1x1 2x2 4x4"
      set panneau(remotectrl,binning)   "2x2"

      #--- Frame invisible pour le temps de pose
      frame $This.fra6.fra1

         #--- Entry pour l'objet a entrer
         entry $This.fra6.fra1.ent1 -textvariable panneau(remotectrl,exptime) \
            -relief groove -width 5 -justify center
         pack $This.fra6.fra1.ent1 -in $This.fra6.fra1 -side left -fill none -padx 4 -pady 2

         #--- Label pour les secondes
         label $This.fra6.fra1.lab1 -text $panneau(remotectrl,secondes) -relief flat
         pack $This.fra6.fra1.lab1 -in $This.fra6.fra1 -side left -fill none -padx 1 -pady 1

         pack   $This.fra6.fra1 -in $This.fra6 -side top -fill x

         #--- Menu pour binning
         frame $This.fra6.optionmenu1 -borderwidth 0 -relief groove
         menubutton $This.fra6.optionmenu1.but_bin -text $panneau(remotectrl,bin) \
            -menu $This.fra6.optionmenu1.but_bin.menu -relief raised
         pack $This.fra6.optionmenu1.but_bin -in $This.fra6.optionmenu1 -side left -fill none
         set m [ menu $This.fra6.optionmenu1.but_bin.menu -tearoff 0 ]
         foreach valbin $panneau(remotectrl,choix_bin) {
            $m add radiobutton -label "$valbin" \
               -indicatoron "1" \
               -value "$valbin" \
               -variable panneau(remotectrl,binning) \
               -command { }
         }
         entry $This.fra6.optionmenu1.lab_bin -width 3 -relief groove \
            -textvariable panneau(remotectrl,binning) -justify center -state disabled
         pack $This.fra6.optionmenu1.lab_bin -in $This.fra6.optionmenu1 -side left -fill both -expand true
      pack $This.fra6.optionmenu1 -anchor n -fill x -expand 0 -pady 2
   }

   proc cmdGo {} {
      global audace caption conf panneau
      variable This

      #--- Debut modif reseau
      if {[eval "send \{::cam::list\}"]!=""} {
         #--- Fin modif reseau
         $This.fra6.but1 configure -relief groove -state disabled
         update
         if { ( $panneau(remotectrl,getra) == "$caption(remotectrl,camera)" ) && \
            ( $panneau(remotectrl,getdec) == "$caption(remotectrl,non_connectee)" ) } {
            set panneau(remotectrl,getra)  ""
            set panneau(remotectrl,getdec) ""
            $This.fra3.ent1 configure -text $panneau(remotectrl,getra)
            $This.fra3.ent2 configure -text $panneau(remotectrl,getdec)
            update
         }

         #--- Temps de pose
         set exptime $panneau(remotectrl,exptime)

         #--- Facteur de binning
         set bin 4
         if { $panneau(remotectrl,binning) == "4x4" } { set bin 4 }
         if { $panneau(remotectrl,binning) == "2x2" } { set bin 2 }
         if { $panneau(remotectrl,binning) == "1x1" } { set bin 1 }

         #--- Initialisation du fenetrage
         catch {
            #--- Debut modif reseau
            set message "send \{set n1n2 \[cam\$audace(camNo) nbcells\]\}"
            set n1n2 [eval $message]
            set message "send \{cam\$audace(camNo) window \[list 1 1 \[lindex \$n1n2 0\] \[lindex \$n1n2 1\] ]\}"
            eval $message
            #--- Fin modif reseau
         }

         #--- Alarme sonore de fin de pose
         set message "send \{::camera::alarmeSonore $exptime\}"
         eval $message

         #--- Appel a la fonction d'acquisition
         set message "send \{acq $exptime $bin\}"
         eval $message

         #--- Extension par defaut
         set ext $conf(extension,defaut)
         #---
         if {$panneau(remotectrl,path_img)>1} {

            #--- Transfert par protocole ftp
            set message "send \{saveima \"\$audace(rep_images)/temp$ext\" \}"
            eval $message

            transferFTP "$audace(rep_images)/temp$ext"

         } else {
            #--- Tranfert par fichier dans un dossier partagé
            set message "send \{saveima \"\$panneau(remotectrl,path_img)/temp$ext\" \}"
            eval $message
            loadima "$panneau(remotectrl,path_img)/temp$ext"
            catch { file delete "$panneau(remotectrl,path_img)/temp$ext" }
         }

         #--- Graphisme panneau
         $This.fra1.but configure -text "$panneau(remotectrl,aide1)\n$panneau(remotectrl,titre)"
         $This.fra6.but1 configure -relief raised -state normal
         update

      } else {
         set panneau(remotectrl,getra)  "$caption(remotectrl,camera)"
         set panneau(remotectrl,getdec) "$caption(remotectrl,non_connectee)"
         $This.fra3.ent1 configure -text $panneau(remotectrl,getra)
         $This.fra3.ent2 configure -text $panneau(remotectrl,getdec)
         update
      }
   }

