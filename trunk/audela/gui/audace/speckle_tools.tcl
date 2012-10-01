#
# Fichier : speckle_tools.tcl
# Description : Tools for speckle imagery
# Auteur : Alain KLOTZ
# Mise à jour $Id: speckle_tools.tcl 8176 2012-03-09 18:23:26Z robertdelmas  $
#
# source "$audace(rep_install)/gui/audace/speckle_tools.tcl"
#
# --- Return the number of frames in the .avi file
# speckle_avi2intercor dzeta_boo_test_ralenti_7_fois.avi fsum 
# # 1000
#
# --- Return the intercorrelation image from the .avi file
# speckle_avi2intercor dzeta_boo_test_ralenti_7_fois.avi fsum 10
#
# --- Return the highpass of the intercorrelation image to help the analysis
# speckle_intercorhighpass fsum 8
#
# --- Return the module of the FFT of the intercorrelation image to help the analysis
# speckle_intercorfft fsum
#
# TODO
# speckle_calibwcs, speckle_acq2avi, speckle_distrho
# plus VO tools that interract with the databases

proc speckle_acq2avi { nb_images filename_avi } {
	global audace
	set path $audace(rep_images)
	set bufno $audace(bufNo)
	# --- open the .avi file	
	::avi::create ::av4l_tools_avi::avispeckle1
	#
	# TODO...
	#
	# --- close the .avi file
	::av4l_tools_avi::avispeckle1 close
	rename ::av4l_tools_avi::avispeckle1 ""
}

proc speckle_avi2intercor { filename_avi filename_intercor {nb_images 0} {first_index 1} {verbose 2} } {
	global audace
	set path $audace(rep_images)
	set bufno $audace(bufNo)
	# --- open the .avi file	
	::avi::create ::av4l_tools_avi::avispeckle1
	set fullfileavi "${path}/${filename_avi}"
	set err [catch {::av4l_tools_avi::avispeckle1 load $fullfileavi} msg]
	if {$err==1} {
		# --- close the .avi file
		::av4l_tools_avi::avispeckle1 close
		rename ::av4l_tools_avi::avispeckle1 ""
		# --- error message
		if {[file exists $fullfileavi]==0} {
			append msg " The file $fullfileavi does not exists"
		}
		error "${msg}"
	}
	# --- set the starting and ending indexes
	set kdeb [expr int($first_index)]
	set nb_frames [::av4l_tools_avi::avispeckle1 get_nb_frames]	
	if {$kdeb<0} { set kdeb 1 }
	if {$nb_images==0} {
		# --- close the .avi file
		::av4l_tools_avi::avispeckle1 close
		rename ::av4l_tools_avi::avispeckle1 ""
		# --- return the number of frames
		return $kfin
	} else {
		set kfin [expr $nb_images-$kdeb+1]
	}
	if {$kfin>$nb_frames} {
		set kfin $nb_frames
	}
	# --- loop over each selected image of the .avi file
	set t0 [clock seconds]
	for {set k $kdeb} {$k<=$kfin} {incr k} {
		if {$verbose>=2} {
			console::affiche_resultat "Image $k / $kfin\n"
		}
		# --- load the next .avi image
		::av4l_tools_avi::avispeckle1 next
		if {$verbose>=1} {
			update
		}
		# --- intercorrelation
		buf${bufno} bitpix float
		saveima o
		prod o 1
		saveima o2
		icorr2d ${path}/o2[buf${bufno} extension] ${path}/o[buf${bufno} extension] ${path}/f[buf${bufno} extension]
		buf${bufno} load ${path}/f[buf${bufno} extension]
		if {$k==$kdeb} {
			saveima fsum
		} else {
			buf${bufno} add ${path}/fsum[buf${bufno} extension] 0
			saveima fsum		
		}
	}
	# --- close the .avi file
	::av4l_tools_avi::avispeckle1 close
	rename ::av4l_tools_avi::avispeckle1 ""
	# --- set the outputs
	set dt [expr [clock seconds]-$t0]
	if {$verbose>=2} {
		console::affiche_resultat "Processed in $dt seconds\n"
	}
	if {$verbose>=1} {
		loadima fsum
	} else {
		buf${bufno} load ${path}/fsum[buf${bufno} extension]
	}
	saveima $filename_intercor
}

proc speckle_intercorhighpass { filename_intercor {highpass_threshold 10} } {
	global audace
	set path $audace(rep_images)
	set bufno $audace(bufNo)
	set rc $highpass_threshold
	if {$rc<=0} {
		loadima $filename_intercor
		return ""
	}
	# --- FFT on the intercollation image
	dft2d ${path}/${filename_intercor}[buf${bufno} extension] ${path}/famp[buf${bufno} extension] ${path}/fpha[buf${bufno} extension]
	# --- set the limits of the high pass gaussian filter
	loadima famp
	set naxis1 [buf${bufno} getpixelswidth]
	set naxis2 [buf${bufno} getpixelsheight]
	set xc [expr $naxis1/2+1]
	set yc [expr $naxis2/2+1]
	set rcx [expr 1.*$rc]
	set rcy [expr 1.*$rc*$naxis2/$naxis1]
	set rc2 [expr $rcx*$rcy]
	set etenduex [expr $rcx*5.]
	set etenduey [expr $rcy*5.]
	set etenduex2 [expr $etenduex*$etenduex]
	set etenduey2 [expr $etenduey*$etenduey]
	set etendue2 [expr $etenduex2+$etenduey2]
	set x1 [expr int($xc-$etenduex)] ; if {$x1<1} {set x1 1}
	set x2 [expr int($xc+$etenduex)] ; if {$x2>$naxis1} {set x2 $naxis1}
	set y1 [expr int($yc-$etenduey)] ; if {$y1<1} {set y1 1}
	set y2 [expr int($yc+$etenduey)] ; if {$y2>$naxis2} {set y2 $naxis2}
	# --- filtering in the Fourier domain
	set fs {famp fpha}
	foreach f $fs {
		loadima $f
		for {set x $x1} {$x<=$x2} {incr x} {
			set dx [expr $x-$xc]
			set dx2 [expr $dx*$dx]
			if {$dx2>$etenduex2} {
				continue
			}
			for {set y $y1} {$y<=$y2} {incr y} {
				set dy [expr $y-$yc]
				set dy2 [expr $dy*$dy]
				if {$dy2>$etenduey2} {
					continue
				}
				set r2 [expr $dx2+$dy2]
				if {$r2<$etendue2} {
					set filtre [expr 1.-exp(-0.5*$r2/$rc2)]
					set val [lindex [buf${bufno} getpix [list $x $y] ] 1]
					set newval [expr $val*$filtre]
					buf${bufno} setpix [list $x $y] $newval
				}
			}
		}
		saveima ${f}f
	}
	# --- inverse FFT	
	idft2d ${path}/fampf[buf${bufno} extension] ${path}/fphaf[buf${bufno} extension] ${path}/fsumf[buf${bufno} extension]
	loadima fsumf
}

proc speckle_intercorfft { filename_intercor } {
	global audace
	set path $audace(rep_images)
	set bufno $audace(bufNo)
	# --- FFT on the intercollation image
	dft2d ${path}/${filename_intercor}[buf${bufno} extension] ${path}/famp[buf${bufno} extension] ${path}/fpha[buf${bufno} extension]
	# --- return the amplitude image
	loadima famp
}
