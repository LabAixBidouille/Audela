   proc ::bdi_binast_gui::box { img_list } {

      global audace
      global bddconf

      ::bdi_binast_tools::charge_list $img_list
      ::bdi_binast_gui::inittoconf


      #--- Creation de la fenetre
      set ::gui_cdl_withwcs::fen .cdlwcs
      if { [winfo exists $::gui_cdl_withwcs::fen] } {
         wm withdraw $::gui_cdl_withwcs::fen
         wm deiconify $::gui_cdl_withwcs::fen
         focus $::gui_cdl_withwcs::fen
         return
      }
      toplevel $::gui_cdl_withwcs::fen -class Toplevel
      set posx_config [ lindex [ split [ wm geometry $::gui_cdl_withwcs::fen ] "+" ] 1 ]
      set posy_config [ lindex [ split [ wm geometry $::gui_cdl_withwcs::fen ] "+" ] 2 ]
      wm geometry $::gui_cdl_withwcs::fen +[ expr $posx_config + 165 ]+[ expr $posy_config + 55 ]
      wm resizable $::gui_cdl_withwcs::fen 1 1
      wm title $::gui_cdl_withwcs::fen "Creation du WCS"
      wm protocol $::gui_cdl_withwcs::fen WM_DELETE_WINDOW "destroy $::gui_cdl_withwcs::fen"
      set frm $::gui_cdl_withwcs::fen.frm_cdlwcs





      #--- Cree un frame general
      frame $frm -borderwidth 0 -cursor arrow -relief groove
      pack $frm -in $::gui_cdl_withwcs::fen -anchor s -side top -expand 0 -fill x -padx 10 -pady 5


#--- Setup

        #--- Nom e l'Objet
        set nomobj [frame $frm.nomobj -borderwidth 0 -cursor arrow -relief groove]
        pack $nomobj -in $frm -anchor s -side top -expand 0 -fill x -padx 5 -pady 5
             label $nomobj.lab -text "Nom de l'objet"
             pack $nomobj.lab -in $nomobj -side left -padx 5 -pady 0
             entry $nomobj.val -relief sunken -textvariable ::tools_cdl::nomobj -width 25 \
             -validate all -validatecommand { ::tkutil::validateString %W %V %P %s wordchar1 0 100 }
             pack $nomobj.val -in $nomobj -side left -pady 1 -anchor w

        #--- Repertoire des resultats
        set savedir [frame $frm.savedir -borderwidth 0 -cursor arrow -relief groove]
        pack $savedir -in $frm -anchor s -side top -expand 0 -fill x -padx 5 -pady 5
             label $savedir.lab -text "Repertoire de sauvegarde"
             pack $savedir.lab -in $savedir -side left -padx 5 -pady 0
             entry $savedir.val -relief sunken -textvariable ::tools_cdl::savedir -width 50
             pack $savedir.val -in $savedir -side left -pady 1 -anchor w

        #--- Cree un frame pour afficher movingobject
        set move [frame $frm.move -borderwidth 0 -cursor arrow -relief groove]
        pack $move -in $frm -anchor s -side top -expand 0 -fill x -padx 10 -pady 5

             #--- Cree un checkbutton
             checkbutton $move.check -highlightthickness 0 -text "Objet en mouvement" -variable ::tools_cdl::movingobject
             pack $move.check -in $move -side left -padx 5 -pady 0
  
        #--- Nb points pour deplacement
        set nbporbit [frame $frm.nbporbit -borderwidth 0 -cursor arrow -relief groove]
        pack $nbporbit -in $frm -anchor s -side top -expand 0 -fill x -padx 10 -pady 5
             label $nbporbit.lab -text "Nb points pour deplacement"
             pack $nbporbit.lab -in $nbporbit -side left -padx 5 -pady 0
             spinbox $nbporbit.val -values [ list 2 3 5 9] -command "" -width 3 -textvariable ::tools_cdl::nbporbit
             $nbporbit.val set 5
             pack  $nbporbit.val -in $nbporbit -side left -anchor w

        #--- Cree un frame pour afficher bestdelta
        set photom [frame $frm.photom -borderwidth 0 -cursor arrow -relief groove]
        pack $photom -in $frm -anchor s -side top -expand 0 -fill x -padx 10 -pady 5
             checkbutton $photom.check -highlightthickness 0 \
                        -text "Recherche meilleur delta (min/max)" -variable ::tools_cdl::bestdelta
             pack $photom.check -in $photom -side left -padx 5 -pady 0
             spinbox $photom.min -from 1 -to 100 -increment 1 -command "" -width 3  \
                   -textvariable ::tools_cdl::deltamin
             pack  $photom.min -in $photom -side left -anchor w
             spinbox $photom.max -from 1 -to 100 -increment 1 -command "" -width 3  \
                   -textvariable ::tools_cdl::deltamax
             pack  $photom.max -in $photom -side left -anchor w
  
        #--- Niveau de saturation (ADU)
        set saturation [frame $frm.saturation -borderwidth 0 -cursor arrow -relief groove]
        pack $saturation -in $frm -anchor s -side top -expand 0 -fill x -padx 5 -pady 5
             label $saturation.lab -text "Niveau de saturation (ADU)"
             pack $saturation.lab -in $saturation -side left -padx 5 -pady 0
             entry $saturation.val -relief sunken -textvariable ::tools_cdl::saturation -width 6
             pack $saturation.val -in $saturation -side left -pady 1 -anchor w

        #--- Nb etoiles de reference
        set nbstars [frame $frm.nbstars -borderwidth 0 -cursor arrow -relief groove]
        set sources [frame $frm.sources -borderwidth 0 -cursor arrow -relief groove]
        pack $nbstars -in $frm -anchor s -side top -expand 0 -fill x -padx 10 -pady 5
             label $nbstars.lab -text "Nb d etoiles de reference"
             pack $nbstars.lab -in $nbstars -side left -padx 5 -pady 0
             spinbox $nbstars.val -from 1 -to 100 -increment 1 \
                      -command "::gui_cdl_withwcs::change_refstars $sources " \
                      -width 3 -textvariable ::gui_cdl_withwcs::nbstars
             pack  $nbstars.val -in $nbstars -side left -anchor w

        #--- Cree un frame pour afficher movingobject
        set stoperreur [frame $frm.stoperreur -borderwidth 0 -cursor arrow -relief groove]
        pack $stoperreur -in $frm -anchor s -side top -expand 0 -fill x -padx 10 -pady 5

             #--- Cree un checkbutton
             checkbutton $stoperreur.check -highlightthickness 0 -text "Arret en cas d'erreur" \
                      -variable ::gui_cdl_withwcs::stoperreur
             pack $stoperreur.check -in $stoperreur -side left -padx 5 -pady 0

        #--- Cree un frame pour afficher movingobject
        set uncosm [frame $frm.uncosm -borderwidth 0 -cursor arrow -relief groove]
        pack $uncosm -in $frm -anchor s -side top -expand 0 -fill x -padx 10 -pady 5

             #--- Cree un checkbutton
             checkbutton $uncosm.check -highlightthickness 0 -text "Uncosmic" \
                      -command "::gui_cdl_withwcs::change_uncosm " \
                      -variable ::tools_cdl::uncosm
             pack $uncosm.check -in $uncosm -side left -padx 5 -pady 0
             entry $uncosm.p1 -relief sunken -textvariable ::tools_cdl::uncosm_param1 -width 6
             pack $uncosm.p1 -in $uncosm -side left -pady 1 -anchor w
             entry $uncosm.p2 -relief sunken -textvariable ::tools_cdl::uncosm_param2 -width 6
             pack $uncosm.p2 -in $uncosm -side left -pady 1 -anchor w


        #--- Cree un frame pour afficher la mag de la premiere etoile de reference
        set firstrefstar [frame $frm.firstrefstar -borderwidth 0 -cursor arrow -relief groove]
        pack $firstrefstar -in $frm -anchor s -side top -expand 0 -fill x -padx 10 -pady 5

             #--- Cree un checkbutton
             label $firstrefstar.lab -text "Magnitude de la premiere etoile de reference : "
             pack $firstrefstar.lab -in $firstrefstar -side left -padx 5 -pady 0
             entry $firstrefstar.val -relief sunken -textvariable ::tools_cdl::firstmagref -width 6
             pack $firstrefstar.val -in $firstrefstar -side left -pady 1 -anchor w

        #--- Cree un frame pour afficher l acces direct a l image
        set directaccess [frame $frm.directaccess -borderwidth 0 -cursor arrow -relief groove]
        pack $directaccess -in $frm -anchor s -side top -expand 0 -fill x -padx 10 -pady 5

             #--- Cree un checkbutton
             label $directaccess.lab -text "Access direct a l image : "
             pack $directaccess.lab -in $directaccess -side left -padx 5 -pady 0
             entry $directaccess.val -relief sunken \
                -textvariable ::gui_cdl_withwcs::directaccess -width 6 \
                -justify center
             pack $directaccess.val -in $directaccess -side left -pady 1 -anchor w
             button $directaccess.go -text "Go" -borderwidth 1 -takefocus 1 \
                -command "::gui_cdl_withwcs::go $sources" 
             pack $directaccess.go -side left -anchor e \
                -padx 2 -pady 2 -ipadx 2 -ipady 2 -expand 0




#--- Boutons





        #--- Cree un frame pour afficher les boutons
        set bouton [frame $frm.bouton -borderwidth 0 -cursor arrow -relief groove]
        pack $bouton -in $frm -anchor s -side top -expand 0 -fill x -padx 10 -pady 5

             button $bouton.back -text "Precedent" -borderwidth 2 -takefocus 1 \
                -command "::gui_cdl_withwcs::back $sources" -state $::gui_cdl_withwcs::stateback
             pack $bouton.back -side left -anchor e \
                -padx 5 -pady 5 -ipadx 5 -ipady 5 -expand 0

             button $bouton.next -text "Suivant" -borderwidth 2 -takefocus 1 \
                -command "::gui_cdl_withwcs::next $sources" -state $::gui_cdl_withwcs::statenext
             pack $bouton.next -side left -anchor e \
                -padx 5 -pady 5 -ipadx 5 -ipady 5 -expand 0

             label $bouton.lab -text "Par bloc de :"
             pack $bouton.lab -in $bouton -side left
             entry $bouton.block -relief sunken -textvariable ::gui_cdl_withwcs::block -borderwidth 2 -width 6 -justify center
             pack $bouton.block -in $bouton -side left -padx 5 -pady 5 -ipadx 5 -ipady 5 -expand 0 -anchor w



#--- Info etat avancement

 
 
 
 
        #--- Cree un frame pour afficher info image
        set infoimage [frame $frm.infoimage -borderwidth 0 -cursor arrow -relief groove]
        pack $infoimage -in $frm -anchor s -side top -expand 0 -fill x -padx 10 -pady 5

            #--- Cree un label pour le Nom de l image
            label $infoimage.nomimage -text $::tools_cdl::current_image_name
            pack $infoimage.nomimage -in $infoimage -side top -padx 3 -pady 3

            #--- Cree un label pour la date de l image
            label $infoimage.dateimage -text $::tools_cdl::current_image_date
            pack $infoimage.dateimage -in $infoimage -side top -padx 3 -pady 3

            #--- Cree un label pour la date de l image
            label $infoimage.stimage -text "$::tools_cdl::id_current_image / $::tools_cdl::nb_img_list"
            pack $infoimage.stimage -in $infoimage -side top -padx 3 -pady 3






#--- Sources


        #--- Sources
        pack $sources -in $frm -anchor s -side top 
           set name [frame $sources.name -borderwidth 0 -cursor arrow -relief groove]
           pack $name -in $sources -anchor s -side left 
           set ra [frame $sources.ra -borderwidth 0 -cursor arrow -relief groove]
           pack $ra -in $sources -anchor s -side left 
           set dec [frame $sources.dec -borderwidth 0 -cursor arrow -relief groove]
           pack $dec -in $sources -anchor s -side left 
           set mag [frame $sources.mag -borderwidth 0 -cursor arrow -relief groove]
           pack $mag -in $sources -anchor s -side left 
           set stdev [frame $sources.stdev -borderwidth 0 -cursor arrow -relief groove]
           pack $stdev -in $sources -anchor s -side left 
           set delta [frame $sources.delta -borderwidth 0 -cursor arrow -relief groove]
           pack $delta -in $sources -anchor s -side left 
           set select [frame $sources.select -borderwidth 0 -cursor arrow -relief groove]
           pack $select -in $sources -anchor s -side left 


        #--- Objet

            label $name.obj    -text "Objet :"
            entry $ra.obj      -relief sunken -width 11
            entry $dec.obj     -relief sunken -width 11
            label $mag.obj     -width 9 
            label $stdev.obj   -width 9 
            spinbox $delta.obj -from 1 -to 100 -increment 1 -command "" -width 3 \
                   -command "::gui_cdl_withwcs::mesure_tout $sources" \
                   -textvariable ::tools_cdl::tabsource(obj,delta)
            button $select.obj -text "Select" -command "::gui_cdl_withwcs::select_source $sources obj" -height 1

            pack $name.obj   -in $name   -side top -pady 2 -ipady 2
            pack $ra.obj     -in $ra     -side top -pady 2 -ipady 2
            pack $dec.obj    -in $dec    -side top -pady 2 -ipady 2
            pack $mag.obj    -in $mag    -side top -pady 2 -ipady 2
            pack $stdev.obj  -in $stdev  -side top -pady 2 -ipady 2
            pack $delta.obj  -in $delta  -side top -pady 2 -ipady 2
            pack $select.obj -in $select -side top  

            label $name.star1    -text "Star1 :"
            entry $ra.star1      -relief sunken -width 11
            entry $dec.star1     -relief sunken -width 11
            label $mag.star1     -width 9 -textvariable ::tools_cdl::firstmagref
            label $stdev.star1   -width 9 
            spinbox $delta.star1 -from 1 -to 100 -increment 1 -width 3 \
                   -command "::gui_cdl_withwcs::mesure_tout $sources" \
                   -textvariable ::tools_cdl::tabsource(star1,delta)
            button $select.star1 -text "Select" -command "::gui_cdl_withwcs::select_source $sources star1"

            pack $name.star1   -in $name   -side top -pady 2 -ipady 2
            pack $ra.star1     -in $ra     -side top -pady 2 -ipady 2
            pack $dec.star1    -in $dec    -side top -pady 2 -ipady 2
            pack $mag.star1    -in $mag    -side top -pady 2 -ipady 2
            pack $stdev.star1  -in $stdev  -side top -pady 2 -ipady 2
            pack $delta.star1  -in $delta  -side top -pady 2 -ipady 2
            pack $select.star1 -in $select -side top    







#--- Boutons Final





        #--- Cree un frame pour afficher les boutons finaux
        set boutonfinal [frame $frm.boutonfinal -borderwidth 0 -cursor arrow -relief groove]
        pack $boutonfinal -in $frm -anchor s -side top -expand 0 -fill x -padx 10 -pady 5

             button $boutonfinal.fermer -text "Fermer" -borderwidth 2 -takefocus 1 \
                -command ::gui_cdl_withwcs::fermer \
                -state normal
             pack $boutonfinal.fermer -side right -anchor e \
                -padx 5 -pady 5 -ipadx 5 -ipady 5 -expand 0


             button $boutonfinal.enregistrer -text "Enregistrer" -borderwidth 2 -takefocus 1 \
                -command "" -state $::gui_cdl_withwcs::enregistrer
             pack $boutonfinal.enregistrer -side right -anchor e \
                -padx 5 -pady 5 -ipadx 5 -ipady 5 -expand 0

             button $boutonfinal.analyser -text "Analyser" -borderwidth 2 -takefocus 1 \
                -command "" -state $::gui_cdl_withwcs::analyser
             pack $boutonfinal.analyser -side right -anchor e \
                -padx 5 -pady 5 -ipadx 5 -ipady 5 -expand 0

             button $boutonfinal.stat_mag -text "Stat Mag" -borderwidth 2 -takefocus 1 \
                -command ::gui_cdl_withwcs::stat_mag2
             pack $boutonfinal.stat_mag -side right -anchor e \
                -padx 5 -pady 5 -ipadx 5 -ipady 5 -expand 0



   }
   

   

