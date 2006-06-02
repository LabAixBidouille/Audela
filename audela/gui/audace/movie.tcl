#
# Fichier : movie.tcl
# Description : Lecture des films avi, mov, mpeg (pour plateforme Windows uniquement)
# Auteur : Michel PUJOL
# Date de mise a jour : 02 juin 2006
#

##############################################################################
# namespace Movie
#
#   ::Movie::open filename       ouvre un fichier et affiche la premiere image
#   ::Movie::close               ferme le fichier
#   ::Movie::start               demarre la lecture du film
#   ::Movie::stop                arrete la lecture du film
#
#############################################################################

namespace eval ::Movie {

   array set private {
      opened 0
   }

   #------------------------------------------------------------
   # Movie::open 
   #   ouvre le fichier du film
   #   et affiche la premiere image
   #------------------------------------------------------------
   proc open { fileName hCanvas zoom x y anchor} {
      variable private
      global audace

      Movie::close $hCanvas
      #--- je verifie que le package tmci est present
      set result [catch { package require tmci } msg]
      if { $result == 1} {
         set message "error : package \"tmci\" not found "
         console::affiche_erreur "$message \n"
         tk_messageBox -title "Movie.tcl" -type ok -message "$message" -icon error
         return
      }

      set hWindow [createMovieWindow $hCanvas $x $y $anchor]
      catch { 
         #--- je ferme la session
         #mci "close aliasmovie"
      }

      #--- j'ouvre le film et associe a la fenetre de style child
      set result [catch { mci "open \"$fileName\" alias aliasmovie " } msg]
      if { $result == 1} {
         return 0
      }

      #--- je recupere les dimensions du film
      set frameSize [mci "where aliasmovie source"]
      set w [lindex $frameSize 2]
      set h [lindex $frameSize 3]

      #--- calcul des dimensions en fonction du zoom
      set w_zoomed [expr int(${zoom}*$w)]
      set h_zoomed [expr int(${zoom}*$h)]
      set private(hWindow) $hWindow

      #--- j'adapte les dimensions de la fenetre
      $hCanvas itemconfigure avi -width $w_zoomed -height $h_zoomed
      #--- je mets la fenetre au premier plan
      $hCanvas raise $private(hWindow)

      #--- j'adapte la taille de l'image en fonction du zoom
      mci "put aliasmovie destination at 0 0 $w_zoomed $h_zoomed"

      #--- je recupere le handle WINDOWS de la fenetre
      scan [winfo id $private(hWindow) ] 0x%x canvasid
      #--- j'associe le handle WINDOWS a l'alias MCI
      mci "window aliasmovie handle $canvasid"
      #after 5 { mci "update aliasmovie hdc 0 wait" }
      #--- j'affiche la premiere image du film par dessus le background de la fenetre
      mci "update aliasmovie hdc 0"
      update

      #--- je raffraichis l'affichage du reticule
      #--- je redessine le reticule
      set audace(picture,w) $w
      set audace(picture,h) $h
      ::confVisu::redrawCrosshair $audace(visuNo)

      #--- je cree un bind pour raffraichir l'affichage chaque fois que le curseur de la souris revient sur la fenetre
      bind $hWindow <Enter> {
         #--- j'affiche la premiere image du film par dessus le background de la fenetre
         mci "update aliasmovie hdc 0"
      }

      set private(opened) 1
      #mci "play aliasmovie from 0:0:0 to 0:0:0 wait"
      after 100 {
         catch { mci "update aliasmovie hdc 0" }
      }
      update
   }

   #------------------------------------------------------------
   # Movie::close
   #   ferme le film et masque la fenetre
   #------------------------------------------------------------
   proc close { hCanvas } {
      variable private
      global audace

      if { $private(opened) == 0 } return
      catch {
         #--- j'annule le bind
         bind $hCanvas.movie <Enter> {}
      }

      catch {
         #--- je ferme la session mci
         mci "close aliasmovie"
      }
      #--- je supprime le canvas
      deleteMovieWindow $hCanvas
      set private(opened) 0
   }

   #------------------------------------------------------------
   # Movie::start
   #   demarre la lecture du film
   #------------------------------------------------------------
   proc start { } {
      catch { mci "play aliasmovie from 0:0:0" }
   }

   #------------------------------------------------------------
   # Movie::stop
   #   arrete la lecture du film
   #------------------------------------------------------------
   proc stop { } {
      catch { mci "stop aliasmovie" }
   }

   #------------------------------------------------------------
   # createMovieWindow
   #   cree la fenetre pour les films et l'ajoute au canvas
   #------------------------------------------------------------
   proc createMovieWindow { hCanvas x y anchor} {
      global audace

      set hWindow $hCanvas.movie
      #--- je cree une fenetre pour visualiser le film
      if { ![winfo exists $hWindow ] } {
         #--- le widget "label" est la plus simple des fenetres
         label $hWindow -bg darkGreen
      }
      #--- je declare le label comme item du canvas
      $hCanvas create window $x $y -tag avi -anchor $anchor -window $hWindow -width 1 -height 1
      return $hWindow
   }

   #------------------------------------------------------------
   # deleteMovieWindow
   #   je detruis la canvasItem car il n'est pas possible de la masquer
   #------------------------------------------------------------
   proc deleteMovieWindow { hCanvas } {
      global audace

      $hCanvas delete avi
   }
}

