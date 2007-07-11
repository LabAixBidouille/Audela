#!/bin/bash
#------ Benjamin Mauclaire 2004 for AudeLA's team ---------#

echo -e "Se mettre dans le repertoire bin...\n"
chemin=`pwd`
typeset -x LD_LIBRARY_PATH=$chemin
./audela $*

