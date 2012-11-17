#
# Fichier : collector_utils.tcl
# Description :
# Auteur : Raymond Zachantke
# Mise à jour $Id$
#

   #--   Liste des proc utilitaires       utilisee par
   # ::collector::testPattern             binding de validation des entry string
   # ::collector::testNumeric             binding de validation des entry numeriques
   # ::collector::updateEtc               testNumeric
   # ::collector::activeOnglet            configLed
   # ::collector::createIcon              initCollector
   # ::collector::avertiUser              testPattern, testNumeric et updateEtc

   #---------------------------------------------------------------------------
   #  testPattern
   #  Valide les saisies
   #  Parametre : nom de la variable modifiee
   #---------------------------------------------------------------------------
   proc testPattern { child } {
      variable private
      global caption

      set newValue $private($child)

      #--   controle le bon format
      set test 0
      switch -exact $child {
         ra        { set test [regexp {([0-9]{1,2}h[0-9]{1,2}m[0-9]{1,2}s)([0-9]?)} $newValue]}
         dec       { set test [regexp {([-\+])?([0-9]{1,2}d[0-9]{1,2}m[0-9]{1,2}s)([0-9]?)} $newValue]}
         tu        { set test [regexp {([0-9]{4}-[0-9]{2}-[0-9]{2}T[0-9]{2}:[0-9]{2}:[0-9]{2})(|\.[0-9]+)?} $newValue]}
         objname   { regexp -all {([\w|-|_]+)} $newValue match
                     if {[string length $newValue] == [string length $match]} {set test 1}
                   }
         parkaz    { if {$newValue >= 0. && $newValue < 360.} {set test 1}}
         parkelev  { if {$newValue <= +90.0 && $newValue >= -90.0} {set test 1}}
      }

      if {$test == 1} {
         #--   remplace l'ancienne valeur par la nouvelle
         set private(prev,$child) $newValue
         updateInfo $child
      } else {
         #--   message si echec
         avertiUser [format $caption(collector,invalid) $newValue "$caption(collector,$child)"]
         #--   retablit l'ancienne valeur
         set private($child) $private(prev,$child)
      }
   }

   #---------------------------------------------------------------------------
   #  testNumeric
   #  Valide les saisies : toutes sont des nombres >= 0 sauf la magnitude
   #  Parametres : nom de la variable modifiee, ancienne et nouvelle valeur
   #---------------------------------------------------------------------------
   proc testNumeric { child } {
      variable private
      global caption cameras

      set newValue $private($child)

      if {[TestReel $newValue] == 1} {

         #--   identifie la variable etc_tools
         set etc_variables $private(etc_variables)
         set key [lindex [lsearch -inline -exact -ascii -all -index 0 $etc_variables $child] {0 1}]

         if {$key ne ""} {
            #--   met a jour la variable etc_tools
            updateEtc $key $newValue

            #--   met a jour l'array
            set k [lsearch -exact [list naxis1 naxis2 photocell1 photocell2 C_th G N_ro eta Em] $key]
            if {$k != -1} {
               if {$key in [list photocell1 photocell2]} {
                  set $newValue [expr { $newValue * 1e-6 }]
               }
               lassign [array get cameras $private(detnam)] detnam data
               array set cameras [list $detnam [lreplace $data $k $k $newValue]]
            }
         }

         #--   remplace l'ancienne valeur par la nouvelle
         set private(prev,$child) $newValue
         updateInfo $child

      } else {

         #--   message si echec
         avertiUser [format $caption(collector,invalid) $newValue "$caption(collector,$child)"]
         #--   retablit l'ancienne valeur
         set private($child) $private(prev,$child)

      }
   }

   #---------------------------------------------------------------------------
   #  updateEtc
   #  Met a jour la variable etc_tools
   #  Parametre : nom de la variable etc_tools et sa nouvelle valeur
   #---------------------------------------------------------------------------
   proc updateEtc { key value } {
      variable private
      global audace caption

      #--   apporte des corrections
      if {$key in [list D FonD]} {
         set private(foclen) [expr { $private(aptdia) * $private(fond) }]
      } elseif {$key in [list Fwhm_psf_opt photocell1 photocell2]} {
         set value [expr { $value * 1e-6 }]
      } elseif {$key eq "Foclen"} {
         set key FonD
         set value [expr { $value / $private(aptdia) }]
         set private(fond) [format %0.2f $value]
      }

      #--   identifie le nom de la variable etc
      set var_name audace([ lsearch -regexp -all -inline [array names audace] "(etc)\,.+\,($key)$" ])

      #--   met a jour la variable etc_tools
      set $var_name $value

      #::console::affiche_resultat "updateEtc $key $var_name [set $var_name]\n"

      if {[set $var_name] != $value} {
         avertiUser "[format $caption(collector,noMatch) $var_name $value]"
      }
   }

   #---------------------------------------------------------------------------
   #  activeOnglet
   #  Avtive un onglet du notebook
   #  Paremetre : nom de l'onglet a selectionner
   #---------------------------------------------------------------------------
   proc activeOnglet { onglet } {
      variable private

      $private(This).n select $private(This).n.$onglet
   }

   #--------------------------------------------------------------------------
   #  createIcon
   #--------------------------------------------------------------------------
   proc createIcon { icon } {
      variable private

      set private($icon) [image create photo]
      switch -exact $icon {
         "greenLed"  {  set data {R0lGODlhDgAOALMAAAA4UgBAXgCBKQCZfgDUihH/+k3/hVD/TYj/roj/6J3/
                           iKH/cMP/1rH/oM//3v///yH5BAEAAA8ALAAAAAAOAA4AAART8Ek5Qhgzv5t6
                           qhqAOGSJABNQNJ7XFOgjGEht14bwDARh/IjfrzfgCY9CQtEHtCWXzdsQAzjU
                           Fo3GonaIAWjYrDYYe4jE4lMIoGAwFICyxiyXRAAAOw==}
                     }
         "redLed"    {  set data {R0lGODlhDgAOAMQAAD0AAD0AAJMAAJMAAOkAAGkAANMAAP8AAP89Pf9lAP9l
                           AP9laf+TPf+Tk/+nkf/Qaf/p6f//////////////////////////////////
                           /////////////////////////yH5BAEAAB8ALAAAAAAOAA4AAAVf4CeKRVmM
                           6FcYy/MsxokGCmTfSjCuTu/3MRHgoCgaiweASkA4JI6JA0FQGhyuTgX2MCg1
                           iQoEAiktXcMIBkOsPZwMiXRj3lgnDKQwnY5IyFQIPz0If3kPPQ8KhSgmiyEA
                           Ow==}
                     }
         "baguette"  {  set data {R0lGODlhEAAQAIIAMQUEBYmJhFpZUTAwKt7e3K6wqff593FwaywAAAAAEAAQ
                           AAIDNAi63P4wyskOHWCUETA8RUEQliQYBhEIkaASYec1LBAcApdLQz7MkUGJ
                           AtgRAQcgr0YEJgAAOw==}
                     }
         "chaudron"  { set data {R0lGODlhEAAQAIMAMQ4KB5mLbpFOINPSzrdkHlBFKtqQL4xvR0cpF8ylXPr7
                          +mlhR6qmlr63rNB5JCchFSwAAAAAEAAQAAMEfXCoOdhaZR0m6QzPg1xY2HjD
                          UwTBRqooEBb0DCtSAOz8HgKexaNHBJwkh6IMgDDiFDriQ4CgoqhTxJTANaAO
                          BIEj7DAYHAnK4HAwu9+Cw2B+EBDKb4eY3bgI/lxcgAcBHAoWAQZ2BGBxCxId
                          DA2ECQGVHB0Nc3MtDByamwMRADs=}
                     }
      }
      $private($icon) put $data
   }

   #---------------------------------------------------------------------------
   #  avertiUser
   #  Affiche un message d'avertissement ou d'erreur
   #  Paremetre : msg message a afficher
   #---------------------------------------------------------------------------
   proc avertiUser { msg } {
      global caption

      tk_messageBox -title "$caption(collector,attention)" \
         -icon error -type ok -message "$msg"
   }

   #------------------------------------------------------------
   #  editPrivate :
   #  Edite les variables private et de leur valeur
   #------------------------------------------------------------
   proc editPrivate { } {
      variable private

      ::console::affiche_resultat "liste des [array size private] variables \"private\"\n\n"
      foreach v [lsort -dictionary [array names private]] {
        ::console::affiche_resultat "private($v) $private($v)\n"
      }
   }

   #------------------------------------------------------------
   #  editCamerasArray :
   #  Edite la liste des caméras et leurs caracteristiques dans la Console
   #------------------------------------------------------------
   proc editCamerasArray { } {
      global conf

      set camList [::struct::list map $conf(collector,cam) {::collector::extractIndex 0}]
      set data [::struct::list map $conf(collector,cam) {::collector::extractIndex 1}]
      ::console::affiche_resultat "$camList\n"
      foreach cam $camList d $data {
         ::console::affiche_resultat "$cam $d\n"
      }
   }

