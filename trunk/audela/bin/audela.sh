#!/bin/bash
#------ Benjamin Mauclaire 2004 for AudeLA's team ---------#

echo -e "Lancement AudeLA..."
chemin=`pwd`
typeset -x LD_LIBRARY_PATH=$chemin
#${chemin}/audela $*
./audela $*
