# source /srv/develop/audela/gui/audace/plugin/tool/bddimages/bddimages_calendrier.tcl
namespace eval bddimages_calendrier {

   global audace
   global bddconf



#--------------------------------------------------
# run { this }
#--------------------------------------------------
#
#    fonction  :
#        Creation de la fenetre
#
#    procedure externe :
#
#    variables en entree :
#        this = chemin de la fenetre
#
#    variables en sortie :
#
#--------------------------------------------------

   proc ::bddimages_calendrier::run { this } {

      variable This
      global entetelog

      set entetelog "Calendrier"
      set This $this
      createDialog 
      return
   }

#--------------------------------------------------
# fermer { }
#--------------------------------------------------
#
#    fonction  :
#        Fonction appellee lors de l'appui
#        sur le bouton 'Fermer'
#
#    procedure externe :
#
#    variables en entree :
#
#    variables en sortie :
#
#--------------------------------------------------
   proc ::bddimages_calendrier::fermer { } {
      variable This

      destroy $This
      return
   }



#--------------------------------------------------
#  createDialog { }
#--------------------------------------------------
#
#    fonction  :
#       Creation de l'interface graphique
#
#    procedure externe :
#
#    variables en entree :
#
#    variables en sortie :
#
#--------------------------------------------------


   proc ::bddimages_calendrier::createDialog {  } {

      variable This fb txt
      global audace
      global caption
      global color
      global conf
      global bddconf






      #---
      if { [ winfo exists $This ] } {
         wm withdraw $This
         wm deiconify $This
         return
      }

      #---
      toplevel $This -class Toplevel
      wm resizable $This 1 1
      wm title $This "Calendar"
      wm protocol $This WM_DELETE_WINDOW { ::bddimages_calendrier::fermer }



 set month [clock format [clock sec] -format %B]
 set year [clock format [clock sec] -format %Y]
 set jour [clock format [clock sec] -format %e]

 set lesmois { 0 Janvier Fevrier Mars Avril Mai Juin Juillet Aout Septembre Octobre Novembre Décembre }
 scan [clock format [clock scan "1 $month $year"] -format %m] %d decm





         #--- Cree un frame pour le nom de la liste
         set f $This.calendar
         set fb $f.f
         set txt $f.txt
         
         frame $fb
         pack $fb
         button $fb.bp -bd 1 -pady 0 -padx 2 -text "<<" -command "change -1"
         pack $fb.bp -side left
         label $fb.t -pady 2 -padx 5 -text "[lindex $lesmois $decm] $year"
         pack $fb.t  -side left
         button $fb.bs -bd 1 -pady 0 -padx 2 -text ">>" -command "change +1"
         pack $fb.bs -side left

         text $txt -height 8 -padx 0 -pady 5 -width 32 -bd 0 -bg #eeeeee -font {Helvetica 10 } -tabs {0.9c right}
         pack $txt
         $txt tag configure actuel -background yellow
         $txt insert end "\tDim\tLun\tMar\tMer\tJeu\tVen\tSam\n"
         affiche $jour $decm $year
         
         
         




#--- Lecture des info des images

      #--- Gestion du bouton
#      $audace(base).bddimages.fra5.but1 configure -relief raised -state normal

      #--- La fenetre est active
      focus $This

      #--- Raccourci qui donne le focus a la Console et positionne le curseur dans la ligne de commande
      bind $This <Key-F1> { $audace(console)::GiveFocus }

      #--- Mise a jour dynamique des couleurs
      ::confColor::applyColor $This
   }


























 proc numberofdays {month year} {
    if {$month==12} {set month 1; incr year}
    clock format [clock scan "[incr month]/1/$year  1 day ago"] -format %d
 }
 proc affiche { jour nbmois year } {

      variable fb txt

    $txt delete 2.0 end
    $txt insert end \n

    set yeekday [clock format [clock scan "$nbmois/1/$year"] -format %w]
    $txt insert end [string repeat "\t" $yeekday]

    set maxd [numberofdays $nbmois $year]
    for {set d 1} {$d <= $maxd} {incr d} {
      $txt insert end \t
      if { $jour==$d } { set tag actuel} else { set tag ""}
      $txt insert end [format %2d $d] $tag
      if {[incr yeekday]>6} { $txt insert end \n; set yeekday 0}
      }
 }
 proc change { sens  } {
      variable fb txt
    global jour decm year lesmois

    incr decm $sens;
    if { $decm<=0 } { set decm 12; incr year -1}
    if { $decm>12 } { set decm 1; incr year }
    affiche $jour $decm $year
    $fb.t configure -text  "[lindex $lesmois $decm] $year"
    }
 #--------------------------------------------
}
