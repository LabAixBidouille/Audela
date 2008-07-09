#
# Fichier : menu.tcl
# Description : Package pour gerer facilement les menus
# Auteur : Denis MARCHAIS d'apres B. Welsh, Practical Programming in Tcl and Tk, Ed. 2, p.319-322
# Mise a jour $Id: menu.tcl,v 1.7 2007-06-16 08:39:34 robertdelmas Exp $
#

proc Menu_Setup { visuNo menubar } {
   global menu

   menu $menubar
   #--- Associated menu with its main window
   set top [winfo parent $menubar]
   $top config -menu $menubar
   $menubar configure -relief flat
   set menu(menubar$visuNo) $menubar
   if { [info exists menu(uid)] } {
      incr menu(uid)
   } else {
      set menu(uid) 0
   }
}

proc Menubar_Delete { visuNo } {
   global menu

   #--- Je supprime tous les menus contenus dans le menubar
   set menuList [array names menu menu$visuNo,* ]
   foreach key $menuList {
      set menuName [lindex [split $key ","] 1]
      Menu_Delete $visuNo $menuName all
   }

   #--- Je supprime le menubar
   destroy $menu(menubar$visuNo)
   array unset menu menubar$visuNo
}

proc Menu { visuNo menuName } {
   global menu

   if [info exists menu(menu$visuNo,$menuName)] {
      error "Menu $menuName already defined"
   }
   #--- Create the cascade menu
   set menuId $menu(menubar$visuNo).mb$menu(uid)
   incr menu(uid)
   menu $menuId -tearoff 1
   $menu(menubar$visuNo) add cascade -label $menuName -menu $menuId
   #--- Remember the name to menu mapping
   set menu(menu$visuNo,$menuName) $menuId
}

proc MenuGet { visuNo menuName } {
   global menu

   if [info exist menu(menu$visuNo,$menuName) ] {
      set menuId $menu(menu$visuNo,$menuName)
   } else {
      return -code error "No such menu: $menuName"
   }
   return $menuId
}

proc Menu_Command { visuNo menuName label command } {
   set menuId [MenuGet $visuNo $menuName]
   $menuId add command -label $label -command $command
}

proc Menu_Command_Radiobutton { visuNo menuName label value variable command } {
   set menuId [MenuGet $visuNo $menuName]
   $menuId add radiobutton -label $label -indicatoron "1" -variable $variable -value $value -command $command
}

proc Menu_Check { visuNo menuName label var { command { } } } {
   set menuId [MenuGet $visuNo $menuName]
   $menuId add check -label $label -command $command -variable $var
}

proc Menu_Radio { visuNo menuName label var {val { } } {command { } } } {
   set menuId [MenuGet $visuNo $menuName]
   if {[string length $val] == 0} {
      set val $label
   }
   $menuId add radio -label $label -command $command -value $val -variable $var
}

proc Menu_Separator { visuNo menuName } {
   [MenuGet $visuNo $menuName] add separator
}

proc Menu_Cascade { visuNo menuName label } {
   global menu

   set menuId [MenuGet $visuNo $menuName]
   if [info exists menu(menu$visuNo,$label)] {
      error "Menu $label already defined"
   }
   set sub $menuId.sub$menu(uid)
   incr menu(uid)
   menu $sub -tearoff 0
   $menuId add cascade -label $label -menu $sub
   set menu(menu$visuNo,$label) $sub
}

proc Menu_Bind { visuNo what sequence menuName label seqText } {
   global menu

   set menuId [MenuGet $visuNo "$menuName"]
   if [catch {$menuId index "$label"} index] {
      error "$label not in menu $menuName"
   }
   set command [$menuId entrycget $index -command]
   bind $what $sequence $command
   $menuId entryconfigure $index -accelerator "$seqText"
}

proc Menu_Configure { visuNo menuName label optionName optionValue } {
   global menu

   set menuId [MenuGet $visuNo "$menuName"]
   if [catch {$menuId index "$label"} index] {
      error "$label not in menu $menuName"
   }
   $menuId entryconfigure $index $optionName $optionValue
}

#------------------------------------------------------------
#  Menu_Delete
#     supprime un menu et/ou ses entrees
#
#  parametres :
#     visuNo : numero de la visu
#     menuName : nom du menu
#     index : numero d'entree ou "items" "all"
#        numera d'entree : supprime l'entee correspondant à l'index
#        "entries" : supprime toutes les entrées
#        "all" :  supprime toutes les entrées et le menu
#------------------------------------------------------------
proc Menu_Delete { visuNo menuName index } {
   global menu

   if { [string compare $index "all"] ==0 || [string compare $index "entries"] ==0 } {
      set menuId [MenuGet $visuNo "$menuName"]

      #--- On efface toutes les entrees si ce n'est pas un sous menu
      #---- (les sous menus sont effaces en meme temps que leur menu parent)
      if { [ string first sub $menuId] == -1 } {
         for {set index2 [$menuId index last]} {$index2 > 0} {incr index2 -1} {
            $menuId delete $index2
         }
      }

      if { $index == "all" } {
         #--- Je supprime le menu
         destroy $menuId
         #--- Je supprime sa declaration dans la variable globale menu
         array unset menu menu$visuNo,$menuName

      }
   } else {
      #--- On efface juste la i_eme entree (si elle existe)
      set menuId [MenuGet $visuNo "$menuName"]
      if { ($index >= 1) && ($index <= [$menuId index last]) } {
         $menuId delete $index
      }
   }
}

