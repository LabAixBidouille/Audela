#
# Fichier : mycycle.tcl
# Description : Procedure de definition des cylces personnels
# Auteur : Fr√©d√©ric Vachier
# Mise √† jour $Id$
#
# source audace/plugin/tool/acqt1m/cycle.tcl
#

#============================================================
# Declaration du namespace bddimages
#    initialise le namespace
#============================================================
namespace eval ::mycycle {






   proc ::mycycle::use { } {

      ::mycycle::Haumea
   
   }







   proc ::mycycle::KOI13 { } {

      variable private

      set private(object)         "KOI-13"
      set private(bin)            "1x1"
      set private(ra)             "19:07:53.09"
      set private(dec)            "+46:52:6.10"
      #†Liste le mouvement de la roue, [Filtre Exposure nbimg]
      set private(roue)           [list [list "Us" 60 1] [list "Gs" 3 5] [list "Rs" 1.5 10] [list "Is" 1.5 10] [list "Zs" 3 5] ]
   
   }




   proc ::mycycle::Comete { } {

      variable private

      set ::cycle::object          "67P"      
      set ::cycle::ra              "19:07:53.09"
      set ::cycle::dec             "+46:52:6.10"

   
      #†Liste le mouvement de la roue, [Filtre Exposure nbimg]
      set private(roue)           [list [list "Us" 60 1] [list "Gs" 3 5] [list "Rs" 1.5 10] [list "Is" 1.5 10] [list "Zs" 3 5] ]
   }

   proc ::mycycle::Haumea { } {

      set ::cycle::object         "Haumea"      
      set ::cycle::ra             "13 53 11.8619"
      set ::cycle::dec            "+18 35 49.413"
   
      #†Liste le mouvement de la roue  [Filtre    Exposure   nbimg   binning   ]
      set ::cycle::roue          [list [list "Rs"   150        1        1      ] \
                                       [list "Is"   150        1        1      ] \
                                       [list "Gs"   150        1        1      ] \
                                       [list "Rs"   60        1        2      ] \
                                       [list "Is"   60        1        2      ] \
                                       [list "Gs"   60        1        2      ] \
                                 ]

   }




# Fin namespace
   }
