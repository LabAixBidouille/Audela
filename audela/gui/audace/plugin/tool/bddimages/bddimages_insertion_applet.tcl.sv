#--------------------------------------------------  
#  init_info { }
#--------------------------------------------------  
#
#    fonction  : 
#       Initialisation de la liste des fichiers 
#       du repertoire "incoming" dans conf(dirinco)
#       pour l affichage dans la table.
#        
#    procedure externe :
#             globrdk
#     
#    variables en entree : 
#
#    variables en sortie : 
#   
#--------------------------------------------------  
   proc init_info { } {
   
      global bddconf
      global caption
      global maliste   

      #--- Chargement des captions
      uplevel #0 "source \"[ file join $bddconf(rep_plug) bddimages_insertion.cap ]\""

      set bddconf(liste) [list "$caption(bddimages_insertion,etat) \
                                $caption(bddimages_insertion,nom) \
                                $caption(bddimages_insertion,dateobs) \
                                $caption(bddimages_insertion,telescope)\
                                $caption(bddimages_insertion,taille) \
                                $caption(bddimages_insertion,erreur)" ]

      set listfile {}
      set maliste {}


      globrdk $bddconf(dirinco) $bddconf(limit)


      set err [catch {set list_file [lsort -increasing $maliste]} result]

      if {$err==0} {
        
      foreach fichier $list_file {
        set fic [file tail "$fichier"]
        lappend listfile [list "?" "$fichier" "NULL" "NULL" "NULL" "NULL"]
        }
      } else {
        bddimages_sauve_fich "init_info: pas de fichier"
      }

      lappend bddconf(liste) $listfile
      return
   }

#--------------------------------------------------  
#  info_fichier { nomfich dir }
#--------------------------------------------------  
#
#    fonction  : 
#       Lecture de la taille du fichier et de la
#       liste des Champs du header.
#       On charge l image en memoire ici
#        
#    procedure externe :
#       buf1 : fonction audela de lecture de l'image
#     
#       bddimages_entete_preminforecon : reconnaissance
#              des champs necessaires a l'insertion de
#              l'image dans la base
#
#     
#    variables en entree : 
#       nomfich = Nom de l image
#       dir     = repertoire de l image
#
#    variables en sortie : 
#       list = $erreur $sizefich $list_keys
#  
#--------------------------------------------------  

   proc info_fichier { nomfich } {
     global bddconf

     set erreur    0
     set etat      "X"
     set dateiso   "-"
     set site      "-"
     set sizefich  "Unknown"
     set tabkey    "-"
     set bufno $bddconf(bufno)

     # --- Recupere la taille de l'image
     set errnum [catch {set sizefich [file size $nomfich]} msg ]
     if {$errnum!=0} { return [list 1 $etat $nomfich $dateiso $site $sizefich $tabkey] }

     # --- Recupere l'extension du fichier
     set result [bddimages_formatfichier $nomfich]
     set form2  [lindex $result 0]
     set racinefich  [lindex $result 1]

     # --- renomme le fichier pour que l'extension soit en minuscule 
     set errnum [catch {file rename $nomfich "$racinefich.$form2"} msg]
     if {$errnum!=0} {
       if {[string last "file already exists" $msg]<=1} {
         bddimages_sauve_fich "info_fichier: ERREUR 9 : Renommage du fichier $nomfich impossible <err:$errnum> <msg:$msg>"
         return [list "9" $etat $nomfich $dateiso $site $sizefich $tabkey] 
         }
       } else {
       set nomfich "$racinefich.$form2"
       }

     # --- dezippe le fichier s il est zippé
     if {$form2=="fit.gz"||$form2=="fits.gz"||$form2=="cata.txt.gz"} {
       set errnum [catch {exec gunzip $nomfich} msgzip ]
       if {$errnum==0} {
         set nomfichfits [string range $nomfich 0 [expr [string last .gz $nomfich] -1]]     
         } else {
         bddimages_sauve_fich "info_fichier: ERREUR 8 : Archive invalide <err:$errnum> <msg:$msgzip>"
         return [list "8" $etat $nomfich $dateiso $site $sizefich $tabkey] 
         }
       } else {
       set nomfichfits $nomfich
       }

     # --- Charge l'image en memoire
     set errnum [catch {buf$bufno load $nomfichfits} msg ]
     if { $errnum != 0 } {
       bddimages_sauve_fich "info_fichier: ERREUR 3 : Erreur de Chargement de l image en memoire <err:$errnum> <msg:$msg>"
       return [list "3" $etat $nomfichfits $dateiso $site $sizefich $tabkey]
       }

     # --- zip/rezip l'image 
     set errnum [catch {exec gzip $nomfichfits} msg ]
     if {$errnum!=0} { 
       bddimages_sauve_fich "info_fichier: ERREUR 2 : Erreur lors de la recompression de l'image $nomfichfits  <err:$errnum> <msg:$msg>"
       return [list "2" $etat $nomfichfits $dateiso $site $sizefich $tabkey] 
       }
     set nomfich "$nomfichfits.gz"

     # --- Recuperation des champs du header FITS
     set errnum [catch {set list_keys [buf$bufno getkwds]} msg ]
     if {$errnum!=0} { 
       bddimages_sauve_fich "info_fichier: ERREUR 4 : Erreur lors de la lecture du header de l'image <err:$errnum> <msg:$msg>"
       return [list 4 $etat $nomfich $dateiso $site $sizefich $tabkey] 
       }
       
     # Creation de la liste des champs et valeurs
     set tabkey {}
     foreach key $list_keys {
       set garde "ok"
       if {$key==""} {set garde "no"}
       foreach rekey $tabkey {
         if {$key==$rekey} {set garde "no"}
         }
       if {$garde=="ok"} {
         lappend tabkey [list $key [buf$bufno getkwd $key] ]
         }
       }

     set champs  [bddimages_entete_preminforecon $tabkey]
     set err     [lindex $champs 0]
     set dateiso [lindex $champs 1]
     set site    [lindex $champs 2]

     switch $err {
       "0" { set etat  "!" }
       "1" { set erreur 5 }
       "2" { set erreur 6 }
        default { set erreur 7 }
       }

    return [list $erreur $etat $nomfich $dateiso $site $sizefich $tabkey]
   }

#--------------------------------------------------  
#  lecture_info { This }
#--------------------------------------------------  
#
#    fonction  : 
#       Obtention de la liste des champs du
#       header pour les images de la liste
#
#    procedure externe :
#
#    variables en entree :
#       this = chemin de la fenetre
#
#    variables en sortie :
#  
#--------------------------------------------------  
   proc lecture_info { This } {

   global conf
   global bddconf
   global caption
   global entetelog   

      set listeentiere [ $::bddimages_insertion::This.frame7.tbl get 0 end ]
      set nbimg [ llength $listeentiere ]

      set nbimgins 0
      set nbimgerr 0

      set bddconf(listetotale) {}
      if { $nbimg != "0" } {
         for { set i 0 } { $i <= [ expr $nbimg - 1 ] } { incr i } {

           set ligne     [lindex $listeentiere $i]
           set nomfich   [lindex $ligne 1]
           set result    [info_fichier $nomfich]
           set erreur    [lindex $result 0]
           set etat      [lindex $result 1]
           set nomfich   [lindex $result 2]
           set dateiso   [lindex $result 3]
           set site      [lindex $result 4]
           set sizefich  [lindex $result 5]
           set tabkey    [lindex $result 6]

           set fic [file tail $nomfich]
           set entetelog $fic

           if {$erreur!=0} {
             incr nbimgerr
             set dirpb "$conf(direrr)"
             createdir_ifnot_exist $dirpb
             set dirpb "$conf(direrr)/err$erreur"
             createdir_ifnot_exist $dirpb
             bddimages_sauve_fich "lecture_info: Deplacement du fichier $nomfich dans $dirpb"
             set errnum [catch {file rename $nomfich $dirpb/} msg]

             set errcp [string first "file already exists" $msg]
             if {$errcp>0||$errnum==0} {
               set errnum [catch {file delete $nomfich} msg]
               if {$errnum!=0} {
                 bddimages_sauve_fich "lecture_info: ERREUR 111 : effacement de $nomfich impossible <err=$errnum> <msg=$msg>"
                 return 111
                 } else {
                 bddimages_sauve_fich "lecture_info: Fichier $nomfich supprime"
                 }
               }               
             set erreur "Erreur <$erreur> : $caption(bddimages_insertion,err$erreur)"
             }
           set ligne [list $etat $nomfich $dateiso $site $sizefich $erreur]
           $::bddimages_insertion::This.frame7.tbl delete $i
           $::bddimages_insertion::This.frame7.tbl insert $i $ligne
           # Modifie l affichage de nbimg nbimgins nbimgerr
           set bddconf(inserinfo) "Total($nbimg) Inser($nbimgins) Err($nbimgerr)"
           lappend bddconf(listetotale) [list "!" $nomfich $dateiso $site $sizefich $erreur $tabkey]
           update
           }
         }
 
   set bddconf(nbimg)    $nbimg
   set bddconf(nbimgins) $nbimgins
   set bddconf(nbimgerr) $nbimgerr

   return
   }


#--------------------------------------------------  
#  insertion { This }
#--------------------------------------------------  
#
#    fonction  : 
#       Insertion des images en 3 modes :
#         - selection d images
#         - tout inserer
#         - insertion automatique attente d images 
#             dans le repertoire incoming 
#        
#    procedure externe :
#     
#    variables en entree : 
#       this = chemin de la fenetre
#
#    variables en sortie : 
#  
#--------------------------------------------------  
   proc insertion { This } {

   global conf
   global bddconf
   global caption
   global audace

   uplevel #0 "source \"[ file join $audace(rep_plugin) tool bddimages bddimages_sub_insertion.tcl ]\""

# Mode d insertion automatique
  if {$bddconf(inserauto)==1} {
      insertion_auto
      return
      }


# Autre Mode d insertion  
   ::console::affiche_resultat "Insertion ... \n"

   for { set i 0 } { $i <= [ expr [llength $bddconf(listetotale)] - 1 ] } { incr i } {

     set selectfich [$::bddimages_insertion::This.frame7.tbl selection includes $i]

     if {$selectfich==1} {

       set nomfich [lindex [$::bddimages_insertion::This.frame7.tbl get $i] 1]
       set etat    [lindex [$::bddimages_insertion::This.frame7.tbl get $i] 0]

       switch $etat {
         "?" { }
         "X" { }
         "0" { }
         "!" {
              foreach ligne $bddconf(listetotale) {
                set nomfichinfo [lindex $ligne 1]
                if {$nomfichinfo==$nomfich} {
                    set etat      [lindex $ligne 0]
                    set dateobs   [lindex $ligne 2]
                    set site      [lindex $ligne 3]
                    set sizefich  [lindex $ligne 4]
                    set liste     [bddimages_insertion_unfich $ligne]
                    set err       [lindex $liste 0]
                    set nomfich   [lindex $liste 1]
                    if {$err==-1} {break}
                    if {$err==0} {
                      incr bddconf(nbimgins)
                      set etat "O"
                      set err "$caption(bddimages_insertion,err$err)"
                    } else {
                      incr bddconf(nbimgerr)
                      set etat "X"
                      set err "Erreur <$err> : $caption(bddimages_insertion,err$err)"
                    }
                    set ligne [list $etat $nomfich $dateobs $site $sizefich $err]
                    $::bddimages_insertion::This.frame7.tbl delete $i
                    $::bddimages_insertion::This.frame7.tbl insert $i $ligne
                    # Modifie l affichage de nbimg nbimgins nbimgerr
                    set bddconf(inserinfo) "Total($bddconf(nbimg)) Inser($bddconf(nbimgins)) Err($bddconf(nbimgerr))"
                    }
                  update
                  }
                }

         default { }
         }


       }
     }


 
   }


#--------------------------------------------------  
#  insertion_auto {  }
#--------------------------------------------------  
#
#    fonction  : 
#       Insertion des images en mode automatique :
#       attente d images dans le repertoire incoming 
#        
#    procedure externe :
#     
#    variables en entree : 
#       this = chemin de la fenetre
#
#    variables en sortie : 
#  
#--------------------------------------------------  
  proc insertion_auto { } {

  global conf
  global bddconf
  global caption
  global entetelog   

  set nbimg             0
  set nbimgins          0
  set nbimgerr          0
  set bddconf(nbimg)    0
  set bddconf(nbimgerr) 0
  set bddconf(nbimgins) 0

  ::console::affiche_resultat "Insertion Automatique \n"

  set fichlock "$conf(dirinco)/lock"
     
  while { 0 < 1 } {
    # RAZ de la Table

    if {[file exists $fichlock]==1} {
       update
       after 60000      
       } else {

        set bddconf(liste) {}

#        ::bddimages_insertion::init_info
        init_info
        set listetitre [lindex $bddconf(liste) 0]
        set listeval [lindex $bddconf(liste) 1]
        set listeval [lrange $listeval 0 999]
        set bddconf(liste) [list $listetitre $listeval]

       catch {
           ::bddimages_insertion::getFormatColumn
          $::bddimages_insertion::This.frame7.tbl delete 0 end
          $::bddimages_insertion::This.frame7.tbl deletecolumns 0 end
          }

        ::bddimages_insertion::Affiche_Results

        set nbcol        [ $::bddimages_insertion::This.frame7.tbl columncount ]
        set listeentiere [ $::bddimages_insertion::This.frame7.tbl get 0 end ]      

        set nbimg        [ llength $listeentiere ]
        if {$nbimg == 0} {
          update
          after 10000
          } 


        set bddconf(listetotale) {}

        if { $nbimg != "0" } {

           set bddconf(nbimg) [expr $bddconf(nbimg) + $nbimg]

           for { set i 0 } { $i <= [ expr $nbimg - 1 ] } { incr i } {

              if {[file exists $fichlock]==1} {break}

              set ligne     [lindex $listeentiere $i]
              set nomfich   [lindex $ligne 1]
              set result    [info_fichier $nomfich]
              set erreur    [lindex $result 0]
              set etat      [lindex $result 1]
              set nomfich   [lindex $result 2]
              set dateiso   [lindex $result 3]
              set site      [lindex $result 4]
              set sizefich  [lindex $result 5]
              set tabkey    [lindex $result 6]

              set fic [file tail $nomfich]
              set entetelog $fic

              bddimages_sauve_fich "insertion_auto:Debute"

              set ligne [list $etat $nomfich $dateiso $site $sizefich $erreur $tabkey]
              $::bddimages_insertion::This.frame7.tbl delete $i
              $::bddimages_insertion::This.frame7.tbl insert $i $ligne

              if {$erreur!=0} {
                incr bddconf(nbimgerr)
                set dirpb "$conf(direrr)"
                createdir_ifnot_exist $dirpb
                set dirpb "$conf(direrr)/err$erreur"
                createdir_ifnot_exist $dirpb
                bddimages_sauve_fich "insertion_auto: Deplacement du fichier $nomfich dans $dirpb"
                set errnum [catch {file rename $nomfich $dirpb/} msg]
                set errcp [string first "file already exists" $msg]
                if {$errcp>0||$errnum==0} {
                  set errnum [catch {file delete $nomfich} msg]
                  if {$errnum!=0} {
                    bddimages_sauve_fich "insertion_auto: ERREUR 111 : effacement de $nomfich impossible <err=$errnum> <msg=$msg>"
                    return 111
                    } else {
                    bddimages_sauve_fich "insertion_auto: Fichier $nomfich supprime"
                    }
                  }               
                set erreur "Erreur <$erreur> : $caption(bddimages_insertion,err$erreur)"
                }
              set ligne [list $etat $nomfich $dateiso $site $sizefich $erreur $tabkey]
              $::bddimages_insertion::This.frame7.tbl delete $i
              $::bddimages_insertion::This.frame7.tbl insert $i $ligne
              # Modifie l affichage de nbimg nbimgins nbimgerr
              set bddconf(inserinfo) "Total($bddconf(nbimg)) Inser($bddconf(nbimgins)) Err($bddconf(nbimgerr))"
   #           lappend bddconf(listetotale) [list "!" $nomfich $dateiso $site $sizefich $erreur $tabkey]

              if {$erreur==0} {

                 # Ici se fait l'Insertion de l image

                 set liste     [bddimages_insertion_unfich $ligne]

                 set err       [lindex $liste 0]
                 set nomfich   [lindex $liste 1]
                 if {$err==-1} {break}
                 if {$err==0} {
                   incr bddconf(nbimgins)
                   set etat "O"
                   set err "$caption(bddimages_insertion,err$err)"
                   } else {
                   incr bddconf(nbimgerr)
                   set etat "X"
                   set err "Erreur <$err> : $caption(bddimages_insertion,err$err)"
                   }
                   set ligne [list $etat $nomfich $dateiso $site $sizefich $err]
                   $::bddimages_insertion::This.frame7.tbl delete $i
                   $::bddimages_insertion::This.frame7.tbl insert $i $ligne
                   # Modifie l affichage de nbimg nbimgins nbimgerr
                   set bddconf(inserinfo) "Total($bddconf(nbimg)) Inser($bddconf(nbimgins)) Err($bddconf(nbimgerr))"
                }
                # Fin: if {$erreur==0}
           update
           }
           # Fin: boucle for
        }
        # Fin: if { $nbimg != "0" }

      }
      #if file exists $fichlock
   }
   # Fin: while
}
# Fin: proc
