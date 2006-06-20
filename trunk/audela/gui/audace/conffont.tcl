#
# Fichier : conffont.tcl
# Description : Selection et mise a jour en direct des polices de l'interface Aud'ACE
# Auteur : Robert DELMAS
# Mise a jour $Id: conffont.tcl,v 1.3 2006-06-20 17:25:40 robertdelmas Exp $
#

namespace eval confFont {
global audace

   proc init { } {
      global audace

      if { $::tcl_platform(os) == "Linux" } {

         #--- Fontes des liens hypertextes (fonte Linux = fonte Windows + 3)
         set audace(font,url)             "arial 12 normal"

         #--- Fontes des en-tetes FITS et des listes (fonte Linux = fonte Windows + 3)
         set audace(font,en_tete_1)       "courier 11 normal"
         set audace(font,en_tete_2)       "courier 11 bold"
         set audace(font,listbox)         "courier 13 bold"

         #--- Fontes des boites et des outils (fonte Linux = fonte Windows + 3)
         set audace(font,arial_6_n)       "arial 9 normal"
         set audace(font,arial_6_b)       "arial 9 bold"
         set audace(font,arial_7_n)       "arial 10 normal"
         set audace(font,arial_7_b)       "arial 10 bold"
         set audace(font,arial_8_n)       "arial 11 normal"
         set audace(font,arial_8_b)       "arial 11 bold"
         set audace(font,arial_10_n)      "arial 13 normal"
         set audace(font,arial_10_b)      "arial 13 bold"
         set audace(font,arial_12_n)      "arial 15 normal"
         set audace(font,arial_12_b)      "arial 15 bold"
         set audace(font,arial_15_b)      "arial 18 bold"

      } elseif { $::tcl_platform(os) == "Darwin" } {

         #--- Fontes des liens hypertextes (fonte Mac = fonte Windows + 3)
         set audace(font,url)             "arial 12 normal"

         #--- Fontes des en-tetes FITS et des listes (fonte Mac = fonte Windows + 3)
         set audace(font,en_tete_1)       "courier 11 normal"
         set audace(font,en_tete_2)       "courier 11 bold"
         set audace(font,listbox)         "courier 13 bold"

         #--- Fontes des boites et des outils (fonte Mac = fonte Windows + 3)
         set audace(font,arial_6_n)       "arial 9 normal"
         set audace(font,arial_6_b)       "arial 9 bold"
         set audace(font,arial_7_n)       "arial 10 normal"
         set audace(font,arial_7_b)       "arial 10 bold"
         set audace(font,arial_8_n)       "arial 11 normal"
         set audace(font,arial_8_b)       "arial 11 bold"
         set audace(font,arial_10_n)      "arial 13 normal"
         set audace(font,arial_10_b)      "arial 13 bold"
         set audace(font,arial_12_n)      "arial 15 normal"
         set audace(font,arial_12_b)      "arial 15 bold"
         set audace(font,arial_15_b)      "arial 18 bold"

      } else {

         #--- Fontes des liens hypertextes
         set audace(font,url)             "arial 9 normal"

         #--- Fontes des en-tetes FITS et des listes
         set audace(font,en_tete_1)       "courier 8 normal"
         set audace(font,en_tete_2)       "courier 8 bold"
         set audace(font,listbox)         "courier 10 bold"

         #--- Fontes des boites et des outils
         set audace(font,arial_6_n)       "arial 7 normal"
         set audace(font,arial_6_b)       "arial 7 bold"
         set audace(font,arial_7_n)       "arial 7 normal"
         set audace(font,arial_7_b)       "arial 7 bold"
         set audace(font,arial_8_n)       "arial 8 normal"
         set audace(font,arial_8_b)       "arial 8 bold"
         set audace(font,arial_10_n)      "arial 10 normal"
         set audace(font,arial_10_b)      "arial 10 bold"
         set audace(font,arial_12_n)      "arial 12 normal"
         set audace(font,arial_12_b)      "arial 12 bold"
         set audace(font,arial_15_b)      "arial 15 bold"

      }

   }

}

#--- Initialisation des polices
::confFont::init

