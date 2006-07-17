#
# Fichier : quickremote.tcl
# Description : Interface de liaison QuickRemote
# Auteurs : Robert DELMAS et Michel PUJOL
# Mise a jour $Id: quickremote.tcl,v 1.2 2006-06-20 19:29:41 robertdelmas Exp $
#

package provide quickremote 1.0

#
# Procedures generiques obligatoires (pour configurer tous les drivers camera, telescope, equipement) :
#     init              : initialise le namespace (appelee pendant le chargement de ce source)
#     getDriverName     : retourne le nom du driver
#     getLabel          : retourne le nom affichable du driver 
#     getHelp           : retourne la documentation htm associee
#     getDriverType     : retourne le type de driver (pour classer le driver dans le menu principal)
#     initConf          : initialise les parametres de configuration s'il n'existe pas dans le tableau conf()
#     fillConfigPage    : affiche la fenetre de configuration de ce driver 
#     confToWidget      : copie le tableau conf() dans les variables des widgets
#     widgetToConf      : copie les variables des widgets dans le tableau conf()
#     configureDriver   : configure le driver 
#     stopDriver        : arrete le driver et libere les ressources occupees
#     isReady           : informe de l'etat de fonctionnement du driver
#
# Procedures specifiques a ce driver :
#     

namespace eval quickremote {
   variable This
   global quickremote

   #==============================================================
   # Procedures generiques de configuration des drivers
   #==============================================================

   #------------------------------------------------------------
   #  init (est lance automatiquement au chargement de ce fichier tcl)
   #     initialise le driver
   #  
   #  return namespace name
   #------------------------------------------------------------
   proc init { } {
      global audace

      #--- Charge le fichier caption
      uplevel #0  "source \"[ file join $audace(rep_plugin) link quickremote quickremote.cap ]\""

      #--- Cree les variables dans conf(...) si elles n'existent pas
      initConf

      #--- J'initialise les variables widget(..)
      confToWidget

      return [namespace current]
   }

   #------------------------------------------------------------
   #  getDriverType
   #     retourne le type de driver
   #  
   #  return "link"
   #------------------------------------------------------------
   proc getDriverType { } {
      return "link"
   }

   #------------------------------------------------------------
   #  getLabel
   #     retourne le label du driver
   #  
   #  return "Titre de l'onglet (dans la langue de l'utilisateur)"
   #------------------------------------------------------------
   proc getLabel { } {
      global caption

      return "$caption(quickremote,titre)"
   }

   #------------------------------------------------------------
   #  getHelp
   #     retourne la documentation du driver
   #  
   #  return "nom_driver.htm"
   #------------------------------------------------------------
   proc getHelp { } {

      return "quickremote.htm"
   }

   #------------------------------------------------------------
   #  initConf 
   #     initialise les parametres dans le tableau conf()
   #  
   #  return rien
   #------------------------------------------------------------
   proc initConf { } {
      global conf

      return
   }

   #------------------------------------------------------------
   #  confToWidget 
   #     copie les parametres du tableau conf() dans les variables des widgets
   #  
   #  return rien
   #------------------------------------------------------------
   proc confToWidget { } {
      variable widget
      global conf

   }

   #------------------------------------------------------------
   #  widgetToConf
   #     copie les variables des widgets dans le tableau conf()
   #  
   #  return rien
   #------------------------------------------------------------
   proc widgetToConf { } {
      variable widget
      global conf

   }

   #------------------------------------------------------------
   #  fillConfigPage
   #     fenetre de configuration du driver
   #  
   #  return nothing
   #------------------------------------------------------------
   proc fillConfigPage { frm } {
      variable widget
      global caption

      #--- Je memorise la reference de la frame
      set widget(frm) $frm

   }

   #------------------------------------------------------------
   #  configureDriver
   #     configure le driver
   #  
   #  return nothing
   #------------------------------------------------------------
   proc configureDriver { } {
      global audace

      #--- Affiche la liaison
      quickremote::run "$audace(base).quickremote"

      return
   }

   #------------------------------------------------------------
   #  stopDriver
   #     arrete le driver et libere les ressources occupees
   #  
   #  return nothing
   #------------------------------------------------------------
   proc stopDriver { } {

      #--- Ferme la liaison
      fermer
      return
   }

   #------------------------------------------------------------
   #  isReady 
   #     informe de l'etat de fonctionnement du driver
   #  
   #  return 0 (ready) , 1 (not ready)
   #------------------------------------------------------------
   proc isReady { } {

      return 0
   }

}

::quickremote::init

