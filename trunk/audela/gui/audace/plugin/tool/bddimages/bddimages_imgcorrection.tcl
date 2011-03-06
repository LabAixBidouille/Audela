#--------------------------------------------------
# source audace/plugin/tool/bddimages/bddimages_imgcorrection.tcl
#--------------------------------------------------
#
# Fichier        : bddimages_imgcorrection.tcl
# Description    : Environnement de recherche des images
#                  dans la base de donnees
# Auteur         : Frédéric Vachier
# Mise à jour $Id: bddimages_liste.tcl 6858 2011-03-06 14:19:15Z fredvachier $
#
#--------------------------------------------------
#
# - namespace bddimages_imgcorrection
#
#--------------------------------------------------
#
#   -- Fichiers source externe :
#
#  bddimages_imgcorrection.cap
#
#--------------------------------------------------

namespace eval bddimages_imgcorrection {

   global audace
   global bddconf








   proc ::bddimages_imgcorrection::get_info_img {  } {

      #recupere la liste des idbddimg
      set l [$::bddimages_recherche::This.frame6.result.tbl curselection ]
      set l [lsort -decreasing -integer $l]
      
      set cpt 0
      foreach i $listid {
         incr cpt
         set inf [$::bddimages_recherche::This.frame6.result.tbl get $i] 
         set id [lindex $inf 0]
         if {$cpt == 1} {
            set l "$id"
         } else {
            set l "$l,$id"
         }
      }
      if {$cpt == 0}  { return }

   }




#--------------------------------------------------
# run_create_sdark { this }
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

   proc ::bddimages_imgcorrection::run_create_sdark { this } {

      # Recuperation des informations des images selectionnees
      set info   [::bddimages_imgcorrection::get_info_img "dark"]
      set errmsg [::bddimages_imgcorrection::verif_info_img $info "dark"]
      if {$errmsg != ""}  { 
         ::console::affiche_erreur "ERROR: $errmsg\n"
         return
         }

      set texte "Images d entree \n"
      set texte "${texte}[lindex $info 0] \n"
      set texte "${texte}Image en sortie\n"
      set texte "${texte}[lindex $info 1]\n"
      
      # Affichage de la fenetre
      global This
      global entetelog
      set entetelog "Creation du Super Dark"
      set This $this

      if { [ winfo exists $This ] } {
         wm withdraw $This
         wm deiconify $This
         return
      }

      toplevel $This -class Toplevel
      wm title $This "Creation du Super Dark"
      wm positionfrom $This user
      wm sizefrom $This user

      set framecurrent $This.framename

      frame $framecurrent -relief groove
      pack configure $framecurrent -side top -fill both -expand 1 -padx 10 -pady 10

      # Frame qui va contenir le label "Type your password:" et une entrée pour le rentrer
      frame $framecurrent.title
      pack configure $framecurrent.title -side top -fill x
        label $framecurrent.title.e -text ${texte}
        pack configure $framecurrent.title.e -side left -anchor c

      # Frame qui va contenir les boutons Cancel et Ok
      frame $framecurrent.buttons
      pack configure $framecurrent.buttons -side top -fill x
        button $framecurrent.buttons.cancel -text Cancel -command "destroy $This"
        pack configure $framecurrent.buttons.cancel -side left
        button $framecurrent.buttons.ok -text Ok -command {::bddimages_imgcorrection::create_sdark; destroy $This}
        pack configure $framecurrent.buttons.ok -side right

      grab set $This
      tkwait window $This
}








}

