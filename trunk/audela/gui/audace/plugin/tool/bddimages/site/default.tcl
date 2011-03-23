#
# Mise à jour $Id$
#

proc chg_tabkey {tabkey} {

   #     0         1         2
   #       0123456789012345678901
   # date <2006-06-23T20:22:36.08>

   set dateobs [get_tabkey $tabkey "DATE-OBS"]

   if { [regexp {(\d+)-(\d+)-(\d+)( |T)(\d+):(\d+):(\d+)(\.*\d*)} $dateobs dateiso aa mm jj sep h m s sd] } {

      # Si date ISO
      set dateiso "${aa}-${mm}-${jj}T${h}:${m}:${s}${sd}"
      set tabkey [update_tabkey $tabkey "DATE-OBS" $dateiso]
      return [list 0 $tabkey]

   } else {

      # Sinon
      return [list 1 "-"]

   }

}

