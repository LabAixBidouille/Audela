
# source $audace(rep_install)/gui/audace/plugin/tool/bddimages/utils/ssp_sex/main.tcl

set path0 "$audace(rep_install)/gui/audace/plugin/tool/bddimages/utils/ssp_sex"
loadima ${path0}/t1m_20110413_034512_858.fits

set ra [lindex [buf$audace(bufNo) getkwd RA] 1]
set dec [lindex [buf$audace(bufNo) getkwd DEC] 1]
set pixsize1 [lindex [buf$audace(bufNo) getkwd PIXSIZE1] 1]
set pixsize2 [lindex [buf$audace(bufNo) getkwd PIXSIZE2] 1]
set foclen [lindex [buf$audace(bufNo) getkwd FOCLEN] 1]

calibwcs $ra $dec $pixsize1 $pixsize2 $foclen USNO c:/d/usno
