   #------------------------ fonction de focalisation -------------------------

   #---------------------------------------------------------------------------
   #  refreshFocGraph : rafraichit le graphique de la focalisation
   #  Parametres : N° de la visu et du buf associe
   #---------------------------------------------------------------------------
   proc refreshFocGraph { visuNo bufNo } {
      variable private

      set racine ::V_${visuNo}_
      set graph $private($visuNo,graph)

      lassign [ buf$bufNo stat ] nihil nihil maxi nihil nihil nihil nihil fond contraste

      ${racine}intensite append [ expr { $maxi - $fond } ]
      ${racine}contrast append [ expr { -1.*$contraste } ]

      set box [ ::confVisu::getBox $::audace(visuNo) ]
      if { $box  == "" } {
         set naxis1 [ lindex [ buf$bufNo getkwd NAXIS1 ] 1 ]
         set naxis2 [ lindex [ buf$bufNo getkwd NAXIS2 ] 1 ]
         #--   par defaut de selection, la boite a les dimensions de l'image
         set box [ list 1 1 $naxis1  $naxis1 ]
      }

      lassign [ buf$bufNo fwhm $box ] fwhm_x fwhm_y

      set fwhm [ expr { ( $fwhm_x+$fwhm_y )/2 } ]

      ${racine}fwhm append $fwhm
      ${racine}ratio_x_y append [ expr { $fwhm_x/$fwhm_y } ]

      #--   configure l'axe des ordonnees de FWHM
      if { $fwhm > 10 } {
         set max {}
      } elseif { $fwhm < 10 && $fwhm > 5 } {
         set max 10
      } elseif { $fwhm < 5 } {
         set max 5
      }
      $graph.fwhm yaxis configure -max $max

      #--   identifie le rang de la derniere image
      set imgNo [ ${racine}intensite length ]

      #--   configure l'axe des ordonnees
      if { $imgNo >= 20 } {
         incr imgNo
         ::V_${visuNo}_imgNo append $imgNo
         set index_first [ expr { $imgNo - 19 } ]
         #--   selectionne toujours les 20 dernieres mesures
         foreach par { intensite fwhm ratio_x_y contrast } {
            $graph.$par xaxis configure -min $index_first -max $imgNo
            $graph.$par x2axis configure -min $index_first -max $imgNo
         }
      }
   }

   #---------------------------------------------------------------------------
   #  focGraphe : cree la fenetre des graphiques de focalisation
   #  Parametres : N° de la visu
   #---------------------------------------------------------------------------
   proc focGraphe { visuNo } {
      variable private
      global caption conf

      set this $private($visuNo,base).parafoc
      set private($visuNo,graph) $this

      #--- Fenetre d'affichage des parametres de la foc
      if [ winfo exists $this ] {
         fermeGraphe $visuNo $this
      }

      #--- Creation et affichage des graphes
      if { ! [ winfo exists  $this ] } {

         #--- Creation de la fenetre
         toplevel $this
         wm title $this "$caption(spytimer,focalisation)"
         wm resizable $this 1 1
         set posx [ lindex [ split [ wm geometry $private($visuNo,base).config ] "+" ] 1 ]
         set posy [ lindex [ split [ wm geometry $private($visuNo,base).config ] "+" ] 2 ]
         wm geometry $this +[ expr $posx + 450 ]+[ expr $posy ]
         wm protocol $this WM_DELETE_WINDOW "::spytimer::closeFocGraphe $visuNo $this"

         #---
         blt::vector create ::V_${visuNo}_imgNo -watchunset 1
         #--   cree le vecteur de 1 a 20
         ::V_${visuNo}_imgNo seq 1 20 1
         #--   fait demarrer l'index a 1
         ::V_${visuNo}_imgNo offset 1

         foreach par { intensite contrast fwhm ratio_x_y } {

            blt::vector create ::V_${visuNo}_$par -watchunset 1

            #--   fait demarrer l'index a 1
            ::V_${visuNo}_$par offset 1

            #--   cree le graphique
            set graph [ ::spytimer::buildGraph $visuNo $this imgNo $par ]

            $graph xaxis configure -min 1  -max 20 -stepsize 1
            $graph x2axis configure -min 1 -max 20 -stepsize 1

         }

         button $this.init -borderwidth 2 -text "$caption(spytimer,init)" -width 15 \
            -command "::spytimer::initFocGraph $visuNo"
         pack $this.init -side bottom -side left -padx 15 -pady 5

         button $this.close -borderwidth 2 -text "$caption(spytimer,close)" -width 15 \
            -command "::spytimer::closeFocGraphe $visuNo $this"
         pack $this.close -side bottom -side right -padx 15 -pady 5

         #--- Mise a jour dynamique des couleurs
         ::confColor::applyColor $this
      }

      #--   active la surveillance du repertoire
      set private($visuNo,survey) 1
      ::spytimer::initSurvey $visuNo
   }

   #---------------------------------------------------------------------------
   #  buildGraph Construit une zone graphique
   #  Parametres : N° de la visu, nom du frame graphique ,
   #     nom du vecteur abscisses et nom de la variable
   #  Return : chemin du frame graphique
   #  Fonction commune aux deux graphiques
   #---------------------------------------------------------------------------
   proc buildGraph { visuNo w abscisses par } {
      global caption

     lassign [ list 500 140 30 80 ] width height bottom_margin side_margin
      set grph [ blt::graph $w.$par -title "" \
         -width $width -height $height -takefocus 0 \
         -bd 0 -relief flat \
         -rightmargin $side_margin -leftmargin $side_margin \
         -topmargin $bottom_margin -bottommargin $bottom_margin \
         -plotborderwidth 2 -plotrelief groove \
         -plotpadx 0 -plotpady 0 -plotbackground grey ]

      $grph element create line -xdata ::V_${visuNo}_${abscisses} -ydata ::V_${visuNo}_${par} \
         -color red -hide no -linewidth 1 -symbol "scross"

      $grph xaxis configure -hide no -subdivision 0 -max {}
      $grph x2axis configure -hide no -subdivision 0  -max {}
      $grph yaxis configure -title "$caption(spytimer,$par)" -min {} -max {} -hide no
      $grph y2axis configure -min {} -max {} -hide no

      #--   masque la legende
      $grph legend configure -hide yes

      pack $grph -side top -fill both -expand 1
      return $grph
   }

   #---------------------------------------------------------------------------
   #  initFocGraph : remet a zero tous les vecteurs du graphique
   #  Parametres : N° de la visu
   #---------------------------------------------------------------------------
   proc initFocGraph { visuNo } {

      foreach par { intensite contrast fwhm ratio_x_y } {
         ::V_${visuNo}_$par length 0
      }
   }

   #---------------------------------------------------------------------------
   #  closeFocGraphe : ferme le graphique
   #  Parametres : N° de la visu et chemin de la fenetre
   #---------------------------------------------------------------------------
   proc closeFocGraphe { visuNo this } {
      global conf

      #--   detruit les vecteurs persistants
      blt::vector destroy ::V_${visuNo}_imgNo ::V_${visuNo}_intensite \
         ::V_${visuNo}_contrast ::V_${visuNo}_fwhm ::V_${visuNo}_ratio_x_y

      destroy $this
   }