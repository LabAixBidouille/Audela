#####################################################################
#
# Fichier     : bess_module.tcl
# Description : Script pour générer un fichier FITS de spectre conforme à la base de données bess
# Auteurs     : François Cochard (francois.cochard@wanadoo.fr)
#               Sur la forme, je suis parti du script calaphot de Jacques Michelet (jacques.michelet@laposte.net)
#               Par ailleurs, je m'appuie sur les routines spc_audace de Benjamin Mauclaire
# Mise a jour $Id: bess_module.tcl,v 1.1 2008-06-14 16:36:31 bmauclaire Exp $
# Mise à jour FC mars 2007
# Dernière mise à jour: 24 mars 2007 - 11h00
#
#####################################################################

# Bugs à corriger avant release
# - Permettre l'accès à la routine aussi bien en standalone (script) que par une ligne de cde avec nom de fichier en argument
# - Virer les appels à consolog: pas besoin de générer un fichier de log !
# - Le message "fin normale du script arrive trop tôt dans la console
# - Ajouter des coches pour les traitements (tell; helio, norm...)
# - Bug : Permettre de mettre des # dans les champs prédefinis
# - Bug "affichage fin ANTICIPEE du script..."
# - Demander confirmation avant d'écraser le fichier...
# - Tenir compte du fait que la vitesse héliocentrique est optionnelle
# - Ajouter la correction tellurique, la normalisation, la vitesse helio
# - Recharger dynamiquement le fichier des prédéfinis

# Définition d'un espace réservé à ce script
catch {namespace delete ::bess}
namespace eval ::bess {

   variable parametres
   variable text_bess
   variable police
   variable test
   variable parametres
   set fich_in ""

   set numero_version v0.2

   if {$tcl_platform(os)!="Linux"} {
      set police(gras)     [font actual .audace]
      set police(italique) [font actual .audace]
      set police(normal)   [font actual .audace]
      set police(titre)    [font actual .audace]
   } else {
      set police(gras)     {helvetica 9 bold}
      set police(italique) {helvetica 9 italic}
      set police(normal)   {helvetica 9 normal}
      set police(titre)    {helvetica 11 bold}
   }

   global audace audela

   if { [regexp {1.3.0} $audela(version) match resu ] } {
       set repspc [ file join $audace(rep_scripts) spcaudace ]
       source [file join $repspc plugins bess_module bess_module.cap]
       source [file join $repspc spc_io.tcl]
   } else {
       set repspc [ file join $audace(rep_plugin) tool spectro spcaudace ]
       source [file join $repspc plugins bess_module bess_module.cap]
       source [file join $repspc spc_io.tcl]
   }

   #*************************************************************************#
   #*************  Principal  ***********************************************#
   #*************************************************************************#
   proc Principal { fich_in } {

      global audace color
      variable parametres
      variable text_bess
      variable liste_instruments
      variable liste_sites
      variable liste_observers

      LitFichesBeSSPredefinies
      ChargeFichier $fich_in
      EditeParametres $fich_in
   }

   #*************************************************************************#
   #*************  AnnuleSaisie  ********************************************#
   #*************************************************************************#
   proc AnnuleSaisie { } {
      global audace

      destroy $audace(base).saisie
      update idletasks
   }

   #*************************************************************************#
   #*************  Message  *************************************************#
   #*************************************************************************#
   proc Message { niveau args } {
      variable test
      variable fileId
      global audace

      switch -exact -- $niveau {
         console {
            ::console::disp [eval [concat {format} $args]]
            update idletasks
         }
         log {
            puts -nonewline $fileId [eval [concat {format} $args]]
         }
         consolog {
            ::console::disp [eval [concat {format} $args]]
            update idletasks
            catch {puts -nonewline $fileId [eval [concat {format} $args]]}
         }
         test {
            ::console::affiche_erreur [eval [concat {format} $args]]
            update idletasks
         }
      }

      if {[info exists test]} {
         if {[catch {open [file join $audace(rep_images) debug.log] a} filetest]} {
            Message console $filetest
            return
         } else {
            puts -nonewline $filetest [eval [concat {format} $args]]
            close $filetest
         }
      }
   }

   #*************************************************************************#
   #*************  LitFichesBeSSPredefinies  **********************************#
   #*************************************************************************#
   # Lit les noms prédéfinis pour les sites, les instruments et les observateurs
   proc LitFichesBeSSPredefinies { } {
      global audace
#       variable parametres
      variable liste_instrument
      variable liste_site
      variable liste_observer

      set motcle ""
      set valeur ""

      # Initialisation
      if {[info exists liste_instrument]} {unset liste_instrument}
      if {[info exists liste_site]} {unset liste_site}
      if {[info exists liste_observer]} {unset liste_observer}

      # Ouverture du fichier de paramètres
      set fichier [file join $audace(rep_plugin) tool spectro spcaudace plugins bess_module BeSSParam.ini]

      if {[file exists $fichier]} {
# On ouvre le fichier
         set fileID [open $fichier r]
# Et on lit chaqueligne
         while {[eof $fileID] == 0} {
            gets $fileID ligne
#           Message console "%s - eof %s\n" $ligne [eof $fileID]
            if {[BalayageLigne $ligne] == 0} {
               lappend liste_$motcle $valeur
            }
         }
         close $fileID
         if {[info exists liste_instrument] == 0} { set liste_instrument [ list "" ] }
         if {[info exists liste_site] == 0} { set liste_site [ list "" ] }
         if {[info exists liste_observer] == 0} { set liste_observer [ list "" ] }
       } else {
          set liste_instrument [ list "" ]
          set liste_site [ list ""]
          set liste_observer [ list ""]
       }

}

#*******************************************************************************

   proc BalayageLigne {ligne} {
    # Passage des parametres de retour (motcle et valeur)
    upvar motcle motcle
    upvar valeur valeur

    # Nettoyage des characteres <espace> en trop
    set ligne [string trim $ligne]

    # Cas de la ligne de commentaires (ignorée)
    if {[string first \# $ligne] == 0} {
        return -2
    }

    # Isolement du mot cle
    set cg [string first \[ $ligne]
    set cd [string first \] $ligne]
    # Erreurs de syntaxe
    if {($cg<0 && $cd>=0) || ($cg>=0 && $cd<0)} {
        return -1
    }
    set motcle [string tolower [string range $ligne [expr $cg+1] [expr $cd-1]]]

    # Isolement de la valeur associée, et nettoyage des caractères <espace> résiduels
    set valeur [string trim [string range $ligne [expr $cd+1] end]]
    if {[string length $valeur] == 0} {
        return -3
    }
    return 0
    }


   #*************************************************************************#
   #*************  ChargeFichier  ********************************************#
   #*************************************************************************#
   # Va chercher les mots-clé fits dans le header du fichier sélectionné
      proc ChargeFichier { fich_in } {
         # On procède par étapes:
         # - On regarde le format du fichier, et on convertit si besoin
         # - On lit le header pour initialiser les variables
         # - On duplique les données du header pour en garder trace

      global audace
      variable parametres
      variable parametresOld
      variable fich_out

      if { $fich_in == ""} {
         foreach motcle { OBJNAME BSS_RA BSS_DEC OBSERVER BSS_INST BSS_SITE DATE-OBS EXPTIME BSS_VHEL BSS_NORM BSS_TELL BSS_COSM obs1 obs2 obs3 datedeb heuredeb} {
            set parametres($motcle) ""
         }
#        return
      } else {

      #  - On regarde le format du fichier, et on convertit si besoin
            set racine [file tail [file rootname $fich_in]]
            set ::bess::fich_in $racine
            set fich_out $racine
            
            switch [file extension $fich_in] {
               ".dat" {
                  spc_dat2fits $racine.dat
                  buf$audace(bufNo) load [file join $audace(rep_images) $racine ]
               }
               ".spc" {
                  spc_spc2fits $racine.spc
                  buf$audace(bufNo) load [file join $audace(rep_images) $racine]
                  # Corriger: virer l'extension _spc à la création du fichier (cf Benjamin)
               }
               ".fit" {
                  # On se contente de charger le fichier
                  buf$audace(bufNo) load [file join $audace(rep_images) $fich_in]
      #                    Message console "Je charge %s - Ok\n" [file join $audace(rep_images) $fich_in]
               }
               "" {
                  # On se contente de charger le fichier
                  buf$audace(bufNo) load [file join $audace(rep_images) $fich_in]
      #                    Message console "Je charge en FIT %s - Ok\n" [file join $audace(rep_images) $fich_in]
         }
         default {
#            break
         }
      }

# On liste les mots-clé BeSS
      foreach motcle { OBJNAME BSS_RA BSS_DEC OBSERVER BSS_INST BSS_SITE DATE-OBS EXPTIME BSS_VHEL BSS_NORM BSS_TELL BSS_COSM} {
         set ligne [buf$audace(bufNo) getkwd $motcle]
#           Message console "mot cle - %s - %s\n" $motcle [lindex $ligne 1]
          set parametres($motcle) [lindex $ligne 1]
      }
# Sépare le champ DATE-OBS
      set parametres(datedeb) [lindex [split $parametres(DATE-OBS) T] 0]
      set parametres(heuredeb) [lindex [split $parametres(DATE-OBS) T] 1]

# Sépare le champ Observer en 3 noms
      set parametres(obs1) [string trim [lindex [split $parametres(OBSERVER) ,] 0]]
      set parametres(obs2) [string trim [lindex [split $parametres(OBSERVER) ,] 1]]
      set parametres(obs3) [string trim [lindex [split $parametres(OBSERVER) ,] 2]]

# On garde trace des éléments du header - on n'enregistrera que ceux qui sont modifiés
      }
      if {[info exists parametresOld]} {unset parametresOld}
      foreach indice [array names parametres] {
         set parametresOld($indice) $parametres($indice)
      }
   }

   #*************************************************************************#
   #*************  SelectFile  **********************************************#
   #*************************************************************************#
   # Ouvre un menu de sélection de fichier
   proc SelectFile { } {
      global audace
      set nomFichier [tk_getOpenFile -filetypes { { {FIT} {.fit} } { {DAT} {.dat} } { {SPC} {.spc} } } -initialdir $audace(rep_images)]
      set nomFichier [file tail $nomFichier]
      set ::bess::fich_in [file tail $nomFichier]
      ChargeFichier $nomFichier
  }

   #*************************************************************************#
   #*************  EditeParametres  ****************************************#
   #*************************************************************************#
   proc EditeParametres { fich_in } {
      global audace
      global color
      variable parametres
      variable parametresOld
      variable text_bess
      variable police
      variable liste_instrument
      variable liste_site
      variable liste_observer
#       variable fich_out

      variable bess_export_fg
      set bess_export_fg #ECE9D8
      variable bess_entry_fg
      set bess_entry_fg $color(white)

      # Ferme la fentre si elle est deja ouverte
      if [ winfo exists $audace(base).saisie ] {
         ::bess::AnnuleSaisie
      }

#       Provisioire (debug)
#       Message console "fichier - %s - Ok (editeur)\n" $fich_in

      # Construction de la fenêtre des paramètres
      toplevel $audace(base).saisie -borderwidth 2 -relief groove -bg $bess_export_fg
      #wm geometry $audace(base).saisie 560x550+120+50
      wm geometry $audace(base).saisie 605x570+120+50
      wm title $audace(base).saisie $text_bess(titre_saisie)
      wm protocol $audace(base).saisie
#       WM_DELETE_WINDOW ::bess::Suppression

      # Construction du canevas qui va contenir toutes les trames et des ascenseurs
      set c [canvas $audace(base).saisie.canevas]

      # Construction d'une trame qui va englober toutes les listes dans le canevas
      set t [frame $c.t]
      $c create window 0 0 -anchor nw -window $t


      # Trame du titre
  if { 1==0 } {
      frame $t.trame0 -borderwidth 5 -relief groove -bg $bess_export_fg
      label $t.trame0.titre \
	      -font [ list {Arial} 16 bold ] -text $text_bess(titrePanneau) \
	      -borderwidth 0 -relief flat -bg $bess_export_fg  \
	      -fg $color(blue_pad)
#label $t.trame0.titre -text $text_bess(titrePanneau) -font {helvetica 16 bold} -justify center -fg $color(blue_pad) -bg $bess_export_fg 
      pack $t.trame0.titre -in $t -fill x -side top -pady 15
      #pack $t.trame0.titre -side top -fill both -expand true
  }

      #--------------------------------------------------------------------------------
      # Trame du nom des fichier à éditer et de sortie            
      frame $t.trame1 -borderwidth 5 -relief groove -bg $bess_export_fg
      
      label $t.trame1.titre -text $text_bess(titrePanneau) -font {helvetica 16 bold} -justify center -fg $color(blue_pad) -bg $bess_export_fg
      grid $t.trame1.titre -in $t.trame1 -columnspan 2 -sticky w
      
      label $t.trame1.l1 -text $text_bess(fich_in) -font $police(gras) -fg $color(blue_pad) -bg $bess_export_fg
      entry $t.trame1.e1 -textvariable ::bess::fich_in -font $police(normal) -relief sunken -bg $bess_entry_fg
      button $t.trame1.b1 -text $text_bess(SelecFile) -command {::bess::SelectFile} -font $police(titre) -bg $bess_export_fg
      button $t.trame1.b2 -text $text_bess(ChargeFichier) -command {::bess::ChargeFichier $::bess::fich_in} -font $police(titre) -fg $color(blue_pad) -bg $bess_export_fg
      grid $t.trame1.l1 $t.trame1.e1 $t.trame1.b1 $t.trame1.b2
      
      label $t.trame1.l2 -text $text_bess(fich_out) -font $police(gras) -fg $color(blue_pad) -bg $bess_export_fg
      entry $t.trame1.e2 -textvariable ::bess::fich_out -font $police(normal) -relief sunken -bg $bess_entry_fg
      grid $t.trame1.l2 $t.trame1.e2

      pack $t.trame1 -side top -fill both -expand true
      

      #--------------------------------------------------------------------------------
      # Trame des renseignements généraux
      frame $t.trame2 -borderwidth 5 -relief groove -bg $bess_export_fg
#       label $t.trame2.titre -text $text_bess(param_generaux) -font $police(titre) -fg $color(blue_pad) -bg $bess_export_fg
      label $t.trame2.opt -text $text_bess(optionnel) -font $police(gras) -fg $color(blue_pad) -bg $bess_export_fg
      grid $t.trame2.opt -in $t.trame2 -columnspan 3 -sticky e

      foreach champ {OBJNAME BSS_RA BSS_DEC datedeb heuredeb EXPTIME BSS_VHEL BSS_NORM BSS_TELL BSS_COSM} {
         label $t.trame2.l$champ -text $text_bess($champ) -font $police(gras) -fg $color(blue_pad) -bg $bess_export_fg
         entry $t.trame2.e$champ -textvariable ::bess::parametres($champ) -font $police(normal) -relief sunken -bg $bess_entry_fg
         label $t.trame2.lb$champ -text $text_bess(u_$champ) -font $police(gras) -fg $color(blue_pad) -bg $bess_export_fg
         grid $t.trame2.l$champ $t.trame2.e$champ $t.trame2.lb$champ
      }

      set liste_BSS_INST $liste_instrument
      set liste_BSS_SITE $liste_site
      set liste_obs1 $liste_observer
      set liste_obs2 $liste_observer
      set liste_obs3 $liste_observer

      foreach champ {BSS_INST BSS_SITE obs1 obs2 obs3} {
         set liste [set liste_$champ]
         label $t.trame2.l$champ -text $text_bess($champ) -font $police(gras) -fg $color(blue_pad) -bg $bess_export_fg
         ComboBox $t.trame2.e$champ -textvariable ::bess::parametres($champ) -font $police(normal) -relief sunken -values $liste
         label $t.trame2.lb$champ -text $text_bess(u_$champ) -font $police(gras) -fg $color(blue_pad) -bg $bess_export_fg
         grid $t.trame2.l$champ $t.trame2.e$champ $t.trame2.lb$champ
      }
      pack $t.trame2 -side top -fill both -expand true

      #--------------------------------------------------------------------------------
      # Trame des boutons. Ceux-ci sont fixes (pas d'ascenseur).
      frame $t.trame3 -borderwidth 5 -relief groove -bg $bess_export_fg

      button $t.trame3.b1 -text $text_bess(enregistrer) -command {::bess::EnregistreSaisie $::bess::fich_out} -font $police(titre) -fg $color(blue_pad) -bg $bess_export_fg
      button $t.trame3.b2 -text $text_bess(editer) -command {::bess::EditeConfigs} -font $police(titre) -fg $color(blue_pad) -bg $bess_export_fg
      button $t.trame3.b3 -text $text_bess(annuler) -command {::bess::AnnuleSaisie} -font $police(titre) -fg $color(blue_pad) -bg $bess_export_fg
      button $t.trame3.b4 -text $text_bess(webess) -command {::bess::WebBeSS} -font $police(titre) -fg $color(blue_pad) -bg $bess_export_fg
      pack $t.trame3.b1 -side left -padx 10 -pady 10
      pack $t.trame3.b2 -side left -padx 10 -pady 10
      pack $t.trame3.b3 -side right -padx 10 -pady 10
      pack $t.trame3.b4 -side right -padx 35 -pady 10
      

      pack $t.trame3 -side top -fill both -expand true

      pack $c -side left -fill both -expand true

      tkwait window $audace(base).saisie
      if { "$::bess::fich_out"!="" } {
	   return "$::bess::fich_out"
      }
   }

   #*************************************************************************#
   #*************  WebBeSS  ************************************#
   #*************************************************************************#
   proc WebBeSS { } {

      global audace conf spcaudace
      variable text_bess
      
     if { $conf(editsite_htm)!="" } {
	      set answer [ catch { exec $conf(editsite_htm) "$spcaudace(sitebess)" & 
	      } ]
      } else {
	      set message_erreur $text_bess(pb_editweb)
	      tk_messageBox -message $message_erreur -icon error -title $text_bess(probleme)
    }
   }

   #*************************************************************************#
   #*************  EditeConfigs  ************************************#
   #*************************************************************************#
   proc EditeConfigs { } {

      global audace conf
      variable liste_instruments
      variable liste_sites
      variable liste_observers

      set fichier [file join $audace(rep_plugin) tool spectro spcaudace plugins bess_module BeSSParam.ini]
      catch {
         exec $conf(editscript) $fichier
         tkwait visibility $audace(base).saisie
         LitFichesBeSSPredefinies
         }

   }
   
   #*************************************************************************#
   #*************  valideMotCle  ********************************************#
   #*************************************************************************#
# Cette procédure teste la validité d'un mote-clé BeSS
   proc valideMotCle { motcle valeurmotle } {
      global audace
      variable parametres
      variable text_bess

      switch $motcle {

        "OBJNAME" {
#          Verifier le longueur du champ
# Verifier les caractères utilisés
          set result 1        }

          "BSS_RA" {
#            Verifier que DEC est aussi présent
             if {!([string is double $parametres(BSS_RA)])} {
                set message_erreur $text_bess(pb_ra)
                tk_messageBox -message $message_erreur -icon error -title $text_bess(probleme)
                set result -2
             } else {
                set result 1
             }
          }

          "BSS_DEC" {
#                  Verifier que RA est aussi présent
             if {!([string is double $parametres(BSS_DEC)])} {
                set message_erreur $text_bess(pb_dec)
                tk_messageBox -message $message_erreur -icon error -title $text_bess(probleme)
                set result -2
             } else {
                set result 1
             }
           }

          "OBSERVER" {
#            Verifier que pas plus de trois observateurs
# Verifier la longueur du champ
            set result 1
          }

          "BSS_INST" {
             # Verifier la longueur du champ
            set result 1        }

          "BSS_SITE" {
             # Verifier la longueur du champ
            set result 1        }

          "DATE-OBS" {
#            Vérifier le format
            set result 1        }

          "EXPTIME" {
            if {!([string is double $parametres(EXPTIME)])} {
                set message_erreur $text_bess(pb_exptime)
                tk_messageBox -message $message_erreur -icon error -title $text_bess(probleme)
                set result -2
               } else {
                set result 1            }
          }

          "BSS_VHEL" {
            if {!([string is double $parametres(BSS_VHEL)])} {
                set message_erreur $text_bess(pb_vhel)
                tk_messageBox -message $message_erreur -icon error -title $text_bess(probleme)
                set result -2
               } else {
                set result 1            }
          }

          "BSS_NORM" {
             # Verifier la longueur du champ
            set result 1        }

          "BSS_TELL" {
             # Verifier la longueur du champ
            set result 1        }

          "BSS_COSM" {
             # Verifier la longueur du champ
            set result 1        }

         default {
            set result -1      }
        }
        return $result
}

   #*************************************************************************#
   #*************  EnregistreSaisie  ****************************************#
   #*************************************************************************#
   proc EnregistreSaisie { fich_out } {
      global audace
      variable text_bess
      variable parametres
      variable parametresOld

#       Dans un premier temps, on commence par regarder si les mots-cle modifiés sont valides.
# La variable motCleAModifier contiendra la liste des mots-clé modifiés
      if {[info exists motCleAModifier]} {unset motCleAModifier}
# La variable pas_glop est à 0 tant que les champs sont corrects. Le processus est interrompu sinon
      set pas_glop 0
#       Message console "fichier %s\n" $fich_out

#       On traite le cas à part du mot-clé OBSERVER (séparé en 3 dans le panneau)
      if { $parametres(obs1) != $parametresOld(obs1) ||
          $parametres(obs2) != $parametresOld(obs2) ||
          $parametres(obs3) != $parametresOld(obs3) } {
             set parametres(OBSERVER) $parametres(obs1)
             append parametres(OBSERVER) ","
             append parametres(OBSERVER) $parametres(obs2)
             append parametres(OBSERVER) ","
             append parametres(OBSERVER) $parametres(obs3)
      } else {
         set parametres(OBSERVER) $parametresOld(OBSERVER)
      }

#       On traite le cas à part du mot-clé DATE-OBS (séparé en 2 dans le panneau)
      if {$parametres(datedeb) != $parametresOld(datedeb) ||
          $parametres(heuredeb) != $parametresOld(heuredeb) } {
             set parametres(DATE-OBS) $parametres(datedeb)
             append parametres(DATE-OBS) T
             append parametres(DATE-OBS) $parametres(heuredeb)
      } else {
         set parametres(DATE-OBS) $parametresOld(DATE-OBS)
      }

#       On traite maintenant en bloc tous le smots-clé
      foreach motcle { OBJNAME BSS_RA BSS_DEC OBSERVER BSS_INST BSS_SITE DATE-OBS EXPTIME BSS_VHEL BSS_NORM BSS_TELL BSS_NORM} {
         if { $parametres($motcle) != $parametresOld($motcle)} {
#           Le mot-cle a été modifié
              if { [valideMotCle $motcle $parametres($motcle)] != 1 } {
                 set pas_glop 1
#                Message console "Erreur:  %s - %s\n" $motcle $parametres($motcle)
#                break
              } else {
#                   Message console "A MODIFIER ! - %s - %s\n" $motcle $parametres($motcle)
                 lappend motCleAModifier $motcle
              }
         }
      }
      if {$pas_glop == 0} {
   #     On peut maintenant enregistrer les mots-cé...
   #       J'initialise les valeurs qui seront mises dans le header
         set formatmotcle(OBJNAME)  "string"
         set formatmotcle(BSS_RA)   "float"
         set formatmotcle(BSS_DEC)  "float"
         set formatmotcle(OBSERVER) "string"
         set formatmotcle(BSS_INST) "string"
         set formatmotcle(BSS_SITE) "string"
         set formatmotcle(DATE-OBS) "string"
         set formatmotcle(EXPTIME)  "float"
         set formatmotcle(BSS_VHEL) "float"
         set formatmotcle(BSS_NORM) "string"
         set formatmotcle(BSS_TELL) "string"
         set formatmotcle(BSS_COSM) "string"

         set commentaire(OBJNAME)  "Object name - updated by Audela BeSS module"
         set commentaire(BSS_RA)   "Updated by Audela BeSS module"
         set commentaire(BSS_DEC)  "Updated by Audela BeSS module"
         set commentaire(OBSERVER) "Updated by Audela BeSS module"
         set commentaire(BSS_INST) "Updated by Audela BeSS module"
         set commentaire(BSS_SITE) "Updated by Audela BeSS module"
         set commentaire(DATE-OBS) "Start. obs. - Updated by Audela BeSS module"
         set commentaire(EXPTIME)  "Total duration - Updated by Audela BeSS module"
         set commentaire(BSS_VHEL) "Updated by Audela BeSS module"
         set commentaire(BSS_NORM) "Updated by Audela BeSS module"
         set commentaire(BSS_TELL) "Updated by Audela BeSS module"
         set commentaire(BSS_COSM) "Updated by Audela BeSS module"

         if {[info exists motCleAModifier]} {
             foreach motcle $motCleAModifier {
                 buf$audace(bufNo) setkwd [list $motcle $parametres($motcle) $formatmotcle($motcle) $commentaire($motcle) ""]
             }

	     #--- Complete les mots clefs vides :
	     set listemotsclef [ buf$audace(bufNo) getkwds ]
	     if { [ lsearch $listemotsclef "BSS_VHEL" ] ==-1 } {
		 buf$audace(bufNo) setkwd [ list BSS_VHEL 0.0 float "Heliocentric velocity at data date" "km/s" ]
	     }
	     if { [ lsearch $listemotsclef "BSS_NORM" ] ==-1 } {
		 buf$audace(bufNo) setkwd [ list BSS_NORM "no" string "Yes or no if normalisation has been done" "" ]
	     }
	     if { [ lsearch $listemotsclef "BSS_COSM" ] ==-1 } {
		 buf$audace(bufNo) setkwd [ list BSS_COSM "no" string "Yes or no if cosmics correction has been done" "" ]
	     }
	     if { [ lsearch $listemotsclef "BSS_TELL" ] ==-1 } {
		 buf$audace(bufNo) setkwd [ list BSS_TELL "no" string "Yes or no if telluric lines has been removed" "" ]
	     }

            #---   Et je sauve le fichier... si le nom de fichier n'est pas vide
            if { $fich_out != ""} {
               set fichier [file root $fich_out]
               append fichier ".fit"
               set okpoursauver 0
               if {[file exists [file join $audace(rep_images) $fichier]]} {
	               set message_erreur $text_bess(FichExiste)
	               if {[tk_messageBox -message $message_erreur -icon warning -type yesno -title $text_bess(probleme)] == "yes"} {
	                  set okpoursauver 1
                  }
               } else {
	               set okpoursauver 1
               }
               if { $okpoursauver == 1 } {
	               buf$audace(bufNo) bitpix float
                   buf$audace(bufNo) save [file join $audace(rep_images) $fich_out]
                   buf$audace(bufNo) bitpix short
                   ChargeFichier $fich_out
               }
             } else {
                set message_erreur $text_bess(FichOutVide)
                tk_messageBox -message $message_erreur -icon warning -type ok -title $text_bess(probleme)
             }
          } else {
#            Message console "Pas besoin de sauver: pas de changements \n"
          }
      } else {
#       Message console "Je ne sauve pas: bugs ! \n"
      }
  }
}
# Fin du namespace bess

#-- BMauclaire - 070619 : ne lance pas la fenetre au chargement de l'ensemble des scripts bess
# ::bess::Principal ""


