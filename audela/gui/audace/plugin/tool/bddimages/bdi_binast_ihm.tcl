   proc ::bdi_binast_gui::box { img_list } {

      global audace
      global bddconf

      ::bdi_binast_tools::charge_list $img_list
      ::bdi_binast_gui::inittoconf


      #--- Creation de la fenetre
      set ::bdi_binast_gui::fen .cdlwcs
      if { [winfo exists $::bdi_binast_gui::fen] } {
         wm withdraw $::bdi_binast_gui::fen
         wm deiconify $::bdi_binast_gui::fen
         focus $::bdi_binast_gui::fen
         return
      }
      toplevel $::bdi_binast_gui::fen -class Toplevel
      set posx_config [ lindex [ split [ wm geometry $::bdi_binast_gui::fen ] "+" ] 1 ]
      set posy_config [ lindex [ split [ wm geometry $::bdi_binast_gui::fen ] "+" ] 2 ]
      wm geometry $::bdi_binast_gui::fen +[ expr $posx_config + 165 ]+[ expr $posy_config + 55 ]
      wm resizable $::bdi_binast_gui::fen 1 1
      wm title $::bdi_binast_gui::fen "Creation du WCS"
      wm protocol $::bdi_binast_gui::fen WM_DELETE_WINDOW "destroy $::bdi_binast_gui::fen"
      set frm $::bdi_binast_gui::fen.frm_cdlwcs





      #--- Cree un frame general
      frame $frm -borderwidth 0 -cursor arrow -relief groove
      pack $frm -in $::bdi_binast_gui::fen -anchor s -side top -expand 0 -fill x -padx 10 -pady 5


#--- Setup

        #--- Nom e l'Objet
        set nomobj [frame $frm.nomobj -borderwidth 0 -cursor arrow -relief groove]
        pack $nomobj -in $frm -anchor s -side top -expand 0 -fill x -padx 5 -pady 5
             label $nomobj.lab -text "Nom de l'objet"
             pack $nomobj.lab -in $nomobj -side left -padx 5 -pady 0
             entry $nomobj.val -relief sunken -textvariable ::bdi_binast_tools::nomobj -width 25 \
             -validate all -validatecommand { ::tkutil::validateString %W %V %P %s wordchar1 0 100 }
             pack $nomobj.val -in $nomobj -side left -pady 1 -anchor w

        #--- Repertoire des resultats
        set savedir [frame $frm.savedir -borderwidth 0 -cursor arrow -relief groove]
        pack $savedir -in $frm -anchor s -side top -expand 0 -fill x -padx 5 -pady 5
             label $savedir.lab -text "Repertoire de sauvegarde"
             pack $savedir.lab -in $savedir -side left -padx 5 -pady 0
             entry $savedir.val -relief sunken -textvariable ::bdi_binast_tools::savedir -width 50
             pack $savedir.val -in $savedir -side left -pady 1 -anchor w


  

        #--- Nb etoiles de reference
        set nbstars [frame $frm.nbstars -borderwidth 0 -cursor arrow -relief groove]
        set sources [frame $frm.sources -borderwidth 0 -cursor arrow -relief groove]
        pack $nbstars -in $frm -anchor s -side top -expand 0 -fill x -padx 10 -pady 5
             label $nbstars.lab -text "Nb d etoiles de reference"
             pack $nbstars.lab -in $nbstars -side left -padx 5 -pady 0
             spinbox $nbstars.val -from 1 -to 100 -increment 1 \
                      -command "::bdi_binast_gui::change_refstars $sources " \
                      -width 3 -textvariable ::bdi_binast_gui::nbstars
             pack  $nbstars.val -in $nbstars -side left -anchor w

        #--- Cree un frame pour afficher movingobject
        set uncosm [frame $frm.uncosm -borderwidth 0 -cursor arrow -relief groove]
        pack $uncosm -in $frm -anchor s -side top -expand 0 -fill x -padx 10 -pady 5

             #--- Cree un checkbutton
             checkbutton $uncosm.check -highlightthickness 0 -text "Uncosmic" \
                      -command "::bdi_binast_gui::change_uncosm " \
                      -variable ::bdi_binast_tools::uncosm
             pack $uncosm.check -in $uncosm -side left -padx 5 -pady 0
             entry $uncosm.p1 -relief sunken -textvariable ::bdi_binast_tools::uncosm_param1 -width 6
             pack $uncosm.p1 -in $uncosm -side left -pady 1 -anchor w
             entry $uncosm.p2 -relief sunken -textvariable ::bdi_binast_tools::uncosm_param2 -width 6
             pack $uncosm.p2 -in $uncosm -side left -pady 1 -anchor w


        #--- Cree un frame pour afficher la mag de la premiere etoile de reference
        set firstrefstar [frame $frm.firstrefstar -borderwidth 0 -cursor arrow -relief groove]
        pack $firstrefstar -in $frm -anchor s -side top -expand 0 -fill x -padx 10 -pady 5

             #--- Cree un checkbutton
             label $firstrefstar.lab -text "Magnitude de la premiere etoile de reference : "
             pack $firstrefstar.lab -in $firstrefstar -side left -padx 5 -pady 0
             entry $firstrefstar.val -relief sunken -textvariable ::bdi_binast_tools::firstmagref -width 6
             pack $firstrefstar.val -in $firstrefstar -side left -pady 1 -anchor w

        #--- Cree un frame pour afficher l acces direct a l image
        set directaccess [frame $frm.directaccess -borderwidth 0 -cursor arrow -relief groove]
        pack $directaccess -in $frm -anchor s -side top -expand 0 -fill x -padx 10 -pady 5

             #--- Cree un checkbutton
             label $directaccess.lab -text "Access direct a l image : "
             pack $directaccess.lab -in $directaccess -side left -padx 5 -pady 0
             entry $directaccess.val -relief sunken \
                -textvariable ::bdi_binast_gui::directaccess -width 6 \
                -justify center
             pack $directaccess.val -in $directaccess -side left -pady 1 -anchor w
             button $directaccess.go -text "Go" -borderwidth 1 -takefocus 1 \
                -command "::bdi_binast_gui::go $sources" 
             pack $directaccess.go -side left -anchor e \
                -padx 2 -pady 2 -ipadx 2 -ipady 2 -expand 0




#--- Boutons





        #--- Cree un frame pour afficher les boutons
        set bouton [frame $frm.bouton -borderwidth 0 -cursor arrow -relief groove]
        pack $bouton -in $frm -anchor s -side top -expand 0 -fill x -padx 10 -pady 5

             button $bouton.back -text "Precedent" -borderwidth 2 -takefocus 1 \
                -command "::bdi_binast_gui::back $sources" -state $::bdi_binast_gui::stateback
             pack $bouton.back -side left -anchor e \
                -padx 5 -pady 5 -ipadx 5 -ipady 5 -expand 0

             button $bouton.next -text "Suivant" -borderwidth 2 -takefocus 1 \
                -command "::bdi_binast_gui::next $sources" -state $::bdi_binast_gui::statenext
             pack $bouton.next -side left -anchor e \
                -padx 5 -pady 5 -ipadx 5 -ipady 5 -expand 0

             label $bouton.lab -text "Par bloc de :"
             pack $bouton.lab -in $bouton -side left
             entry $bouton.block -relief sunken -textvariable ::bdi_binast_gui::block -borderwidth 2 -width 6 -justify center
             pack $bouton.block -in $bouton -side left -padx 5 -pady 5 -ipadx 5 -ipady 5 -expand 0 -anchor w



#--- Info etat avancement

 
 
 
 
        #--- Cree un frame pour afficher info image
        set infoimage [frame $frm.infoimage -borderwidth 0 -cursor arrow -relief groove]
        pack $infoimage -in $frm -anchor s -side top -expand 0 -fill x -padx 10 -pady 5

            #--- Cree un label pour le Nom de l image
            label $infoimage.nomimage -text $::bdi_binast_tools::current_image_name
            pack $infoimage.nomimage -in $infoimage -side top -padx 3 -pady 3

            #--- Cree un label pour la date de l image
            label $infoimage.dateimage -text $::bdi_binast_tools::current_image_date
            pack $infoimage.dateimage -in $infoimage -side top -padx 3 -pady 3

            #--- Cree un label pour la date de l image
            label $infoimage.stimage -text "$::bdi_binast_tools::id_current_image / $::bdi_binast_tools::nb_img_list"
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
                   -command "::bdi_binast_gui::mesure_tout $sources" \
                   -textvariable ::bdi_binast_tools::tabsource(obj,delta)
            button $select.obj -text "Select" -command "::bdi_binast_gui::select_source $sources obj" -height 1

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
            label $mag.star1     -width 9 -textvariable ::bdi_binast_tools::firstmagref
            label $stdev.star1   -width 9 
            spinbox $delta.star1 -from 1 -to 100 -increment 1 -width 3 \
                   -command "::bdi_binast_gui::mesure_tout $sources" \
                   -textvariable ::bdi_binast_tools::tabsource(star1,delta)
            button $select.star1 -text "Select" -command "::bdi_binast_gui::select_source $sources star1"

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
                -command ::bdi_binast_gui::fermer \
                -state normal
             pack $boutonfinal.fermer -side right -anchor e \
                -padx 5 -pady 5 -ipadx 5 -ipady 5 -expand 0


             button $boutonfinal.enregistrer -text "Enregistrer" -borderwidth 2 -takefocus 1 \
                -command "" -state $::bdi_binast_gui::enregistrer
             pack $boutonfinal.enregistrer -side right -anchor e \
                -padx 5 -pady 5 -ipadx 5 -ipady 5 -expand 0

             button $boutonfinal.analyser -text "Analyser" -borderwidth 2 -takefocus 1 \
                -command "" -state $::bdi_binast_gui::analyser
             pack $boutonfinal.analyser -side right -anchor e \
                -padx 5 -pady 5 -ipadx 5 -ipady 5 -expand 0

             button $boutonfinal.stat_mag -text "Stat Mag" -borderwidth 2 -takefocus 1 \
                -command ::bdi_binast_gui::stat_mag2
             pack $boutonfinal.stat_mag -side right -anchor e \
                -padx 5 -pady 5 -ipadx 5 -ipady 5 -expand 0



   }
   

   

