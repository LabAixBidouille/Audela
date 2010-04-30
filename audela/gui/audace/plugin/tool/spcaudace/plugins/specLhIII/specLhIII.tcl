#
# Fichier : specLhIII.tcl
# Description : Reduction complete des spectres Lhires III
# Auteur : Fran�ois COCHARD
# Mise a jour $Id: specLhIII.tcl,v 1.5 2010-04-30 15:55:24 robertdelmas Exp $
#

#==============================================================
#   Declaration du Namespace spbmfc
#==============================================================

package provide specLhIII 0.10

namespace eval ::spbmfc {
   variable fichier_log
   variable numero_version
   global audace audela

   #--- Chargement en fonction du numero de la version d'Aud'ACE
   if { [ regexp {1.3.0} $audela(version) match resu ] } {
      set repspc [ file join $audace(rep_scripts) spcaudace ]
      source [ file join $repspc plugins specLhIII specLhIII.cap ]
   } else {
      set repspc [ file join $audace(rep_plugin) tool spcaudace ]
      source [ file join $repspc plugins specLhIII specLhIII.cap ]
   }

   # Num�ro de la version du logiciel
   set numero_version "0.10"

#***** Proc�dure Demarragespbmfc ********************************
   proc Demarragespbmfc { } {
      variable fichier_log
      variable log_id
      variable numero_version
      global panneau

      #--- Si le repertoire .audela n'existe pas, le creer
      set panneau(homeDirectory) [ file join $::env(HOME) .audela ]
      if { ! [ file exist $panneau(homeDirectory) ] } {
         file mkdir $panneau(homeDirectory)
      }

      # Lecture du fichier de configuration
      RecuperationParametres

# 19/08/06 Cr�ation du fichier de log... cette partie doit �tre bascul�e dans l'�x�cution du panneau. Maintenant, c'est � chaque r�duction qu'un fichier de log doit
# �tre cr�� !

#  # Gestion du fichier de log
#  # Creation du nom de fichier log
#       set nom_generique specLhIII
#       # Heure a partir de laquelle on passe sur un nouveau fichier de log
#       if { $::conf(rep_images,refModeAuto) == "0" } {
#          set heure_nouveau_fichier "0"
#       } else {
#          set heure_nouveau_fichier "12"
#       }
#       set heure_courante [lindex [split $audace(tu,format,hmsint) h] 0]
#       if {$heure_courante < $heure_nouveau_fichier} {
#          # Si avant l'heure de changement... Je prends la date de la veille
#          set formatdate [clock format [expr {[clock seconds] - 86400}] -format "%Y-%m-%d"]
#          } else {
#          # Sinon, je prends la date du jour
#          set formatdate [clock format [clock seconds] -format "%Y-%m-%d"]
#          }
#        set fichier_log $audace(rep_images)
#        append fichier_log "/" $nom_generique $formatdate ".log"

#  # Ouverture
#  if {[catch {open $fichier_log a} log_id]} {
#     Message console $caption(specLhIII,pbouvfichcons)
#          tk_messageBox -title $caption(specLhIII,pb) -type ok \
#     -message $caption(specLhIII,pbouvfich)
# # Note importante: Je d�tecte si j'ai un pb � l'ouverture du fichier, mais je ne sais
# # pas traiter ce cas: Il faudrait interdire l'ouverture du panneau, mais le processus
# # est d�j� lanc� � ce stade... Tout ce que je fais, c'est inviter l'utilisateur �
# # changer d'outil !
#          } else {
#          # Ent�te du fichier
#     Message log $caption(specLhIII,ouvsess) $numero_version
#        set date [clock format [clock seconds] -format "%A %d %B %Y"]
#          set heure $audace(tu,format,hmsint)
#     Message log $caption(specLhIII,affheure) $date $heure
#          }
   }
#***** Fin de la proc�dure Demarragespbmfc **********************

#***** Proc�dure Arretspbmfc ************************************
   proc Arretspbmfc { } {
      variable log_id
      global audace caption data_spbmfc panneau

      # Fermeture du fichier de log
      set heure $audace(tu,format,hmsint)
# Je m'assure que le fichier se termine correctement, en particulier pour le cas o� il y
# a eu un probl�me � l'ouverture (C'est un peu une rustine...)
      if {[catch {Message log $caption(specLhIII,finsess) $heure} bug]} {
         Message console $caption(specLhIII,pbfermfichcons)
      } else {
         catch { close $log_id }
      }

      # R�cup�ration de la position de la fen�tre de r�glages
      ::spbmfc::recup_position
      set data_spbmfc(fenetreSpData,position) $panneau(fenetreSpData,position)
      # Sauvegarde des param�tres dans le fichier de config
      SauvegardeParametres
      # Fermeture de la fen�tre de pr�traitement
      destroy $audace(base).fenetreSpData
   }
#***** Fin de la proc�dure Arretspbmfc **************************

#***** Procedure recup_position ********************************
   proc recup_position { } {
      global audace panneau

      set panneau(fenetreSpData,geometry) [ wm geometry $audace(base).fenetreSpData ]
      set deb [ expr 1 + [ string first + $panneau(fenetreSpData,geometry) ] ]
      set fin [ string length $panneau(fenetreSpData,geometry) ]
      set panneau(fenetreSpData,position) "+[string range $panneau(fenetreSpData,geometry) $deb $fin]"
   }
#***** Fin de la procedure recup_position ************************

#***** Proc�dure fenetreSpData ************************************
   proc fenetreSpData { } {
      global audace caption data_spbmfc panneau

      if {[winfo exists $audace(base).fenetreSpData] == 0} {
         Demarragespbmfc

         #---
         if { ! [ info exists data_spbmfc(fenetreSpData,position) ] } { set data_spbmfc(fenetreSpData,position) "+100+5" }

         set panneau(fenetreSpData,position) $data_spbmfc(fenetreSpData,position)

         if { [ info exists panneau(fenetreSpData,geometry) ] } {
            set deb [ expr 1 + [ string first + $panneau(fenetreSpData,geometry) ] ]
            set fin [ string length $panneau(fenetreSpData,geometry) ]
            set panneau(fenetreSpData,position) "+[string range $panneau(fenetreSpData,geometry) $deb $fin]"
         }

         #---
         toplevel $audace(base).fenetreSpData -class Toplevel -borderwidth 2 -relief groove
         wm geometry $audace(base).fenetreSpData $panneau(fenetreSpData,position)
         wm resizable $audace(base).fenetreSpData 1 1
         wm title $audace(base).fenetreSpData $caption(specLhIII,titrelong)

         wm protocol $audace(base).fenetreSpData WM_DELETE_WINDOW ::spbmfc::Arretspbmfc

         creeFenspbmfc
      } else {
         focus $audace(base).fenetreSpData
      }
   }
#***** Fin de la procedure fenetreSpData ******************************

#***** Procedure RecuperationParametres ******************************
   proc RecuperationParametres { } {
      global data_spbmfc panneau

      # Initialisation
      if {[info exists data_spbmfc]} {unset data_spbmfc}
      # Ouverture du fichier de param�tres
      set fichier [file join $panneau(homeDirectory) spdata.ini]
      if {[file exists $fichier]} {source $fichier}
   }
#***** Fin de la procedure RecuperationParametres ******************************

#***** Procedure SauvegardeParametres ******************************
   proc SauvegardeParametres { } {
      global data_spbmfc panneau

      catch {
         set nom_fichier [file join $panneau(homeDirectory) spdata.ini]
         if [catch {open $nom_fichier w} fichier] {
            message console "%s\n" $caption(specLhIII,PbSauveConfig)
         } else {
            foreach {a b} [array get data_spbmfc] {
               puts $fichier "set data_spbmfc($a) \"$b\""
            }
            close $fichier
         }
      }
   }
#***** Fin de la procedure SauvegardeParametres ******************************

# 19/08/06 Toute la partie traitement cosm�tique doit �tre reprise, pour travailler � partir d'un fichier .lst
# #***** Proc�dure rechargeCosm ************************************
#    proc rechargeCosm { } {
#       # Cette proc�dure a pour fonction de recharger le script de correction
#       #    cosm�tique (pour permettre � l'utilisateur de faire du debug sans
#       #    sortir de Audela !
#       global data_spbmfc audace caption

#       # V�rifie validit� du nom du fichier de script
#       if {[TestNomFichier $data_spbmfc(FichScript)] == 0} {
#          tk_messageBox -title $caption(specLhIII,pb) -type ok \
#             -message $caption(specLhIII,pbNomFichScr)
#          } else {
#          # Teste si le fichier de script existe
#          set nomFich $audace(rep_scripts)
#          append nomFich "/" $data_spbmfc(FichScript) ".tcl"
#          if {[file exists $nomFich] == 0} {
#             set integre(cosm) non
#             tk_messageBox -title $caption(specLhIII,pb) -type ok \
#                -message $caption(specLhIII,FichScrAbs)
#             } else {
#             # Alors dans ce cas, je charge le fichier
#             source $nomFich
#             }
#          }
#       }
# #***** Fin de la procedure rechargeCosm ****************************

# #***** Proc�dure goCosm************************************
#    proc goCosm { } {
#       global caption integre

#       # Dans un premier temps, je teste l'int�grit� de l'op�ration
#  testCosm
#       # Si tout est Ok, je lance le traitement
#       if {$integre(cosm) == "oui"} {
#          traiteCosm
#          }
#       }
# #***** Fin de la procedure goCosm******************************

# #***** Proc�dure testCosm************************************
#    proc testCosm { } {
#       global audace caption data_spbmfc integre

#       desactiveBoutons
#       set integre(cosm) oui

#       if {[TestNomFichier $data_spbmfc(procCorr)] == 0} {
#          # Teste si le nom de la proc�dure est Ok (un seul champ, pas de caract�re interdit...)
#          set integre(cosm) non
#          tk_messageBox -title $caption(specLhIII,pb) -type ok \
#             -message $caption(specLhIII,pbProcCorr)
#          } elseif {[info procs $data_spbmfc(procCorr)] == ""} {
#          # Teste si la proc�dure de correction cosm�tique existe
#          # Alors je dois regarder si j'ai de quoi charger le fichier contenant le script
#          # Teste si le nom de fichier est Ok (un seul champ, pas de caract�re interdit...)
#          if {[TestNomFichier $data_spbmfc(FichScript)] == 0} {
#             set integre(cosm) non
#             tk_messageBox -title $caption(specLhIII,pb) -type ok \
#                -message $caption(specLhIII,pbNomFichScr)
#             } else {
#             # Teste si le fichier de script existe
#             set nomFich $audace(rep_scripts)
#             append nomFich "/" $data_spbmfc(FichScript) ".tcl"
#             if {[file exists $nomFich] == 0} {
#                set integre(cosm) non
#                tk_messageBox -title $caption(specLhIII,pb) -type ok \
#                   -message $caption(specLhIII,FichScrAbs)
#                } else {
#                # Alors dans ce cas, je charge le fichier
#                source $nomFich
#                # et je me repose la question de l'existence de la proc�dure:
#                if {[info procs $data_spbmfc(procCorr)] == ""} {
#                   tk_messageBox -title $caption(specLhIII,pb) -type ok \
#                      -message $caption(specLhIII,procCorrIntrouv)
#                   set integre(cosm) non
#                   }
#                }
#             }
#          }
#       activeBoutons
#       }
# #***** Fin de la procedure testCosm******************************

# #***** Proc�dure traiteCosm************************************
#    proc traiteCosm { } {
#       global caption data_spbmfc integre

#       desactiveBoutons
#       # Applique la proc�dure de correction cosm�tique � l'image en cours
#       eval $data_spbmfc(procCorr)
#       activeBoutons
#       }
# #***** Fin de la procedure traiteCosm******************************

#***** Proc�dure goLienBeSS ************************************
   proc goLienBeSS { } {
   }
#***** Fin de la procedure goLienBeSS ******************************

#***** Proc�dure goLienNiveaux ************************************
   proc goLienNiveaux { } {
   }
#***** Fin de la procedure goLienNiveaux ******************************

#***** Proc�dure effacerChampsCalcules ************************************
   proc effacerChampsCalcules { } {
   }
#***** Fin de la procedure effacerChampsCalcules ******************************

#***** Proc�dure cdeEffacerTout ************************************
   proc cdeEffacerTout { } {
   }
#***** Fin de la procedure cdeEffacerTout ******************************

#***** Proc�dure cdeAnnuler ************************************
   proc cdeAnnuler { } {
   }
#***** Fin de la procedure cdeAnnuler ******************************

#***** Proc�dure cdeGo ************************************
   proc cdeGo { } {
   }
#***** Fin de la procedure cdeGo ******************************

#***** Proc�dure cdeEnregistrer ************************************
   proc cdeEnregistrer { } {
   }
#***** Fin de la procedure cdeEnregistrer ******************************

#***** Proc�dure cdeFermer  ************************************
   proc cdeFermer { } {
      ::spbmfc::Arretspbmfc
   }
#***** Fin de la procedure cdeFermer  ******************************

#***** Proc�dure cdeAide ************************************
   proc cdeAide { } {
      ::audace::showHelpPlugin tool [ file join spcaudace plugins specLhIII ] specLhIII.htm
   }
#***** Fin de la procedure cdeAide ******************************

#***** Proc�dure goPrecharge ************************************
   proc goPrecharge { } {
      global caption integre

      # Dans un premier temps, je teste l'int�grit� de l'op�ration
      testPrecharge
      # Si tout est Ok, je lance le traitement
      if {$integre(precharge) == "oui"} {
         traitePrecharge
      }
   }
#***** Fin de la procedure goPrecharge ******************************

#***** Proc�dure testPrecharge ************************************
   proc testPrecharge { } {
      global audace caption data_spbmfc integre

      # Initialisation du drapeau d'integrite
      set integre(precharge) oui

      # Enregistrement de l'extension des fichiers
      set ext $::conf(extension,defaut)

      # Je commence par regarder si la correction cosm�tique est demand�e...
      if {$data_spbmfc(cosmPrech) == 1} {
         # Alors je teste si la d�finition de la correction cosm�tique est Ok
         testCosm
         if {$integre(cosm) != "oui"} {
            set integre(precharge) non
            return
         }
      }

      desactiveBoutons

      # Teste si le nom de fichier source est Ok (un seul champ, pas de caract�re interdit...)
      if {[TestNomFichier $data_spbmfc(nmObj)] == 0} {
         set integre(precharge) non
         tk_messageBox -title $caption(specLhIII,pb) -type ok \
            -message $caption(specLhIII,pbNomPrechSrce)
      } elseif {[TestNomFichier $data_spbmfc(nmPrechRes)] == 0} {
         # Teste si le nom de fichier r�sultant est Ok (un seul champ, pas de caract�re interdit...)
         set integre(noir) non
         tk_messageBox -title $caption(specLhIII,pb) -type ok \
            -message $caption(specLhIII,pbNomPrechRes)
      } elseif {[TestEntier $data_spbmfc(nbPrech)] == 0} {
         # Teste si le nombre est Ok
         set integre(precharge) non
         tk_messageBox -title $caption(specLhIII,pb) -type ok \
            -message $caption(specLhIII,pbNbPrech)
      } else {
         # Teste si les fichiers sources existent
         for {set i 1} {$i <= $data_spbmfc(nbPrech)} {incr i} {
            set nomFich $audace(rep_images)
            append nomFich "/" $data_spbmfc(nmObj) $i $ext
            if {[file exists $nomFich] == 0} {
               set integre(precharge) non
            }
         }
         if {$integre(precharge) == "non"} {
            tk_messageBox -title $caption(specLhIII,pb) -type ok \
               -message $caption(specLhIII,fichPrechAbs)
         } else {
            # Teste si le fichier r�sultant existe d�ja
            set nomFich $audace(rep_images)
            append nomFich "/" $data_spbmfc(nmPrechRes) $ext
            if {[file exists $nomFich] == 1} {
               set confirmation [tk_messageBox -title $caption(specLhIII,conf) -type yesno \
                  -message $caption(specLhIII,fichPrechResDeja)]
               if {$confirmation == "no" } {
                  set integre(precharge) non
                  activeBoutons
                  return
               }
            }
            # Dans le cas o� le filtrage est demand�, je v�rifie que le nb est valide
            if {$data_spbmfc(medFiltree) == 1} {
               if {[TestEntier $data_spbmfc(filtrage)] == 0} {
                  tk_messageBox -title $caption(specLhIII,pb) -type ok \
                     -message $caption(specLhIII,pbNbFiltrage)
                  set integre(precharge) non
               }
            }
         }
      }
      activeBoutons
   }
#***** Fin de la procedure testPrecharge ******************************

#***** Proc�dure traitePrecharge ************************************
   proc traitePrecharge { } {
      global audace caption data_spbmfc integre

      focus $audace(base)
      focus $audace(Console)

      desactiveBoutons
      # Affichage du message de d�marrage du pr�traitement des noirs
      Message consolog $caption(specLhIII,debPrech)

      # Enregistrement de l'extension des fichiers
      set ext $::conf(extension,defaut)

      if {$data_spbmfc(cosmPrech) == 1} {
         # Dans le cas o� la correction cosm�tique est demand�e
         Message consolog $caption(specLhIII,lanceCosmPrech)
         for {set i 1} {$i <= $data_spbmfc(nbPrech)} {incr i} {
            set instr "loadima $data_spbmfc(nmObj)$i"
            Message consolog $instr
            Message consolog "\n"
            eval $instr
            set instr "eval $data_spbmfc(procCorr)"
            Message consolog $instr
            Message consolog "\n"
            eval $instr
            set instr "saveima $data_spbmfc(nmObj)$i"
            Message consolog $instr
            Message consolog "\n"
            eval $instr
         }
      }
      # Affichage de la premi�re image de noir
      set nomFich $data_spbmfc(nmObj)
      append nomFich "1"
      Message consolog $caption(specLhIII,chargPremPrech)
      set instr "loadima "
      append instr $nomFich
      Message consolog $instr
      Message consolog "\n"
      eval $instr

      # Calcul de la m�diane des images
      set instr "smedian $data_spbmfc(nmObj) $data_spbmfc(nmPrechRes) $data_spbmfc(nbPrech)"
      Message consolog $caption(specLhIII,CalcMedPrech)
      Message consolog $instr
      Message consolog "\n"
      eval $instr

      # Op�ration �ventuelle de filtrage
      if {$data_spbmfc(medFiltree) == 1} {
         Message consolog $caption(specLhIII,filtrage)
         set taille $data_spbmfc(filtrage)
         set instr "ttscript2 \"IMA/SERIES \"$audace(rep_images)\" \"$data_spbmfc(nmPrechRes)\" . . \"$ext\" \
            \"$audace(rep_images)\" \"$data_spbmfc(nmPrechRes)\" . \"$ext\" FILTER threshold=0 type_threshold=0 \
            kernel_width=$taille kernel_type=fb kernel_coef=0 nullpixel=-5000 \""
         Message consolog $instr
         Message consolog "\n"
         eval $instr
      }

      # Affichage de l'image de pr�charge r�sultante
      set nomFich $data_spbmfc(nmPrechRes)
      Message consolog $caption(specLhIII,chargPrechRes)
      set instr "loadima $nomFich"
      Message consolog $instr
      Message consolog "\n"
      eval $instr

      # Affichage du message de fin du pr�traitement de la pr�charge
      Message consolog $caption(specLhIII,finPrech)

      activeBoutons
      focus $audace(base).fenetreSpData
   }
#***** Fin de la procedure traitePrecharge ******************************

#***** Proc�dure goNoir ************************************
   proc goNoir { } {
      global caption integre

      # Dans un premier temps, je teste l'int�grit� de l'op�ration
      testNoir
      # Si tout est Ok, je lance le traitement
      if {$integre(noir) == "oui"} {
         traiteNoir
      }
   }
#***** Fin de la procedure goNoir ******************************

#***** Proc�dure testNoir ************************************
   proc testNoir { } {
      global audace caption data_spbmfc integre

      # Initialisation du drapeau d'integrite
      set integre(noir) oui

      # Enregistrement de l'extension des fichiers
      set ext $::conf(extension,defaut)

      # Je commence par regarder si la correction cosm�tique est demand�e...
      if {$data_spbmfc(cosmNoir) == 1} {
         # Alors je teste si la d�finition de la correction cosm�tique est Ok
         testCosm
         if {$integre(cosm) != "oui"} {
            set integre(noir) non
            return
         }
      }

      desactiveBoutons

      # Teste si le nom de fichier source est Ok (un seul champ, pas de caract�re interdit...)
      if {[TestNomFichier $data_spbmfc(nmNrSce)] == 0} {
         set integre(noir) non
         tk_messageBox -title $caption(specLhIII,pb) -type ok \
            -message $caption(specLhIII,pbNomNoirSrce)
      } elseif {[TestNomFichier $data_spbmfc(nmNoirRes)] == 0} {
         # Teste si le nom de fichier r�sultant est Ok (un seul champ, pas de caract�re interdit...)
         set integre(noir) non
         tk_messageBox -title $caption(specLhIII,pb) -type ok \
            -message $caption(specLhIII,pbNomNoirRes)
      } elseif {[TestEntier $data_spbmfc(nbNoirs)] == 0} {
         # Teste si le nombre est Ok
         set integre(noir) non
         tk_messageBox -title $caption(specLhIII,pb) -type ok \
            -message $caption(specLhIII,pbNbNr)
      } else {
         # Teste si les fichiers sources existent
         for {set i 1} {$i <= $data_spbmfc(nbNoirs)} {incr i} {
            set nomFich $audace(rep_images)
            append nomFich "/" $data_spbmfc(nmNrSce) $i $ext
            if {[file exists $nomFich] == 0} {
               set integre(noir) non
            }
         }
         if {$integre(noir) == "non"} {
            tk_messageBox -title $caption(specLhIII,pb) -type ok \
               -message $caption(specLhIII,fichNoirAbs)
         } else {
            # Teste si le fichier r�sultant existe d�ja
            set nomFich $audace(rep_images)
            append nomFich "/" $data_spbmfc(nmNoirRes) $ext
            if {[file exists $nomFich] == 1} {
               set confirmation [tk_messageBox -title $caption(specLhIII,conf) -type yesno \
                  -message $caption(specLhIII,fichNoirResDeja)]
               if {$confirmation == "no" } {
                  set integre(noir) non
               }
            }
         }
      }
      activeBoutons
   }
#***** Fin de la procedure testNoir ******************************

#***** Proc�dure traiteNoir ************************************
   proc traiteNoir { } {
      global audace caption data_spbmfc integre

      focus $audace(base)
      focus $audace(Console)

      desactiveBoutons
      # Affichage du message de d�marrage du pr�traitement des noirs
      Message consolog $caption(specLhIII,debNoir)

      if {$data_spbmfc(cosmNoir) == 1} {
         # Dans le cas o� la correction cosm�tique est demand�e
         Message consolog $caption(specLhIII,lanceCosmNoir)
         for {set i 1} {$i <= $data_spbmfc(nbNoirs)} {incr i} {
            set instr "loadima $data_spbmfc(nmNrSce)$i"
            Message consolog $instr
            Message consolog "\n"
            eval $instr
            set instr "eval $data_spbmfc(procCorr)"
            Message consolog $instr
            Message consolog "\n"
            eval $instr
            set instr "saveima $data_spbmfc(nmNrSce)$i"
            Message consolog $instr
            Message consolog "\n"
            eval $instr
         }
      }
      # Affichage de la premi�re image de noir
      set nomFich $data_spbmfc(nmNrSce)
      append nomFich "1"
      Message consolog $caption(specLhIII,chargPremNoir)
      set instr "loadima "
      append instr $nomFich
      Message consolog $instr
      Message consolog "\n"
      eval $instr

      # Calcul de la m�diane des images
      set instr "smedian $data_spbmfc(nmNrSce) $data_spbmfc(nmNoirRes) $data_spbmfc(nbNoirs)"
      Message consolog $caption(specLhIII,CalcMedNoir)
      Message consolog $instr
      Message consolog "\n"
      eval $instr

      # Affichage de l'image noire r�sultante
      set nomFich $data_spbmfc(nmNoirRes)
      Message consolog $caption(specLhIII,chargNoirRes)
      set instr "loadima $nomFich"
      Message consolog $instr
      Message consolog "\n"
      eval $instr

      # Affichage du message de fin du pr�traitement des noirs
      Message consolog $caption(specLhIII,finNoir)

      activeBoutons
      focus $audace(base).fenetreSpData
   }
#***** Fin de la procedure traiteNoir ******************************

#***** Proc�dure goNoirDePLU ************************************
   proc goNoirDePLU { } {
      global caption integre

      # Dans un premier temps, je teste l'int�grit� de l'op�ration
      testNoirDePLU
      # Si tout est Ok, je lance le traitement
      if {$integre(noir_PLU) == "oui"} {
         traiteNoirDePLU
      }
   }
#***** Fin de la procedure goNoirDePLU ******************************

#***** Proc�dure testNoirDePLU ************************************
   proc testNoirDePLU { } {
      global audace caption data_spbmfc integre

      # Initialisation du drapeau d'integrite
      set integre(noir_PLU) oui

      # Enregistrement de l'extension des fichiers
      set ext $::conf(extension,defaut)

      # Je commence par regarder si la correction cosm�tique est demand�e...
      if {$data_spbmfc(cosmNrPLU) == 1} {
         # Alors je teste si la d�finition de la correction cosm�tique est Ok
         testCosm
         if {$integre(cosm) != "oui"} {
            set integre(noir_PLU) non
            return
         }
      }

      desactiveBoutons

      # Teste si le nom de fichier source est Ok (un seul champ, pas de caract�re interdit...)
      if {[TestNomFichier $data_spbmfc(nmNrPLUSce)] == 0} {
         set integre(noir_PLU) non
         tk_messageBox -title $caption(specLhIII,pb) -type ok \
            -message $caption(specLhIII,pbNomNrPLUSrce)
      } elseif {[TestNomFichier $data_spbmfc(nmNrPLURes)] == 0} {
         # Teste si le nom de fichier r�sultant est Ok (un seul champ, pas de caract�re interdit...)
         set integre(noir_PLU) non
         tk_messageBox -title $caption(specLhIII,pb) -type ok \
            -message $caption(specLhIII,pbNomNrPLURes)
      } elseif {[TestEntier $data_spbmfc(nbNrPLU)] == 0} {
         # Teste si le nombre est Ok
         set integre(noir_PLU) non
         tk_messageBox -title $caption(specLhIII,pb) -type ok \
            -message $caption(specLhIII,pbNbNrPLU)
      } else {
         # Teste si les fichiers sources existent
         for {set i 1} {$i <= $data_spbmfc(nbNrPLU)} {incr i} {
            set nomFich $audace(rep_images)
            append nomFich "/" $data_spbmfc(nmNrPLUSce) $i $ext
            if {[file exists $nomFich] == 0} {
               set integre(noir_PLU) non
            }
         }
         if {$integre(noir_PLU) == "non"} {
            tk_messageBox -title $caption(specLhIII,pb) -type ok \
               -message $caption(specLhIII,fichNrPLUAbs)
         } else {
            # Teste si le fichier r�sultant existe d�ja
            set nomFich $audace(rep_images)
            append nomFich "/" $data_spbmfc(nmNrPLURes) $ext
            if {[file exists $nomFich] == 1} {
               set confirmation [tk_messageBox -title $caption(specLhIII,conf) -type yesno \
                  -message $caption(specLhIII,fichNrPLUResDeja)]
               if {$confirmation == "no" } {
                  set integre(noir_PLU) non
               }
            }
         }
      }
      activeBoutons
   }
#***** Fin de la procedure testNoirDePLU ******************************

#***** Proc�dure traiteNoirDePLU ************************************
   proc traiteNoirDePLU { } {
      global audace caption data_spbmfc integre

      focus $audace(base)
      focus $audace(Console)

      desactiveBoutons
      # Affichage du message de d�marrage du pr�traitement des noir de PLU
      Message consolog $caption(specLhIII,debNrPLU)

      if {$data_spbmfc(cosmNrPLU) == 1} {
         # Dans le cas o� la correction cosm�tique est demand�e
         Message consolog $caption(specLhIII,cosmNoirDePLU)
         for {set i 1} {$i <= $data_spbmfc(nbNrPLU)} {incr i} {
            set instr "loadima $data_spbmfc(nmNrPLUSce)$i"
            Message consolog $instr
            Message consolog "\n"
            eval $instr
            set instr "eval $data_spbmfc(procCorr)"
            Message consolog $instr
            Message consolog "\n"
            eval $instr
            set instr "saveima $data_spbmfc(nmNrPLUSce)$i"
            Message consolog $instr
            Message consolog "\n"
            eval $instr
         }
      }

      # Affichage de la premi�re image de noir de PLU
      set nomFich $data_spbmfc(nmNrPLUSce)
      append nomFich "1"
      Message consolog $caption(specLhIII,chargPremNrPLU)
      set instr "loadima $nomFich"
      Message consolog $instr
      Message consolog "\n"
      eval $instr

      # Calcul de la m�diane des images
      set instr "smedian $data_spbmfc(nmNrPLUSce) $data_spbmfc(nmNrPLURes) $data_spbmfc(nbNrPLU)"
      Message consolog $caption(specLhIII,CalcMedNrPLU)
      Message consolog $instr
      Message consolog "\n"
      eval $instr

      # Affichage de l'image de noir de PLU r�sultante
      set nomFich $data_spbmfc(nmNrPLURes)
      Message consolog $caption(specLhIII,chargNrPLURes)
      set instr "loadima $nomFich"
      Message consolog $instr
      Message consolog "\n"
      eval $instr

      # Affichage du fin de d�marrage du pr�traitement des noirs de PLU
      Message consolog $caption(specLhIII,finNrPLU)
      activeBoutons
      focus $audace(base).fenetreSpData
   }
#***** Fin de la procedure traiteNoirDePLU ******************************

#***** Proc�dure goPLU ************************************
   proc goPLU { } {
      global caption integre

      # Dans un premier temps, je teste l'int�grit� de l'op�ration
      testPLU
      # Si tout est Ok, je lance le traitement
      if {$integre(PLU) == "oui"} {
         traitePLU
      }
   }
#***** Fin de la procedure goPLU ******************************

#***** Proc�dure testPLU ************************************
   proc testPLU { } {
      global audace caption data_spbmfc integre

      # Initialisation du drapeau d'integrite
      set integre(PLU) oui

      # Enregistrement de l'extension des fichiers
      set ext $::conf(extension,defaut)

      # Je commence par regarder si la correction cosm�tique est demand�e...
      if {$data_spbmfc(cosmPLU) == 1} {
         # Alors je teste si la d�finition de la correction cosm�tique est Ok
         testCosm
         if {$integre(cosm) != "oui"} {
            set integre(PLU) non
            return
         }
      }
      desactiveBoutons
      set data_spbmfc(fich_pour_PLU_ok) non
      set data_spbmfc(noir_de_PLU_a_faire_pl) non
      set data_spbmfc(precharge_a_faire_pl) non
      set data_spbmfc(noir_a_faire_pl) non

      # Teste si le nom de fichier source est Ok (un seul champ, pas de caract�re interdit...)
      if {[TestNomFichier $data_spbmfc(nmPLUSce)] == 0} {
         set integre(PLU) non
         tk_messageBox -title $caption(specLhIII,pb) -type ok \
            -message $caption(specLhIII,pbNomPLUSrce)
      } elseif {[TestNomFichier $data_spbmfc(nmPLURes)] == 0} {
         # Teste si le nom de fichier r�sultant est Ok (un seul champ, pas de caract�re interdit...)
         set integre(PLU) non
         tk_messageBox -title $caption(specLhIII,pb) -type ok \
            -message $caption(specLhIII,pbNomPLURes)
      } elseif {[TestEntier $data_spbmfc(nbPLU)] == 0} {
         # Teste si le nombre est Ok
         set integre(PLU) non
         tk_messageBox -title $caption(specLhIII,pb) -type ok \
            -message $caption(specLhIII,pbNbPLU)
      } else {
         # Teste si les fichiers sources existent
         for {set i 1} {$i <= $data_spbmfc(nbPLU)} {incr i} {
            set nomFich $audace(rep_images)
            append nomFich "/" $data_spbmfc(nmPLUSce) $i $ext
            if {[file exists $nomFich] == 0} {
               set integre(PLU) non
            }
         }
         if {$integre(PLU) == "non"} {
            tk_messageBox -title $caption(specLhIII,pb) -type ok \
               -message $caption(specLhIII,fichPLUAbs)
         } else {
            # Teste si le fichier r�sultant existe d�ja
            set nomFich $audace(rep_images)
            append nomFich "/" $data_spbmfc(nmPLURes) $ext
            if {[file exists $nomFich] == 1} {
               set confirmation [tk_messageBox -title $caption(specLhIII,conf) -type yesno \
                  -message $caption(specLhIII,fichPLUResDeja)]
               if {$confirmation == "no"} {
                  set integre(PLU) non
                  activeBoutons
                  return
               }
            }
            if {$data_spbmfc(modePLU) == "simple"} {
               # A partir de l�, c'est selon le mode de traitement de la PLU retenue
               # Teste si le fichier de noir de PLU existe bien
               set nomFich $audace(rep_images)
               append nomFich "/" $data_spbmfc(nmNrPLURes) $ext
               if {[file exists $nomFich] == 0} {
                  testNoirDePLU
                  if {$integre(noir_PLU) == "non"} {
                     tk_messageBox -title $caption(specLhIII,pb) -type ok \
                        -message $caption(specLhIII,fichNrPLUPLUAbs)
                     set integre(PLU) non
                     set data_spbmfc(fich_pour_PLU_ok) non
                  } else {
                     # J'ai tout pour faire le noir de PLU
                     set data_spbmfc(fich_pour_PLU_ok) oui
                     # Alors je m�morise que je dois le faire
                     set data_spbmfc(noir_de_PLU_a_faire_pl) oui
                  }
               } else {
                  set data_spbmfc(fich_pour_PLU_ok) oui
               }
            } elseif {$data_spbmfc(modePLU) != ""} {
               # Dans ce cas, on a choisit les options rapp tps pose ou optimisation
               # Teste si le fichier de pr�charge existe bien
               set nomFich $audace(rep_images)
               append nomFich "/" $data_spbmfc(nmPrechRes) $ext
               if {[file exists $nomFich] == 0} {
                  testPrecharge
                  if {$integre(precharge) == "non"} {
                     tk_messageBox -title $caption(specLhIII,pb) -type ok \
                        -message $caption(specLhIII,fichPrechPLUAbs)
                     set integre(PLU) non
                     set data_spbmfc(fich_pour_PLU_ok) non
                  } else {
                     # J'ai tout pour faire la pr�charge
                     set data_spbmfc(fich_pour_PLU_ok) oui
                     # Alors je m�morise que je dois le faire
                     set data_spbmfc(precharge_a_faire_pl) oui
                  }
               } else {
                   set data_spbmfc(fich_pour_PLU_ok) oui
               }
               if {$data_spbmfc(fich_pour_PLU_ok) == "oui"} {
                  # Teste si le fichier de noir existe bien
                  set nomFich $audace(rep_images)
                  append nomFich "/" $data_spbmfc(nmNoirRes) $ext
                  if {[file exists $nomFich] == 0} {
                     testNoir
                     if {$integre(noir) == "non"} {
                        tk_messageBox -title $caption(specLhIII,pb) -type ok \
                           -message $caption(specLhIII,fichNrtoPLUAbs)
                        set integre(PLU) non
                        set data_spbmfc(fich_pour_PLU_ok) non
                     } else {
                        # J'ai tout pour faire le noir
                        set data_spbmfc(fich_pour_PLU_ok) oui
                        # Alors je m�morise que je dois le faire
                        set data_spbmfc(noir_a_faire_pl) oui
                     }
                  } else {
                     set data_spbmfc(fich_pour_PLU_ok) oui
                  }
               }
            } else {
               # V�rifie qu'un mode de traitement est bien s�lectionn�
               tk_messageBox -title $caption(specLhIII,pb) -type ok \
                  -message $caption(specLhIII,choisir_mode_PLU)
               set integre(PLU) non
            }
         }
      }
      activeBoutons
   }
#***** Fin de la procedure testPLU ******************************

#***** Proc�dure traitePLU ************************************
   proc traitePLU { } {
      global audace caption data_spbmfc integre

      if {$data_spbmfc(noir_de_PLU_a_faire_pl) == "oui"} {
         traiteNoirDePLU
      }
      if {$data_spbmfc(precharge_a_faire_pl) == "oui"} {
         traitePrecharge
      }
      if {$data_spbmfc(noir_a_faire_pl) == "oui"} {
         traiteNoir
      }

      focus $audace(base)
      focus $audace(Console)
      update idletasks

      # Enregistrement de l'extension des fichiers
      set ext $::conf(extension,defaut)

      desactiveBoutons

      # Affichage du message de d�marrage du pr�traitement des noirs
      Message consolog $caption(specLhIII,debPLU)
      switch -exact $data_spbmfc(modePLU) {
         simple {
            Message consolog $caption(specLhIII,ModePLUSimple)
         }
         rapTps {
            Message consolog $caption(specLhIII,ModePLURapTps)
         }
         opt {
            Message consolog $caption(specLhIII,ModePLUOpt)
         }
      }

      if {$data_spbmfc(cosmPLU) == 1} {
         # Dans le cas o� la correction cosm�tique est demand�e
         Message consolog $caption(specLhIII,lanceCosmPLU)
         for {set i 1} {$i <= $data_spbmfc(nbPLU)} {incr i} {
            set instr "loadima $data_spbmfc(nmPLUSce)$i"
            Message consolog "%s\n" $instr
            eval $instr
            set instr "eval $data_spbmfc(procCorr)"
            Message consolog "%s\n" $instr
            eval $instr
            set instr "saveima $data_spbmfc(nmPLUSce)$i"
            Message consolog "%s\n" $instr
            eval $instr
         }
      }

      # Affichage de la premi�re image de PLU
      set nomFich $data_spbmfc(nmPLUSce)
      append nomFich "1"
      Message consolog $caption(specLhIII,chargPremPLU)
      set instr "loadima $nomFich"
      Message consolog "%s\n" $instr
      eval $instr

      # Traitement proprement dit des PLU, selon le mode choisi
      switch -exact $data_spbmfc(modePLU) {
         simple {
            # Soustraction du noir de PLU de chaque image de PLU
            set instr "sub2 $data_spbmfc(nmPLUSce) $data_spbmfc(nmNrPLURes) $data_spbmfc(nmPLUSce)"
            append instr "_moinsnoir_ 0 $data_spbmfc(nbPLU)"
            Message consolog $caption(specLhIII,SoustrNrPLUPLU)
            Message consolog "%s\n" $instr
            eval $instr
         }
         rapTps {
            # Lecture du temps de pose de l'image PLU
            # Je v�rifie que le champ exposure est bien pr�sent dans l'ent�te FITS
            if {[lsearch [buf$audace(bufNo) getkwds] EXPOSURE] != -1} {
               set motCle EXPOSURE
            } else {
               set motCle EXPTIME
            }
            set instr "set temps_plu [lindex [buf$audace(bufNo) getkwd $motCle] 1]"
            Message consolog $caption(specLhIII,LitTpsPLU)
            Message consolog "%s\n" $instr
            eval $instr
            # Chargement de l'image de noir
            set instr "loadima $data_spbmfc(nmNoirRes)"
            Message consolog $caption(specLhIII,ChargeNoir)
            Message consolog "%s\n" $instr
            eval $instr
            # Lecture du temps de pose du noir
            # Je v�rifie que le champ exposure est bien pr�sent dans l'ent�te FITS
            if {[lsearch [buf$audace(bufNo) getkwds] EXPOSURE] != -1} {
               set motCle EXPOSURE
            } else {
               set motCle EXPTIME
            }
            set instr "set temps_noir [lindex [buf$audace(bufNo) getkwd $motCle] 1]"
            Message consolog $caption(specLhIII,LitTpsNoir)
            Message consolog "%s\n" $instr
            eval $instr
            # Calcul du rapport de temps entre noir et PLU
            set instr "set rapport [expr double($temps_plu) / double($temps_noir)]"
            Message consolog $caption(specLhIII,calcRapp)
            Message consolog "%s\n" $instr
            eval $instr
            # Retire l'offset du noir (si besoin)
            if {$data_spbmfc(NrContientPrech) == 1} {
               set instr "sub $data_spbmfc(nmPrechRes) 0"
               Message consolog $caption(specLhIII,soustrPrechDuNoir)
               Message consolog "%s\n" $instr
               eval $instr
            }
            # Multiplie le noir par le rapport de tps d'exp.
            set instr "mult $rapport"
            Message consolog $caption(specLhIII,multNoir)
            Message consolog "%s\n" $instr
            eval $instr
            # Sauvegarde le noir pond�r�
            set instr "saveima noir_pondere_temp"
            Message consolog $caption(specLhIII,SauveNoirPond)
            Message consolog "%s\n" $instr
            eval $instr
            # Retire l'offset de toutes les images de PLU
            set nom_fich $data_spbmfc(nmPLUSce)
            append nom_fich "_moinsnoir_"
            set instr "sub2 $data_spbmfc(nmPLUSce) $data_spbmfc(nmPrechRes) $nom_fich 0 $data_spbmfc(nbPLU)"
            Message consolog $caption(specLhIII,SoustrPrechPLUProv)
            Message consolog "%s\n" $instr
            eval $instr
            # Retire le noir pond�r� de toutes les images de PLU
            set instr "sub2 $nom_fich noir_pondere_temp $nom_fich 0 $data_spbmfc(nbPLU)"
            Message consolog $caption(specLhIII,SoustrNoirPondPLU)
            Message consolog "%s\n" $instr
            eval $instr
         }
         opt {
            if {$data_spbmfc(NrContientPrech) == 0} {
               # Chargement de l'image de noir
               set instr "loadima $data_spbmfc(nmNoirRes)"
               Message consolog $caption(specLhIII,ChargeNoir)
               Message consolog "%s\n" $instr
               eval $instr
               # Addition de la pr�charge
               set instr "add $data_spbmfc(nmPrechRes) 0"
               Message consolog $caption(specLhIII,ajoutePrechNoir)
               Message consolog "%s\n" $instr
               eval $instr
               # Sauvegarde le noir contenant la pr�charge
               set instr "saveima noir_avec_prech"
               Message consolog $caption(specLhIII,SauveNoirAvecPrech)
               Message consolog "%s\n" $instr
               eval $instr
               # Astuce pour traiter correctement les fichiers de noir...
               set noir_avec_prech noir_avec_prech
            } else {
               # Suite et fin de l'astuce pour traiter correctement les fichiers de noir...
               set noir_avec_prech $data_spbmfc(nmNoirRes)
            }
            set nom_fich_sortie $data_spbmfc(nmPLUSce)
            append nom_fich_sortie "_moinsnoir_"
            set instr "opt2 $data_spbmfc(nmPLUSce) $noir_avec_prech $data_spbmfc(nmPrechRes) \
               $nom_fich_sortie $data_spbmfc(nbPLU)"
            Message consolog $caption(specLhIII,OptPLU)
            Message consolog "%s\n" $instr
            eval $instr
         }
      }

      # Affichage de la premi�re image de PLU, corrig�e du noir
      set nomFich $data_spbmfc(nmPLUSce)
      append nomFich "_moinsnoir_1"
      Message consolog $caption(specLhIII,chargPremPLUCorrNrPLU)
      set instr "loadima "
      append instr $nomFich
      Message consolog "%s\n" $instr
      eval $instr

      # Calcul de la valeur moyenne de la premi�re image:
      set instr "set valMoyenne \[lindex \[stat\] 4\]"
      Message consolog $caption(specLhIII,calcMoyPremIm)
      Message consolog "%s\n" $instr
      eval $instr

      # Mise au m�me niveau de tous les PLU
      set instr "ngain2 "
      append instr $data_spbmfc(nmPLUSce)
      append instr "_moinsnoir_ "
      append instr $data_spbmfc(nmPLUSce)
      append instr "_auniveau " $valMoyenne " " $data_spbmfc(nbPLU)
      Message consolog $caption(specLhIII,MiseNiveauPLU)
      Message consolog "%s\n" $instr
      eval $instr

      # Calcul de la m�diane des images
      set instr "smedian "
      append instr $data_spbmfc(nmPLUSce)
      append instr _auniveau " " $data_spbmfc(nmPLURes) " " $data_spbmfc(nbPLU)
      Message consolog $caption(specLhIII,CalcMedPLU)
      Message consolog "%s\n" $instr
      eval $instr

      # Affichage de l'image noire r�sultante
      set nomFich $data_spbmfc(nmPLURes)
      Message consolog $caption(specLhIII,chargPLURes)
      set instr "loadima $nomFich"
      Message consolog "%s\n" $instr
      eval $instr

      # Effacement du disque des images g�n�r�es par le pr�traitement:
      Message consolog $caption(specLhIII,effacePLUInter)
      for {set i 1} {$i <= $data_spbmfc(nbPLU)} {incr i} {
         set nomFich $audace(rep_images)
         append nomFich "/" $data_spbmfc(nmPLUSce) "_moinsnoir_" $i $ext
         file delete $nomFich
         set nomFich $audace(rep_images)
         append nomFich "/" $data_spbmfc(nmPLUSce) "_auniveau" $i $ext
         file delete $nomFich
      }
      set nomFich $audace(rep_images)
      append nomFich "/" "noir_pondere_temp$ext"
      if {[file exists $nomFich]} {
         file delete $nomFich
      }
      set nomFich $audace(rep_images)
      append nomFich "/" "noir_avec_prech$ext"
      if {[file exists $nomFich]} {
         file delete $nomFich
      }

      # Affichage du message de fin du pr�traitement des noirs
      Message consolog $caption(specLhIII,finPLU)
      activeBoutons
      focus $audace(base).fenetreSpData
   }
#***** Fin de la procedure traitePLU ******************************

#***** Proc�dure goBrut ************************************
   proc goBrut { } {
      global caption integre

      # Dans un premier temps, je teste l'int�grit� de l'op�ration
      testBrut
      # Si tout est Ok, je lance le traitement
      if {$integre(brut) == "oui"} {
         traiteBrut
      }
   }
#***** Fin de la procedure goBrut ******************************

#***** Proc�dure testBrut ************************************
   proc testBrut { } {
      global audace caption data_spbmfc integre

      # Initialisation du drapeau d'integrite
      set integre(brut) oui

      # Enregistrement de l'extension des fichiers
      set ext $::conf(extension,defaut)

      # Je commence par regarder si la correction cosm�tique est demand�e...
      if {$data_spbmfc(cosmBrut) == 1} {
         # Alors je teste si la d�finition de la correction cosm�tique est Ok
         testCosm
         if {$integre(cosm) != "oui"} {
            set integre(brut) non
            return
         }
      }
      desactiveBoutons
      set data_spbmfc(noir_a_faire_br) non
      set data_spbmfc(PLU_a_faire_br) non
      set data_spbmfc(precharge_a_faire_br) non
      set data_spbmfc(noir_ok) non
      set data_spbmfc(PLU_ok) non
      set data_spbmfc(precharge_ok) non

      # Teste si le nom de fichier source est Ok (un seul champ, pas de caract�re interdit...)
      if {[TestNomFichier $data_spbmfc(nmBrutSce)] == 0} {
         set integre(brut) non
         tk_messageBox -title $caption(specLhIII,pb) -type ok \
            -message $caption(specLhIII,pbNomBrutSrce)
      } elseif {[TestNomFichier $data_spbmfc(nmBrutRes)] == 0} {
         # Teste si le nom de fichier r�sultant est Ok (un seul champ, pas de caract�re interdit...)
         set integre(brut) non
         tk_messageBox -title $caption(specLhIII,pb) -type ok \
            -message $caption(specLhIII,pbNomBrutRes)
      } elseif {[TestEntier $data_spbmfc(nbBrut)] == 0} {
         # Teste si le nombre est Ok
         set integre(brut) non
         tk_messageBox -title $caption(specLhIII,pb) -type ok \
            -message $caption(specLhIII,pbNbBrut)
      } else {
         # Teste si les fichiers sources existent
         for {set i 1} {$i <= $data_spbmfc(nbBrut)} {incr i} {
            set nomFich $audace(rep_images)
            append nomFich "/" $data_spbmfc(nmBrutSce) $i $ext
            if {[file exists $nomFich] == 0} {
               set integre(brut) non
            }
         }
         if {$integre(brut) == "non"} {
            tk_messageBox -title $caption(specLhIII,pb) -type ok \
               -message $caption(specLhIII,fichBrutAbs)
         } else {
            # Teste si le fichier de noir existe bien
            set nomFich $audace(rep_images)
            append nomFich "/" $data_spbmfc(nmNoirRes) $ext
            if {[file exists $nomFich] == 0} {
               # Dans ce cas, je regarde si je peux calculer le noir...
               testNoir
               if {$integre(noir) == "non"} {
                  # Je n'ai pas les �l�ments pour faire le noir
                  tk_messageBox -title $caption(specLhIII,pb) -type ok \
                     -message $caption(specLhIII,fichNoirBrutAbs)
                  set integre(brut) non
                  set data_spbmfc(noir_ok) non
               } else {
                  # Alors je dois pr�voir de faire le calcul du noir pendant le traitement
                  set data_spbmfc(noir_a_faire_br) oui
                  # Et je memorise que c'est Ok pour les noirs
                  set data_spbmfc(noir_ok) oui
               }
            } else {
               set data_spbmfc(noir_ok) oui
            }
            if {$data_spbmfc(noir_ok) == "oui"} {
               # Teste si le fichier de PLU existe bien
               set nomFich $audace(rep_images)
               append nomFich "/" $data_spbmfc(nmPLURes) $ext
               if {[file exists $nomFich] == 0} {
                  # Dans ce cas, je regarde si je peux calculer le PLU...
                  testPLU
                  if {$integre(PLU) == "non"} {
                  # Je n'ai pas les �l�ments pour faire le PLU
                     tk_messageBox -title $caption(specLhIII,pb) -type ok \
                        -message $caption(specLhIII,fichPLUBrutAbs)
                     set integre(brut) non
                     set data_spbmfc(PLU_ok) non
                  } else {
                     # Alors je dois pr�voir de faire le calcul du PLU pendant le traitement
                     set data_spbmfc(PLU_a_faire_br) oui
                     set data_spbmfc(PLU_ok) oui
                  }
               } else {
                  set data_spbmfc(PLU_ok) oui
               }
            }
            if {$data_spbmfc(PLU_ok) == "oui" && $data_spbmfc(noir_ok) == "oui"} {
               # Teste si les fichiers r�sultants existent d�ja
               for {set i 1} {$i <= $data_spbmfc(nbBrut)} {incr i} {
                  set nomFich $audace(rep_images)
                  append nomFich "/" $data_spbmfc(nmBrutRes) $i $ext
                  if {[file exists $nomFich] == 1} {
                     set integre(brut) non
                  }
               }
               if {$integre(brut) == "non"} {
                  set confirmation [tk_messageBox -title $caption(specLhIII,conf) -type yesno \
                     -message $caption(specLhIII,fichBrutResDeja)]
                  if {$confirmation == "yes" } {
                     set integre(brut) oui
                  }
               }
            }
            if {$data_spbmfc(PLU_ok) == "oui" && $data_spbmfc(noir_ok) == "oui"} {
               if {$data_spbmfc(modeBrut) != "simple" || $data_spbmfc(NrContientPrech) == 0} {
                  # Teste si le fichier de pr�charge existe bien (dans le cas o� l'option
                  #   retenue est optimisation ou rapp. tps de pose) ou bien si le noir
                  #   ne contient pas la pr�charge: J'ai alors besoin de la pr�charge
                  set nomFich $audace(rep_images)
                  append nomFich "/" $data_spbmfc(nmPrechRes) $ext
                  if {[file exists $nomFich] == 0} {
                     # Dans ce cas, je regarde si je peux calculer la pr�charge...
                     testPrecharge
                     if {$integre(precharge) == "non"} {
                        # Je n'ai pas les �l�ments pour faire la pr�charge
                        tk_messageBox -title $caption(specLhIII,pb) -type ok \
                           -message $caption(specLhIII,fichPrechBrutAbs)
                        set integre(brut) non
                        set data_spbmfc(precharge_ok) non
                     } else {
                        # Alors je dois pr�voir de faire le calcul du PLU pendant le traitement
                        set data_spbmfc(precharge_a_faire_br) oui
                        set data_spbmfc(precharge_ok) oui
                     }
                  } else {
                     set data_spbmfc(precharge_ok) oui
                  }
               }
            }
            # Teste qu'un mode est bien s�lectionn�
            if {$data_spbmfc(modeBrut) == ""} {
               tk_messageBox -title $caption(specLhIII,pb) -type ok \
                  -message $caption(specLhIII,fichModeBrutAbs)
               set integre(brut) non
            }
         }
      }
      activeBoutons
   }
#***** Fin de la procedure testBrut ******************************

#***** Proc�dure traiteBrut ************************************
   proc traiteBrut { } {
      global audace caption data_spbmfc integre

      # Enregistrement de l'extension des fichiers
      set ext $::conf(extension,defaut)

      # Le cas �ch�ant, je lance les op�ration pr�limin�ires
      if {$data_spbmfc(PLU_a_faire_br) == "oui"} {
         traitePLU
      }
      if {$data_spbmfc(precharge_a_faire_br) == "oui"} {
         # Je v�rifie que le fichier n'existe pas d�j� (il a pu �tre cr�e par le traitement de PLU...)
         set nomFich $audace(rep_images)
         append nomFich "/" $data_spbmfc(nmPrechRes) $ext
         if {[file exists $nomFich] == 0} {
            traitePrecharge
         }
      }
      if {$data_spbmfc(noir_a_faire_br) == "oui"} {
         # Je v�rifie que le fichier n'existe pas d�j� (il a pu �tre cr�e par le traitement de PLU...)
         set nomFich $audace(rep_images)
         append nomFich "/" $data_spbmfc(nmNoirRes) $ext
         if {[file exists $nomFich] == 0} {
            traiteNoir
         }
      }

      focus $audace(base)
      focus $audace(Console)

      desactiveBoutons

      # Affichage du message de d�marrage du pr�traitement des noirs
      Message consolog $caption(specLhIII,debBrut)
      switch -exact $data_spbmfc(modeBrut) {
         simple {
            Message consolog $caption(specLhIII,ModeBrutSimple)
         }
         rapTps {
            Message consolog $caption(specLhIII,ModeBrutRapTps)
         }
         opt {
            Message consolog $caption(specLhIII,ModeBrutOpt)
         }
      }

      if {$data_spbmfc(cosmBrut) == 1} {
         # Dans le cas o� la correction cosm�tique est demand�e
         Message consolog $caption(specLhIII,lanceCosmStellaire)
         for {set i 1} {$i <= $data_spbmfc(nbBrut)} {incr i} {
            set instr "loadima $data_spbmfc(nmBrutSce)$i"
            Message consolog $instr
            Message consolog "\n"
            eval $instr
            set instr "eval $data_spbmfc(procCorr)"
            Message consolog $instr
            Message consolog "\n"
            eval $instr
            set instr "saveima $data_spbmfc(nmBrutSce)$i"
            Message consolog $instr
            Message consolog "\n"
            eval $instr
         }
      }

      # Affichage de la premi�re image stellaire
      set nomFich $data_spbmfc(nmBrutSce)
      append nomFich "1"
      Message consolog $caption(specLhIII,chargPremBrut)
      set instr "loadima $nomFich"
      Message consolog "%s\n" $instr
      eval $instr
      # Soustraction du noir, selon le mode choisi
      switch -exact $data_spbmfc(modeBrut) {
         simple {
            # Soustraction du noir de chaque image stellaire
            set instr "sub2 $data_spbmfc(nmBrutSce) $data_spbmfc(nmNoirRes) $data_spbmfc(nmBrutSce)"
            append instr "_moinsnoir_ 0 $data_spbmfc(nbBrut)"
            Message consolog $caption(specLhIII,SoustrNoirBrut)
            Message consolog $instr
            Message consolog "\n"
            eval $instr
            # Si le noir ne contient pas la pr�charge, soustraction de la pr�charge
            if {$data_spbmfc(NrContientPrech) == 0} {
               set instr "sub2 $data_spbmfc(nmBrutSce)"
               append instr "_moinsnoir_ $data_spbmfc(nmPrechRes) $data_spbmfc(nmBrutSce)"
               append instr "_moinsnoir_ 0 $data_spbmfc(nbBrut)"
               Message consolog $caption(specLhIII,SoustrPrechBrut)
               Message consolog $instr
               Message consolog "\n"
               eval $instr
            }
         }
         rapTps {
            # Lecture du temps de pose des images stellaires
            # Je v�rifie que le champ exposure est bien pr�sent dans l'ent�te FITS
            if {[lsearch [buf$audace(bufNo) getkwds] EXPOSURE] != -1} {
               set motCle EXPOSURE
            } else {
               set motCle EXPTIME
            }
            set instr "set temps_stellaire [lindex [buf$audace(bufNo) getkwd $motCle] 1]"
            Message consolog $caption(specLhIII,LitTpsStellaire)
            Message consolog "%s\n" $instr
            eval $instr
            # Chargement de l'image de noir
            set instr "loadima $data_spbmfc(nmNoirRes)"
            Message consolog $caption(specLhIII,ChargeNoir)
            Message consolog "%s\n" $instr
            eval $instr
            # Lecture du temps de pose du noir
            # Je v�rifie que le champ exposure est bien pr�sent dans l'ent�te FITS
            if {[lsearch [buf$audace(bufNo) getkwds] EXPOSURE] != -1} {
               set motCle EXPOSURE
            } else {
               set motCle EXPTIME
            }
            set instr "set temps_noir [lindex [buf$audace(bufNo) getkwd $motCle] 1]"
            Message consolog $caption(specLhIII,LitTpsNoir)
            Message consolog "%s\n" $instr
            eval $instr
            # Calcul du rapport de temps entre noir et PLU
            set instr "set rapport [expr double($temps_stellaire) / double($temps_noir)]"
            Message consolog $caption(specLhIII,calcRapp)
            Message consolog "%s\n" $instr
            eval $instr
            # Retire l'offset du noir (si besoin)
            if {$data_spbmfc(NrContientPrech) == 1} {
               set instr "sub $data_spbmfc(nmPrechRes) 0"
               Message consolog $caption(specLhIII,soustrPrechDuNoir)
               Message consolog "%s\n" $instr
               eval $instr
            }
            # Multiplie le noir par le rapport de tps d'exp.
            set instr "mult $rapport"
            Message consolog $caption(specLhIII,multNoir)
            Message consolog "%s\n" $instr
            eval $instr
            # Sauvegarde le noir pond�r�
            set instr "saveima noir_pondere_temp"
            Message consolog $caption(specLhIII,SauveNoirPond)
            Message consolog "%s\n" $instr
            eval $instr
            # Retire l'offset de toutes les images stellaires
            set nom_fich $data_spbmfc(nmBrutSce)
            append nom_fich "_moinsnoir_"
            set instr "sub2 $data_spbmfc(nmBrutSce) $data_spbmfc(nmPrechRes) $nom_fich 0 $data_spbmfc(nbBrut)"
            Message consolog $caption(specLhIII,SoustrPrechStelProv)
            Message consolog "%s\n" $instr
            eval $instr
            # Retire le noir pond�r� de toutes les images stellaires
            set instr "sub2 $nom_fich noir_pondere_temp $nom_fich 0 $data_spbmfc(nbBrut)"
            Message consolog $caption(specLhIII,SoustrNoirPondStel)
            Message consolog "%s\n" $instr
            eval $instr
         }
         opt {
            # V�rifie si le noir contient la pr�charge... et agit en cons�quence
            if {$data_spbmfc(NrContientPrech) == 0} {
               # Si offset non inclus... chargement de l'image de noir
               set instr "loadima $data_spbmfc(nmNoirRes)"
               Message consolog $caption(specLhIII,ChargeNoir)
               Message consolog "%s\n" $instr
               eval $instr
               # Addition de la pr�charge
               set instr "add $data_spbmfc(nmPrechRes) 0"
               Message consolog $caption(specLhIII,ajoutePrechNoir)
               Message consolog "%s\n" $instr
               eval $instr
               # Sauvegarde le noir contenant la pr�charge
               set instr "saveima noir_avec_prech"
               Message consolog $caption(specLhIII,SauveNoirAvecPrech)
               Message consolog "%s\n" $instr
               eval $instr
               # Astuce pour traiter correctement les fichiers de noir...
               set noir_avec_prech noir_avec_prech
            } else {
               # Suite et fin de l'astuce pour traiter correctement les fichiers de noir...
               set noir_avec_prech $data_spbmfc(nmNoirRes)
            }
            set nom_fich_sortie $data_spbmfc(nmBrutSce)
            append nom_fich_sortie "_moinsnoir_"
            # Lancement de l'optimisation; le noir doit contenir la pr�charge !
            set instr "opt2 $data_spbmfc(nmBrutSce) $noir_avec_prech $data_spbmfc(nmPrechRes) \
               $nom_fich_sortie $data_spbmfc(nbBrut)"
            Message consolog $caption(specLhIII,OptBrutes)
            Message consolog "%s\n" $instr
            eval $instr
         }
      }

      # Affichage de la PLU
      set nomFich $data_spbmfc(nmPLURes)
      Message consolog $caption(specLhIII,chargePLU)
      set instr "loadima $nomFich"
      Message consolog $instr
      Message consolog "\n"
      eval $instr

      # Calcul de la valeur moyenne de la PLU
      set instr "set valMoyenne \[lindex \[stat\] 4\]"
      Message consolog $caption(specLhIII,calcMoyPLU)
      Message consolog $instr
      Message consolog "\n"
      eval $instr

      # Division des images par le PLU
      set instr "div2 $data_spbmfc(nmBrutSce)"
      append instr "_moinsnoir_ $data_spbmfc(nmPLURes)\
         $data_spbmfc(nmBrutRes) $valMoyenne $data_spbmfc(nbBrut)"
      Message consolog $caption(specLhIII,divBrutPLU)
      Message consolog $instr
      Message consolog "\n"
      eval $instr

      # Affichage de la premi�re image r�sultante
      set nomFich $data_spbmfc(nmBrutRes)
      append nomFich "1"
      Message consolog $caption(specLhIII,chargBrutRes)
      set instr "loadima $nomFich"
      Message consolog $instr
      Message consolog "\n"
      eval $instr

      # Effacement du disque des images g�n�r�es par le pr�traitement:
      Message consolog $caption(specLhIII,effaceBrutsInter)
      for {set i 1} {$i <= $data_spbmfc(nbBrut)} {incr i} {
         set nomFich $audace(rep_images)
         append nomFich "/" $data_spbmfc(nmBrutSce) "_moinsnoir_" $i $ext
         file delete $nomFich
      }
      set nomFich $audace(rep_images)
      append nomFich "/" "noir_pondere_temp$ext"
      if {[file exists $nomFich]} {
         file delete $nomFich
      }
      set nomFich $audace(rep_images)
      append nomFich "/" "noir_avec_prech$ext"
      if {[file exists $nomFich]} {
         file delete $nomFich
      }

      # Affichage du message de fin du pr�traitement des noirs
      Message consolog $caption(specLhIII,finBrut)
      activeBoutons
      focus $audace(base).fenetreSpData
   }
#***** Fin de la procedure traiteBrut ************************************

#***** Proc�dure de d�sactivation des boutons de la fen�tre **************
   proc desactiveBoutons { } {
      global audace

      $audace(base).fenetreSpData.et1.test configure -state disabled
      $audace(base).fenetreSpData.et1.recharge configure -state disabled
      $audace(base).fenetreSpData.et1.ligne1.entnmFichScr configure -state disabled
      $audace(base).fenetreSpData.et1.ligne2.ent1 configure -state disabled
      $audace(base).fenetreSpData.et2.titre.case configure -state disabled
      $audace(base).fenetreSpData.et2.go configure -state disabled
      $audace(base).fenetreSpData.et2.ligne1.entnmPrechSce configure -state disabled
      $audace(base).fenetreSpData.et2.ligne1.entNbPrech configure -state disabled
      $audace(base).fenetreSpData.et2.ligne2.ent1 configure -state disabled
      $audace(base).fenetreSpData.et2.ligne2.case configure -state disabled
      $audace(base).fenetreSpData.et2.ligne2.ent2 configure -state disabled
      $audace(base).fenetreSpData.et3.titre.case configure -state disabled
      $audace(base).fenetreSpData.et3.go configure -state disabled
      $audace(base).fenetreSpData.et3.ligne1.entnmNrSce configure -state disabled
      $audace(base).fenetreSpData.et3.ligne1.entNbNr configure -state disabled
      $audace(base).fenetreSpData.et3.ligne2.ent1 configure -state disabled
      $audace(base).fenetreSpData.et3.ligne2.case configure -state disabled
      $audace(base).fenetreSpData.et4.titre.case configure -state disabled
      $audace(base).fenetreSpData.et4.go configure -state disabled
      $audace(base).fenetreSpData.et4.ligne1.entnmNrPLUSce configure -state disabled
      $audace(base).fenetreSpData.et4.ligne1.entNbNrPLU configure -state disabled
      $audace(base).fenetreSpData.et4.ligne2.ent1 configure -state disabled
      $audace(base).fenetreSpData.et5.titre.case configure -state disabled
      $audace(base).fenetreSpData.et5.go configure -state disabled
      $audace(base).fenetreSpData.et5.ligne1.entnmPLUSce configure -state disabled
      $audace(base).fenetreSpData.et5.ligne1.entNbPLU configure -state disabled
      $audace(base).fenetreSpData.et5.ligne2.ent1 configure -state disabled
      $audace(base).fenetreSpData.et5.ligne3.rad1 configure -state disabled
      $audace(base).fenetreSpData.et5.ligne3.rad2 configure -state disabled
      $audace(base).fenetreSpData.et5.ligne3.rad3 configure -state disabled
      $audace(base).fenetreSpData.et6.titre.case configure -state disabled
      $audace(base).fenetreSpData.et6.go configure -state disabled
      $audace(base).fenetreSpData.et6.ligne1.entnmBrutSce configure -state disabled
      $audace(base).fenetreSpData.et6.ligne1.entNbBrut configure -state disabled
      $audace(base).fenetreSpData.et6.ligne2.ent1 configure -state disabled
      $audace(base).fenetreSpData.et6.ligne3.rad1 configure -state disabled
      $audace(base).fenetreSpData.et6.ligne3.rad2 configure -state disabled
      $audace(base).fenetreSpData.et6.ligne3.rad3 configure -state disabled
   }
#***** Fin de la proc�dure de d�sactivation des boutons de la fen�tre ****

#***** Proc�dure d'activation des boutons de la fen�tre **************
   proc activeBoutons { } {
      global audace

      $audace(base).fenetreSpData.et1.test configure -state normal
      $audace(base).fenetreSpData.et1.recharge configure -state normal
      $audace(base).fenetreSpData.et1.ligne1.entnmFichScr configure -state normal
      $audace(base).fenetreSpData.et1.ligne2.ent1 configure -state normal
      $audace(base).fenetreSpData.et2.titre.case configure -state normal
      $audace(base).fenetreSpData.et2.go configure -state normal
      $audace(base).fenetreSpData.et2.ligne1.entnmPrechSce configure -state normal
      $audace(base).fenetreSpData.et2.ligne1.entNbPrech configure -state normal
      $audace(base).fenetreSpData.et2.ligne2.ent1 configure -state normal
      $audace(base).fenetreSpData.et2.ligne2.case configure -state normal
      $audace(base).fenetreSpData.et2.ligne2.ent2 configure -state normal
      $audace(base).fenetreSpData.et3.titre.case configure -state normal
      $audace(base).fenetreSpData.et3.go configure -state normal
      $audace(base).fenetreSpData.et3.ligne1.entnmNrSce configure -state normal
      $audace(base).fenetreSpData.et3.ligne1.entNbNr configure -state normal
      $audace(base).fenetreSpData.et3.ligne2.ent1 configure -state normal
      $audace(base).fenetreSpData.et3.ligne2.case configure -state normal
      $audace(base).fenetreSpData.et4.titre.case configure -state normal
      $audace(base).fenetreSpData.et4.go configure -state normal
      $audace(base).fenetreSpData.et4.ligne1.entnmNrPLUSce configure -state normal
      $audace(base).fenetreSpData.et4.ligne1.entNbNrPLU configure -state normal
      $audace(base).fenetreSpData.et4.ligne2.ent1 configure -state normal
      $audace(base).fenetreSpData.et5.titre.case configure -state normal
      $audace(base).fenetreSpData.et5.go configure -state normal
      $audace(base).fenetreSpData.et5.ligne1.entnmPLUSce configure -state normal
      $audace(base).fenetreSpData.et5.ligne1.entNbPLU configure -state normal
      $audace(base).fenetreSpData.et5.ligne2.ent1 configure -state normal
      $audace(base).fenetreSpData.et5.ligne3.rad1 configure -state normal
      $audace(base).fenetreSpData.et5.ligne3.rad2 configure -state normal
      $audace(base).fenetreSpData.et5.ligne3.rad3 configure -state normal
      $audace(base).fenetreSpData.et6.titre.case configure -state normal
      $audace(base).fenetreSpData.et6.go configure -state normal
      $audace(base).fenetreSpData.et6.ligne1.entnmBrutSce configure -state normal
      $audace(base).fenetreSpData.et6.ligne1.entNbBrut configure -state normal
      $audace(base).fenetreSpData.et6.ligne2.ent1 configure -state normal
      $audace(base).fenetreSpData.et6.ligne3.rad1 configure -state normal
      $audace(base).fenetreSpData.et6.ligne3.rad2 configure -state normal
      $audace(base).fenetreSpData.et6.ligne3.rad3 configure -state normal
   }
#***** Fin de la proc�dure d'activation des boutons de la fen�tre ****

#***** Procedure de test de validit� d'un nom de fichier *****************
# Cette proc�dure (copi�e de Methking) v�rifie que la chaine pass�e en argument est un
# nom de fichier valide.
   proc TestNomFichier { valeur } {
      set test 1
      # Teste qu'il y a bien un nom de fichier
      if {$valeur == ""} {
         set test 0
      }
      # Teste que le nom de fichier n'a pas d'espace
      if {[llength $valeur] > 1} {
         set test 0
      }
      # Teste que le nom des images ne contient pas de caract�rs interdits
      if {[TestChaine $valeur] == 0} {
         set test 0
      }
      return $test
   }
#***** Fin de la procedure de test de validit� d'un nom de fichier *******

#***** Procedure de test de validit� d'un entier *****************
# Cette proc�dure (copi�e de Methking) v�rifie que la chaine pass�e en argument d�crit
# bien un entier. Elle retourne 1 si c'est la cas, et 0 si ce n'est pas un entier.
   proc TestEntier { valeur } {
      set test 1
      if {$valeur == ""} {
         set test 0
      }
      for {set i 0} {$i < [string length $valeur]} {incr i} {
         set a [string index $valeur $i]
         if {![string match {[0-9]} $a]} {
            set test 0
         }
      }
      return $test
   }
#***** Fin de la procedure de test de validit� d'un entier *******

#***** Procedure de test de validit� d'une chaine de caract�res *******
# Cette proc�dure v�rifie que la chaine pass�e en argument ne contient que des caract�res
# valides. Elle retourne 1 si c'est la cas, et 0 si ce n'est pas valable.
   proc TestChaine { valeur } {
      set test 1
      for {set i 0} {$i < [string length $valeur]} {incr i} {
         set a [string index $valeur $i]
         if {![string match {[-a-zA-Z0-9_]} $a]} {
            set test 0
         }
      }
      return $test
   }
#***** Fin de la procedure de test de validit� d'une chaine de caract�res *******

#***** Procedure de test de validit� d'un nombre r�el *****************
# Cette proc�dure (inspir�e de Methking) v�rifie que la chaine pass�e en argument d�crit
# bien un r�el. Elle retourne 1 si c'est la cas, et 0 si ce n'est pas un entier.
   proc TestReel { valeur } {
      set test 1
      for {set i 0} {$i < [string length $valeur]} {incr i} {
         set a [string index $valeur $i]
         if {![string match {[0-9.]} $a]} {
            set test 0
         }
      }
      return $test
   }
#***** Fin de la procedure de test de validit� d'un nombre r�el *******

#***** Procedure d'affichage des messages ************************
# Cette proc�dure est recopi�e de Methking.tcl. Elle permet l'affichage de differents
# messages (dans la console, le fichier log, etc...)
   proc Message { niveau args } {
      global caption conf

      switch -exact -- $niveau {
         console {
            ::console::disp [eval [concat {format} $args]]
            update idletasks
         }
         log {
            set temps [clock format [clock seconds] -format %H:%M:%S]
            append temps " "
            catch { puts -nonewline $::spbmfc::log_id [eval [concat {format} $args]] }
         }
         consolog {
            if { [ info exists conf(messages_console_specLhIII) ] == "0" } {
               set conf(messages_console_specLhIII) "1"
            }
            if { $conf(messages_console_specLhIII) == "1" } {
               ::console::disp [eval [concat {format} $args]]
               update idletasks
            }
            set temps [clock format [clock seconds] -format %H:%M:%S]
            append temps " "
            catch { puts -nonewline $::spbmfc::log_id [eval [concat {format} $args]] }
         }
         default {
            set b [ list "%s\n" $caption(specLhIII,pbmesserr) ]
            ::console::disp [ eval [ concat {format} $b ] ]
            update idletasks
         }
      }
   }
#***** Fin de la procedure d'affichage des messages ***************

}

#==============================================================
#   Fin de la declaration du Namespace spbmfc
#==============================================================

#-----------------------------------------------------------------------------------------------

proc creeFenspbmfc { } {
   global audace caption data_spbmfc panneau

   set panneau(AcqFC,list_mode) [ list "toto" "titi" ]

   #--- Trame de l'�tape 1
   frame $audace(base).fenetreSpData.et1 -borderwidth 2 -relief groove

      #--- Titre de l'�tape 1: Donn�es d'entr�e
      frame $audace(base).fenetreSpData.et1.titre -borderwidth 1 -relief groove
         # Affichage du titre
         label $audace(base).fenetreSpData.et1.titre.nom -text $caption(specLhIII,titret1) -justify left
         pack $audace(base).fenetreSpData.et1.titre.nom -side left -in $audace(base).fenetreSpData.et1.titre
      pack $audace(base).fenetreSpData.et1.titre -side top -fill x

      #--- Premiere ligne de l'�tape 1
      frame $audace(base).fenetreSpData.et1.fr1
         frame $audace(base).fenetreSpData.et1.fr1.ligne1
            # Affichage du label
            label $audace(base).fenetreSpData.et1.fr1.ligne1.lab1 -text $caption(specLhIII,spfich) -width 20
            pack $audace(base).fenetreSpData.et1.fr1.ligne1.lab1 -side left
            # Affichage du champ de saisie
            entry $audace(base).fenetreSpData.et1.fr1.ligne1.ent1 -width 16 -relief flat\
               -textvariable data_spbmfc(nomFichSpIn) -justify left -borderwidth 1 -relief groove
            pack $audace(base).fenetreSpData.et1.fr1.ligne1.ent1 -side left
         pack $audace(base).fenetreSpData.et1.fr1.ligne1 -side left
      pack $audace(base).fenetreSpData.et1.fr1 -side top

#       #--- Seconde ligne de l'�tape 1 "Spectres"
#       frame $audace(base).fenetreSpData.et1.ligne2
#       pack $audace(base).fenetreSpData.et1.ligne2 -side top -fill x

      #--- Troisi�me ligne de l'�tape 1 "Objet - RA - DEC"
      frame $audace(base).fenetreSpData.et1.ligne3
         # Affichage du label
         label $audace(base).fenetreSpData.et1.ligne3.lab1 -text $caption(specLhIII,spnomobj) \
            -width 15 -justify right
         pack $audace(base).fenetreSpData.et1.ligne3.lab1 -side left
         # Affichage du champ de saisie
         entry $audace(base).fenetreSpData.et1.ligne3.ent1 -width 16 -relief flat\
            -textvariable data_spbmfc(nmObj) -justify left -borderwidth 1 -relief groove
         pack $audace(base).fenetreSpData.et1.ligne3.ent1 -side left
         # Affichage du label
         label $audace(base).fenetreSpData.et1.ligne3.lab2 -text $caption(specLhIII,spRA) \
            -width 16 -justify right
         pack $audace(base).fenetreSpData.et1.ligne3.lab2 -side left
         # Affichage du champ de saisie
         entry $audace(base).fenetreSpData.et1.ligne3.ent2 -width 16 -relief flat\
            -textvariable data_spbmfc(RA) -justify left -borderwidth 1 -relief groove
         pack $audace(base).fenetreSpData.et1.ligne3.ent2 -side left
         # Affichage du label
         label $audace(base).fenetreSpData.et1.ligne3.lab3 -text $caption(specLhIII,spDEC) \
            -width 16 -justify right
         pack $audace(base).fenetreSpData.et1.ligne3.lab3 -side left
         # Affichage du champ de saisie
         entry $audace(base).fenetreSpData.et1.ligne3.ent3 -width 16 -relief flat\
            -textvariable data_spbmfc(DEC) -justify left -borderwidth 1 -relief groove
         pack $audace(base).fenetreSpData.et1.ligne3.ent3 -side left
      pack $audace(base).fenetreSpData.et1.ligne3 -side top -fill x

      #--- Quatri�me ligne de l'�tape 1 "Equipement - site"
      frame $audace(base).fenetreSpData.et1.ligne4
         # Affichage du label & combobox
         label $audace(base).fenetreSpData.et1.ligne4.lab2 -text $caption(specLhIII,spconf) \
            -width 29 -justify right
         pack $audace(base).fenetreSpData.et1.ligne4.lab2 -side left
         ComboBox $audace(base).fenetreSpData.et1.ligne4.comb1 \
           -width 25 -height 3 -relief raised -borderwidth 1 -editable 0 -takefocus 1 \
           -justify left -textvariable data_spbmfc(config) -values $panneau(AcqFC,list_mode)
           #-modifycmd "::AcqFC::ChangeMode $visuNo"
         pack $audace(base).fenetreSpData.et1.ligne4.comb1 -side left
         # Affichage du label
         label $audace(base).fenetreSpData.et1.ligne4.lab3 -text $caption(specLhIII,spsiteobs) \
            -width 15 -justify right
         pack $audace(base).fenetreSpData.et1.ligne4.lab3 -side left
         # Affichage du champ de saisie
         entry $audace(base).fenetreSpData.et1.ligne4.ent3 -width 16 -relief flat\
            -textvariable data_spbmfc(siteObs) -justify left -borderwidth 1 -relief groove
         pack $audace(base).fenetreSpData.et1.ligne4.ent3 -side left
      pack $audace(base).fenetreSpData.et1.ligne4 -side top -fill x

      #--- Cinqui�me ligne de l'�tape 2 "Observateurs"
      frame $audace(base).fenetreSpData.et1.ligne5
         # Affichage du label
         label $audace(base).fenetreSpData.et1.ligne5.lab1 -text $caption(specLhIII,spobservers) \
            -width 29 -justify right
         pack $audace(base).fenetreSpData.et1.ligne5.lab1 -side left
         # Affichage du champ de saisie
         entry $audace(base).fenetreSpData.et1.ligne5.ent1 -width 16 -relief flat\
            -textvariable data_spbmfc(Obs-1) -justify left -borderwidth 1 -relief groove
         pack $audace(base).fenetreSpData.et1.ligne5.ent1 -side left
         # Affichage du champ de saisie
         entry $audace(base).fenetreSpData.et1.ligne5.ent2 -width 16 -relief flat\
            -textvariable data_spbmfc(Obs-2) -justify left -borderwidth 1 -relief groove
         pack $audace(base).fenetreSpData.et1.ligne5.ent2 -side left
         # Affichage du champ de saisie
         entry $audace(base).fenetreSpData.et1.ligne5.ent3 -width 16 -relief flat\
            -textvariable data_spbmfc(Obs-3) -justify left -borderwidth 1 -relief groove
         pack $audace(base).fenetreSpData.et1.ligne5.ent3 -side left
      pack $audace(base).fenetreSpData.et1.ligne5 -side top -fill x

      #--- Sixi�me ligne de l'�tape 1 "Noirs"
      frame $audace(base).fenetreSpData.et1.ligne6
         # Affichage du label
         label $audace(base).fenetreSpData.et1.ligne6.lab1 -text $caption(specLhIII,spnoirs) \
            -width 29 -justify right
         pack $audace(base).fenetreSpData.et1.ligne6.lab1 -side left
         # Affichage du champ de saisie
         entry $audace(base).fenetreSpData.et1.ligne6.ent1 -width 16 -relief flat\
            -textvariable data_spbmfc(nomFichNoirIn) -justify left -borderwidth 1 -relief groove
         pack $audace(base).fenetreSpData.et1.ligne6.ent1 -side left
         # Affichage du label
         label $audace(base).fenetreSpData.et1.ligne6.lab2 -text $caption(specLhIII,fichres) \
            -width 29 -justify right
         pack $audace(base).fenetreSpData.et1.ligne6.lab2 -side left
         # Affichage du champ de saisie
         entry $audace(base).fenetreSpData.et1.ligne6.ent2 -width 16 -relief flat\
            -textvariable data_spbmfc(nomFichNoirOut) -justify left -borderwidth 1 -relief groove
         pack $audace(base).fenetreSpData.et1.ligne6.ent2 -side left
      pack $audace(base).fenetreSpData.et1.ligne6 -side top -fill x

      #--- Septi�me ligne de l'�tape 1 "Type de soustraction des noirs"
      frame $audace(base).fenetreSpData.et1.ligne7
         label $audace(base).fenetreSpData.et1.ligne7.lab1 -text $caption(specLhIII,SoustrNr)
         pack $audace(base).fenetreSpData.et1.ligne7.lab1 -side left
         radiobutton $audace(base).fenetreSpData.et1.ligne7.rad1 -variable data_spbmfc(modeNoir) \
            -text $caption(specLhIII,NrBut1) -value simple
         pack $audace(base).fenetreSpData.et1.ligne7.rad1 -side left
         radiobutton $audace(base).fenetreSpData.et1.ligne7.rad2 -variable data_spbmfc(modeNoir) \
            -text $caption(specLhIII,NrPLUBut2) -value rapTps
         pack $audace(base).fenetreSpData.et1.ligne7.rad2 -side left
         radiobutton $audace(base).fenetreSpData.et1.ligne7.rad3 -variable data_spbmfc(modeNoir) \
            -text $caption(specLhIII,NrPLUBut3) -value opt
         pack $audace(base).fenetreSpData.et1.ligne7.rad3 -side left
      pack $audace(base).fenetreSpData.et1.ligne7 -side top -fill x

      #--- Huiti�me ligne de l'�tape 1 "NeonAV"
      frame $audace(base).fenetreSpData.et1.ligne8
         # Affichage du label
         label $audace(base).fenetreSpData.et1.ligne8.lab1 -text $caption(specLhIII,neonavfich) \
            -width 29 -justify right
         pack $audace(base).fenetreSpData.et1.ligne8.lab1 -side left
         # Affichage du champ de saisie "Proc�dure de correction cosm�tique"
         entry $audace(base).fenetreSpData.et1.ligne8.ent1 -width 16 -relief flat\
            -textvariable data_spbmfc(nomFichNeonAvIn) -justify left -borderwidth 1 -relief groove
         pack $audace(base).fenetreSpData.et1.ligne8.ent1 -side left
         # Affichage du label "Proc�dure de correction cosm�tique"
         label $audace(base).fenetreSpData.et1.ligne8.lab2 -text $caption(specLhIII,fichres) \
            -width 29 -justify right
         pack $audace(base).fenetreSpData.et1.ligne8.lab2 -side left
         # Affichage du champ de saisie "Proc�dure de correction cosm�tique"
         entry $audace(base).fenetreSpData.et1.ligne8.ent2 -width 16 -relief flat\
            -textvariable data_spbmfc(nomFichNeonAvOut) -justify left -borderwidth 1 -relief groove
         pack $audace(base).fenetreSpData.et1.ligne8.ent2 -side left
      pack $audace(base).fenetreSpData.et1.ligne8 -side top -fill x

      #--- Neuvi�me ligne de l'�tape 1 "NeonAP"
      frame $audace(base).fenetreSpData.et1.ligne9
         # Affichage du label
         label $audace(base).fenetreSpData.et1.ligne9.lab1 -text $caption(specLhIII,neonapfich) \
            -width 29 -justify right
         pack $audace(base).fenetreSpData.et1.ligne9.lab1 -side left
         # Affichage du champ de saisie
         entry $audace(base).fenetreSpData.et1.ligne9.ent1 -width 16 -relief flat\
            -textvariable data_spbmfc(nomFichNeonApIn) -justify left -borderwidth 1 -relief groove
         pack $audace(base).fenetreSpData.et1.ligne9.ent1 -side left
         # Affichage du label
         label $audace(base).fenetreSpData.et1.ligne9.lab2 -text $caption(specLhIII,fichres) \
            -width 29 -justify right
         pack $audace(base).fenetreSpData.et1.ligne9.lab2 -side left
         # Affichage du champ de saisie
         entry $audace(base).fenetreSpData.et1.ligne9.ent2 -width 16 -relief flat\
            -textvariable data_spbmfc(nomFichNeonApOut) -justify left -borderwidth 1 -relief groove
         pack $audace(base).fenetreSpData.et1.ligne9.ent2 -side left
      pack $audace(base).fenetreSpData.et1.ligne9 -side top -fill x

      #--- Dixi�me ligne de l'�tape 1 "Noirs n�on"
      frame $audace(base).fenetreSpData.et1.ligne10
         # Affichage du label
         label $audace(base).fenetreSpData.et1.ligne10.lab1 -text $caption(specLhIII,spnoirsneon) \
            -width 29 -justify right
         pack $audace(base).fenetreSpData.et1.ligne10.lab1 -side left
         # Affichage du champ de saisie
         entry $audace(base).fenetreSpData.et1.ligne10.ent1 -width 16 -relief flat\
            -textvariable data_spbmfc(nomFichNrNeonIn) -justify left -borderwidth 1 -relief groove
         pack $audace(base).fenetreSpData.et1.ligne10.ent1 -side left
         # Affichage du label
         label $audace(base).fenetreSpData.et1.ligne10.lab2 -text $caption(specLhIII,fichres) \
            -width 29 -justify right
         pack $audace(base).fenetreSpData.et1.ligne10.lab2 -side left
         # Affichage du champ de saisie
         entry $audace(base).fenetreSpData.et1.ligne10.ent2 -width 16 -relief flat\
            -textvariable data_spbmfc(nomFichNrNeonOut) -justify left -borderwidth 1 -relief groove
         pack $audace(base).fenetreSpData.et1.ligne10.ent2 -side left
      pack $audace(base).fenetreSpData.et1.ligne10 -side top -fill x

      #--- Onzi�me ligne de l'�tape 1 "Type de soustraction des noirs"
      frame $audace(base).fenetreSpData.et1.ligne11
         label $audace(base).fenetreSpData.et1.ligne11.lab1 -text $caption(specLhIII,SoustrNr)
         pack $audace(base).fenetreSpData.et1.ligne11.lab1 -side left
         radiobutton $audace(base).fenetreSpData.et1.ligne11.rad1 -variable data_spbmfc(modeNeon) \
            -text $caption(specLhIII,NrNeon1) -value simple
         pack $audace(base).fenetreSpData.et1.ligne11.rad1 -side left
         radiobutton $audace(base).fenetreSpData.et1.ligne11.rad2 -variable data_spbmfc(modeNeon) \
            -text $caption(specLhIII,NrPLUBut2) -value rapTps
         pack $audace(base).fenetreSpData.et1.ligne11.rad2 -side left
         radiobutton $audace(base).fenetreSpData.et1.ligne11.rad3 -variable data_spbmfc(modeNeon) \
            -text $caption(specLhIII,NrPLUBut3) -value opt
         pack $audace(base).fenetreSpData.et1.ligne11.rad3 -side left
      pack $audace(base).fenetreSpData.et1.ligne11 -side top -fill x

      #--- Douzi�me ligne de l'�tape 1 "Flats"
      frame $audace(base).fenetreSpData.et1.ligne12
         # Affichage du label
         label $audace(base).fenetreSpData.et1.ligne12.lab1 -text $caption(specLhIII,spPLUs) \
            -width 29 -justify right
         pack $audace(base).fenetreSpData.et1.ligne12.lab1 -side left
         # Affichage du champ de saisie
         entry $audace(base).fenetreSpData.et1.ligne12.ent1 -width 16 -relief flat\
            -textvariable data_spbmfc(nomFichPLUIn) -justify left -borderwidth 1 -relief groove
         pack $audace(base).fenetreSpData.et1.ligne12.ent1 -side left
         # Affichage du label
         label $audace(base).fenetreSpData.et1.ligne12.lab2 -text $caption(specLhIII,fichres) \
            -width 29 -justify right
         pack $audace(base).fenetreSpData.et1.ligne12.lab2 -side left
         # Affichage du champ de saisie
         entry $audace(base).fenetreSpData.et1.ligne12.ent2 -width 16 -relief flat\
            -textvariable data_spbmfc(nomFichPLUOut) -justify left -borderwidth 1 -relief groove
         pack $audace(base).fenetreSpData.et1.ligne12.ent2 -side left
      pack $audace(base).fenetreSpData.et1.ligne12 -side top -fill x

      #--- Treizi�me ligne de l'�tape 1 "Noirs de flats"
      frame $audace(base).fenetreSpData.et1.ligne13
         # Affichage du label
         label $audace(base).fenetreSpData.et1.ligne13.lab1 -text $caption(specLhIII,spnoirsPLUs) \
            -width 29 -justify right
         pack $audace(base).fenetreSpData.et1.ligne13.lab1 -side left
         # Affichage du champ de saisie
         entry $audace(base).fenetreSpData.et1.ligne13.ent1 -width 16 -relief flat\
            -textvariable data_spbmfc(nomFichNrPLUIn) -justify left -borderwidth 1 -relief groove
         pack $audace(base).fenetreSpData.et1.ligne13.ent1 -side left
         # Affichage du label
         label $audace(base).fenetreSpData.et1.ligne13.lab2 -text $caption(specLhIII,fichres) \
            -width 29 -justify right
         pack $audace(base).fenetreSpData.et1.ligne13.lab2 -side left
         # Affichage du champ de saisie
         entry $audace(base).fenetreSpData.et1.ligne13.ent2 -width 16 -relief flat\
            -textvariable data_spbmfc(nomFichNrPLUOut) -justify left -borderwidth 1 -relief groove
         pack $audace(base).fenetreSpData.et1.ligne13.ent2 -side left
      pack $audace(base).fenetreSpData.et1.ligne13 -side top -fill x

      #--- Quatorzi�me ligne de l'�tape 1 "Type de soustraction des noirs de flats"
      frame $audace(base).fenetreSpData.et1.ligne14
         label $audace(base).fenetreSpData.et1.ligne14.lab1 -text $caption(specLhIII,SoustrNr)
         pack $audace(base).fenetreSpData.et1.ligne14.lab1 -side left
         radiobutton $audace(base).fenetreSpData.et1.ligne14.rad1 -variable data_spbmfc(modePLU) \
            -text $caption(specLhIII,NrPLUBut1) -value simple
         pack $audace(base).fenetreSpData.et1.ligne14.rad1 -side left
         radiobutton $audace(base).fenetreSpData.et1.ligne14.rad2 -variable data_spbmfc(modePLU) \
            -text $caption(specLhIII,NrPLUBut2) -value rapTps
         pack $audace(base).fenetreSpData.et1.ligne14.rad2 -side left
         radiobutton $audace(base).fenetreSpData.et1.ligne14.rad3 -variable data_spbmfc(modePLU) \
            -text $caption(specLhIII,NrPLUBut3) -value opt
         pack $audace(base).fenetreSpData.et1.ligne14.rad3 -side left
      pack $audace(base).fenetreSpData.et1.ligne14 -side top -fill x

      #--- Quinzi�me ligne de l'�tape 1 "Offsets"
      frame $audace(base).fenetreSpData.et1.ligne15
         # Affichage du label
         label $audace(base).fenetreSpData.et1.ligne15.lab1 -text $caption(specLhIII,spoffsets) \
            -width 29 -justify right
         pack $audace(base).fenetreSpData.et1.ligne15.lab1 -side left
         # Affichage du champ de saisie
         entry $audace(base).fenetreSpData.et1.ligne15.ent1 -width 16 -relief flat\
            -textvariable data_spbmfc(nomFichOffsetIn) -justify left -borderwidth 1 -relief groove
         pack $audace(base).fenetreSpData.et1.ligne15.ent1 -side left
         # Affichage du label
         label $audace(base).fenetreSpData.et1.ligne15.lab2 -text $caption(specLhIII,fichres) \
            -width 29 -justify right
         pack $audace(base).fenetreSpData.et1.ligne15.lab2 -side left
         # Affichage du champ de saisie
         entry $audace(base).fenetreSpData.et1.ligne15.ent2 -width 16 -relief flat\
            -textvariable data_spbmfc(nomFichOffsetOut) -justify left -borderwidth 1 -relief groove
         pack $audace(base).fenetreSpData.et1.ligne15.ent2 -side left
      pack $audace(base).fenetreSpData.et1.ligne15 -side top -fill x

      frame $audace(base).fenetreSpData.et1.f1 -borderwidth 4 -relief groove -padx 15 -pady 3
         #--- Seizi�me ligne de l'�tape 1
         frame $audace(base).fenetreSpData.et1.f1.ligne16
            # Affichage du label
            label $audace(base).fenetreSpData.et1.f1.ligne16.lab1 -text $caption(specLhIII,spfichcosme) -width 20
            pack $audace(base).fenetreSpData.et1.f1.ligne16.lab1 -side left
            # Affichage du champ de saisie
            entry $audace(base).fenetreSpData.et1.f1.ligne16.ent1 -width 16 -relief flat \
               -textvariable data_spbmfc(nomFichCosm) -justify left -borderwidth 1 -relief groove
            pack $audace(base).fenetreSpData.et1.f1.ligne16.ent1 -side left
            # Affichage du bouton de s�lection
            button $audace(base).fenetreSpData.et1.f1.ligne16.but1 -borderwidth 2 -width 1 -text $caption(specLhIII,troispoints) \
               -command ::spbmfc::goBrut
            pack $audace(base).fenetreSpData.et1.f1.ligne16.but1 -side left
            # Affichage du label
            label $audace(base).fenetreSpData.et1.f1.ligne16.lab2 -text $caption(specLhIII,spcrbreponse) \
               -width 20 -justify right
            pack $audace(base).fenetreSpData.et1.f1.ligne16.lab2 -side left
            # Affichage du champ de saisie
            entry $audace(base).fenetreSpData.et1.f1.ligne16.ent2 -width 16 -relief flat\
               -textvariable data_spbmfc(nomFichRepInst) -justify left -borderwidth 1 -relief groove
            pack $audace(base).fenetreSpData.et1.f1.ligne16.ent2 -side left
            # Affichage du bouton de s�lection
            button $audace(base).fenetreSpData.et1.f1.ligne16.but2 -borderwidth 2 -width 1 -text $caption(specLhIII,troispoints) \
               -command ::spbmfc::goBrut
            pack $audace(base).fenetreSpData.et1.f1.ligne16.but2 -side left
         pack $audace(base).fenetreSpData.et1.f1.ligne16 -side top -fill x

         #--- dix-septi�me ligne de l'�tape 1
         frame $audace(base).fenetreSpData.et1.f1.ligne17
            # Affichage du label
            label $audace(base).fenetreSpData.et1.f1.ligne17.lab1 -text $caption(specLhIII,fichcalibneon) \
               -width 20 -justify right
            pack $audace(base).fenetreSpData.et1.f1.ligne17.lab1 -side left
            # Affichage du champ de saisie
            entry $audace(base).fenetreSpData.et1.f1.ligne17.ent1 -width 16 -relief flat\
               -textvariable data_spbmfc(nomFichRaiesNeon) -justify left -borderwidth 1 -relief groove
            pack $audace(base).fenetreSpData.et1.f1.ligne17.ent1 -side left
            # Affichage du bouton de s�lection
            button $audace(base).fenetreSpData.et1.f1.ligne17.but1 -borderwidth 2 -width 1 -text $caption(specLhIII,troispoints) \
               -command ::spbmfc::goBrut
            pack $audace(base).fenetreSpData.et1.f1.ligne17.but1 -side left
            label $audace(base).fenetreSpData.et1.f1.ligne17.lab2 -text $caption(specLhIII,fichcalibatm) \
               -width 20 -justify right
            pack $audace(base).fenetreSpData.et1.f1.ligne17.lab2 -side left
            # Affichage du champ de saisie
            entry $audace(base).fenetreSpData.et1.f1.ligne17.ent2 -width 16 -relief flat\
               -textvariable data_spbmfc(nomFichRaiesAtm) -justify left -borderwidth 1 -relief groove
            pack $audace(base).fenetreSpData.et1.f1.ligne17.ent2 -side left
                  # Affichage du bouton de s�lection
            button $audace(base).fenetreSpData.et1.f1.ligne17.but2 -borderwidth 2 -width 1 -text $caption(specLhIII,troispoints) \
               -command ::spbmfc::goBrut
            pack $audace(base).fenetreSpData.et1.f1.ligne17.but2 -side left
         pack $audace(base).fenetreSpData.et1.f1.ligne17 -side top -fill x

         #--- Dix-huiti�me ligne de l'�tape 1 "Images invers�es"
         frame $audace(base).fenetreSpData.et1.f1.ligne18
            # Affichage dele case � cocher
            checkbutton $audace(base).fenetreSpData.et1.f1.ligne18.chk1 -text $caption(specLhIII,spinverse) \
               -variable data_spbmfc(inverser)
            pack $audace(base).fenetreSpData.et1.f1.ligne18.chk1 -side top
         pack $audace(base).fenetreSpData.et1.f1.ligne18 -side top -fill x
      pack $audace(base).fenetreSpData.et1.f1 -side top

   pack $audace(base).fenetreSpData.et1 -side top

   #--- Trame de l'�tape 2
   frame $audace(base).fenetreSpData.et2 -borderwidth 2 -relief groove

      #--- Titre de l'�tape 2: Pr�traitement des noirs & option cosm�tique
      frame $audace(base).fenetreSpData.et2.titre -borderwidth 1 -relief groove
         # Affichage du titre
         label $audace(base).fenetreSpData.et2.titre.nom -text $caption(specLhIII,titret2) -justify left
         pack $audace(base).fenetreSpData.et2.titre.nom -side left -in $audace(base).fenetreSpData.et2.titre
      pack $audace(base).fenetreSpData.et2.titre -side top -fill x

      #--- Premi�re ligne de l'�tape 2 "fichier de sortie"
      frame $audace(base).fenetreSpData.et2.ligne1
         # Affichage du label
         label $audace(base).fenetreSpData.et2.ligne1.lab1 -text $caption(specLhIII,nmfichsortie) -width 20
         pack $audace(base).fenetreSpData.et2.ligne1.lab1 -side left
         # Affichage du champ de saisie
         entry $audace(base).fenetreSpData.et2.ligne1.ent1 -width 16 -relief flat\
            -textvariable data_spbmfc(nomFichSpOut) -justify left -borderwidth 1 -relief groove
         pack $audace(base).fenetreSpData.et2.ligne1.ent1 -side left
         # Affichage de la case � cocher pour filtrer la m�diane
         checkbutton $audace(base).fenetreSpData.et2.ligne1.chk1 -text $caption(specLhIII,resfitbess) \
            -variable data_spbmfc(out-fit)
         pack $audace(base).fenetreSpData.et2.ligne1.chk1 -side left -in $audace(base).fenetreSpData.et2.ligne1
         # Affichage de la case � cocher pour filtrer la m�diane
         checkbutton $audace(base).fenetreSpData.et2.ligne1.chk2 -text $caption(specLhIII,resdat) \
            -variable data_spbmfc(out-dat)
         pack $audace(base).fenetreSpData.et2.ligne1.chk2 -side left -in $audace(base).fenetreSpData.et2.ligne1
         # Affichage de la case � cocher pour filtrer la m�diane
         checkbutton $audace(base).fenetreSpData.et2.ligne1.chk3 -text $caption(specLhIII,respng) \
            -variable data_spbmfc(out-png)
         pack $audace(base).fenetreSpData.et2.ligne1.chk3 -side left -in $audace(base).fenetreSpData.et2.ligne1
         checkbutton $audace(base).fenetreSpData.et2.ligne1.chk4 -text $caption(specLhIII,reslog) \
            -variable data_spbmfc(out-log)
         pack $audace(base).fenetreSpData.et2.ligne1.chk4 -side left -in $audace(base).fenetreSpData.et2.ligne1
         button $audace(base).fenetreSpData.et2.ligne1.but1 -borderwidth 2 -width 12 -text $caption(specLhIII,lienBeSS) \
            -command ::spbmfc::goLienBeSS
         pack $audace(base).fenetreSpData.et2.ligne1.but1 -side right
      pack $audace(base).fenetreSpData.et2.ligne1 -side top -fill x

      #--- Seconde ligne de l'�tape 2 "images interm�diaires"
      frame $audace(base).fenetreSpData.et2.ligne2
         # Affichage du label
         label $audace(base).fenetreSpData.et2.ligne2.lab1 -text $caption(specLhIII,fichinterm) \
            -width 20 -justify right
         pack $audace(base).fenetreSpData.et2.ligne2.lab1 -side left
         # Affichage de la case � cocher
         checkbutton $audace(base).fenetreSpData.et2.ligne2.chk1 -text $caption(specLhIII,fich_0b) \
            -variable data_spbmfc(out-0b)
         pack $audace(base).fenetreSpData.et2.ligne2.chk1 -side left -in $audace(base).fenetreSpData.et2.ligne2
         # Affichage de la case � cocher
         checkbutton $audace(base).fenetreSpData.et2.ligne2.chk2 -text $caption(specLhIII,fich_1a) \
            -variable data_spbmfc(out-1a)
         pack $audace(base).fenetreSpData.et2.ligne2.chk2 -side left -in $audace(base).fenetreSpData.et2.ligne2
         # Affichage de la case � cocher
         checkbutton $audace(base).fenetreSpData.et2.ligne2.chk3 -text $caption(specLhIII,fich_1b) \
            -variable data_spbmfc(out-1b)
         pack $audace(base).fenetreSpData.et2.ligne2.chk3 -side left -in $audace(base).fenetreSpData.et2.ligne2
         button $audace(base).fenetreSpData.et2.ligne2.but1 -borderwidth 2 -width 12 -text $caption(specLhIII,lienNiveaux) \
            -command ::spbmfc::goLienNiveaux
         pack $audace(base).fenetreSpData.et2.ligne2.but1 -side right
      pack $audace(base).fenetreSpData.et2.ligne2 -side top -fill x

   pack $audace(base).fenetreSpData.et2 -side top -fill x

   #--- Trame de l'�tape 3
   frame $audace(base).fenetreSpData.et3 -borderwidth 2 -relief groove -bg blue

      #--- Titre de l'�tape 3: Pr�traitement des noirs & option cosm�tique
      frame $audace(base).fenetreSpData.et3.titre -borderwidth 1 -relief groove
         # Affichage du titre
         label $audace(base).fenetreSpData.et3.titre.nom -text $caption(specLhIII,titret3) -justify left
         pack $audace(base).fenetreSpData.et3.titre.nom -side left -in $audace(base).fenetreSpData.et3.titre
      pack $audace(base).fenetreSpData.et3.titre -side top -fill x

      #--- Cinqui�me ligne de l'�tape 3
      frame $audace(base).fenetreSpData.et3.ligne5
      pack $audace(base).fenetreSpData.et3.ligne5 -side top -fill x

      frame $audace(base).fenetreSpData.et3.deuxlignes
         frame $audace(base).fenetreSpData.et3.deuxlignes.f1
            #--- Sixi�me ligne de l'�tape 3
            frame $audace(base).fenetreSpData.et3.deuxlignes.f1.ligne6
               # Affichage du label "Nom du fichier destination"
               label $audace(base).fenetreSpData.et3.deuxlignes.f1.ligne6.lab1 -text $caption(specLhIII,spanglerot) \
                  -width 29 -justify right
               pack $audace(base).fenetreSpData.et3.deuxlignes.f1.ligne6.lab1 -side left
               # Affichage du champ de saisie "Nom du fichier source"
               entry $audace(base).fenetreSpData.et3.deuxlignes.f1.ligne6.ent1 -width 16 -relief flat\
                  -textvariable data_spbmfc(angleRot) -justify left -borderwidth 1 -relief groove -state disabled
               pack $audace(base).fenetreSpData.et3.deuxlignes.f1.ligne6.ent1 -side left
            pack $audace(base).fenetreSpData.et3.deuxlignes.f1.ligne6 -side top -fill x
            #--- Septi�me ligne de l'�tape 3
            frame $audace(base).fenetreSpData.et3.deuxlignes.f1.ligne7
               # Affichage du label
               label $audace(base).fenetreSpData.et3.deuxlignes.f1.ligne7.lab1 -text $caption(specLhIII,spcorrgeom) \
                  -width 29 -justify right
               pack $audace(base).fenetreSpData.et3.deuxlignes.f1.ligne7.lab1 -side left
               # Affichage du champ de saisie
               entry $audace(base).fenetreSpData.et3.deuxlignes.f1.ligne7.ent1 -width 16 -relief flat\
                  -textvariable data_spbmfc(CorrGeom) -justify left -borderwidth 1 -relief groove -state disabled
               pack $audace(base).fenetreSpData.et3.deuxlignes.f1.ligne7.ent1 -side left
               # Affichage de la case � cocher pour indiquer si le noir contient la pr�charge
               #--- Bouton "Effacer"
            pack $audace(base).fenetreSpData.et3.deuxlignes.f1.ligne7 -side top -fill x
         pack $audace(base).fenetreSpData.et3.deuxlignes.f1 -side left -fill x
         frame $audace(base).fenetreSpData.et3.deuxlignes.f2
            button $audace(base).fenetreSpData.et3.deuxlignes.f2.but1 -borderwidth 2 -width 10 -text $caption(specLhIII,speff) \
               -command ::spbmfc::effacerChampsCalcules
            pack $audace(base).fenetreSpData.et3.deuxlignes.f2.but1 -side left
         pack $audace(base).fenetreSpData.et3.deuxlignes.f2 -side left -fill x
      pack $audace(base).fenetreSpData.et3.deuxlignes -side top -fill x

   pack $audace(base).fenetreSpData.et3 -side top -fill x

   #--- Trame finale (boutons)
   frame $audace(base).fenetreSpData.et4 -borderwidth 2 -relief groove

      #--- Bouton "Effacer tout"
      button $audace(base).fenetreSpData.et4.but1 -borderwidth 2 -width 10 -text $caption(specLhIII,spefftout) \
         -command ::spbmfc::cdeEffacerTout
      pack $audace(base).fenetreSpData.et4.but1 -side left -anchor sw -in $audace(base).fenetreSpData.et4
      #--- Bouton "Annuler"
      button $audace(base).fenetreSpData.et4.but2 -borderwidth 2 -width 10 -text $caption(specLhIII,cancel) \
         -command ::spbmfc::cdeAnnuler
      pack $audace(base).fenetreSpData.et4.but2 -side left -anchor sw -in $audace(base).fenetreSpData.et4
      #--- Bouton "Aide"
      button $audace(base).fenetreSpData.et4.but3 -borderwidth 2 -width 10 -text $caption(specLhIII,sphelp) \
         -command ::spbmfc::cdeAide
      pack $audace(base).fenetreSpData.et4.but3 -side right -anchor sw -in $audace(base).fenetreSpData.et4
      #--- Bouton "Fermer"
      button $audace(base).fenetreSpData.et4.but4 -borderwidth 2 -width 10 -text $caption(specLhIII,spclose) \
         -command ::spbmfc::cdeFermer
      pack $audace(base).fenetreSpData.et4.but4 -side right -anchor sw -in $audace(base).fenetreSpData.et4
      #--- Bouton "Enregistrer"
      button $audace(base).fenetreSpData.et4.but5 -borderwidth 2 -width 10 -text $caption(specLhIII,spenreg) \
         -command ::spbmfc::cdeEnregistrer
      pack $audace(base).fenetreSpData.et4.but5 -side right -anchor sw -in $audace(base).fenetreSpData.et4
      #--- Bouton "Go"
      button $audace(base).fenetreSpData.et4.but6 -borderwidth 2 -width 10 -text $caption(specLhIII,spgo) \
         -command ::spbmfc::cdeGo
      pack $audace(base).fenetreSpData.et4.but6 -side right -anchor sw -in $audace(base).fenetreSpData.et4

   pack $audace(base).fenetreSpData.et4 -side top -fill x

   focus $audace(base).fenetreSpData

   #--- Mise a jour dynamique des couleurs
   ::confColor::applyColor $audace(base).fenetreSpData
}

#---------------------------------------------------------------------------------------------
# Fin du fichier spbmfc.tcl
#---------------------------------------------------------------------------------------------

