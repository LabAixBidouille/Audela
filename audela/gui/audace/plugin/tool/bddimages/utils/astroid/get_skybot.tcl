# -- Procedure 
# radius   = rayon du FOV en arcsec
proc get_skybot { dateobs ra dec radius uaicode } {

   global voconf
   global skybot_list
   global skybot_list2

   set log 0

   set voconf(date_image)          $dateobs
   set voconf(centre_ad_image)     $ra
   set voconf(centre_dec_image)    $dec
   set voconf(observer)            [string trim $uaicode]
   set voconf(taille_champ_calcul) $radius
   set voconf(filter)              120
   set voconf(objfilter)           "110"

   #"TAROT CHILI"  809 
   #"TAROT CALERN" 910 

   # -- check availability of skybot slice
   set uptodate 0
   # dateobs format : 2008-01-01T03:48:04.64
   # skybot epoch format : 2008-01-01 03:48:04
   set epoch [regsub {T} $voconf(date_image) " "]
   set epoch [regsub {\..*} $epoch ""]
    # gren_info "    SKYBOT-STATUS for epoch $epoch \n"
   set status [vo_skybotstatus "text" "$epoch"]
     #gren_info "    MSG-SKYBOT-STATUS : <$status> \n"
   if {[lindex $status 1] >= 1} then {
    set stats [lindex $status 5]
    set lines [split $stats ";"]
    if { [llength $lines] == 2 } {
     if {[string match -nocase "*uptodate*" "[lindex $lines 1]"]} { set uptodate 1 }
    }
   }
   if { ! $uptodate } {
      #gren_info "SKYBOT-STATUS not up to date"
      # TODO if not up to date skip image
   }

   set skybot_answered 0
   set no_answer 0
   while { ! $skybot_answered } {
   
      #gren_info  "[clock format [clock seconds] -format %Y-%m-%dT%H:%M:%S -gmt 1]: Appel au conesearch"
      #gren_info "$voconf(date_image) $voconf(centre_ad_image) $voconf(centre_dec_image) $voconf(taille_champ_calcul) $voconf(observer)\n"

      set err [ catch { vo_skybotconesearch $voconf(date_image) $voconf(centre_ad_image)   \
                                            $voconf(centre_dec_image) $voconf(taille_champ_calcul) \
                                            "votable" "object" $voconf(observer) $voconf(filter) $voconf(objfilter) } msg ]

      if {$err} {
         gren_info "get_skybot: ERREUR 7"
         gren_info "get_skybot:        NUM : <$err>" 
         gren_info "get_skybot:        MSG : <$msg>"
         incr no_answer
         if {$no_answer>10} {
            break
         }
      } else {

         if { $msg eq "failed" } {
            gren_info "solarsystemprocess->get_skybot: failed"
         } else {
            set skybot_answered 1
            set err [ catch { ::dom::parse $msg } votable ]
            if { $err } {
               gren_info "  => Erreur d'analyse de la votable Skybot"
               set skybot_answered 0
               after 10000
            }
         }

      }

   }

   set err [ catch { ::dom::parse $msg } votable ]
   if { $err } {
      gren_info "  => Erreur d'analyse de la votable Skybot"
      after 10000
   }

   # -- Parse the votable and extract solar system objects from the parsed votable
   set skybot_fields {}
   foreach n [::dom::selectNode $votable {descendant::FIELD/attribute::ID}] {
      lappend skybot_fields "[::dom::node stringValue $n]"
   }
   set voconf(fields) $skybot_fields

   set skybot_list2 {}
   set common_fields [list ra dec poserr mag magerr]
   set fields [list [list "SKYBOT" $common_fields $skybot_fields] ] 

   set cpt 0
   foreach tr [::dom::selectNode $votable {descendant::TR}] {
      set row {}
      foreach td [::dom::selectNode $tr {descendant::TD/text()}] {
         lappend row [::dom::node stringValue $td]
      }
      # Conversion RA,DEC sexadec -> dec en degres
      set ra_d [expr [mc_angle2deg [lindex $row 2]] * 15.0]
      set dec_d [lindex [mc_angle2deg [lindex $row 3]] 0]
      set row [lreplace $row 2 3 $ra_d $dec_d]
      
      # Data pour le champ common
      set sra [lindex $row 2]
      set sdec [lindex $row 3]
      set sradialerrpos [expr abs([lindex $row 6])]
      set srmag [lindex $row 5]
      set srmagerr 1
      set common [list $sra $sdec $sradialerrpos $srmag $srmagerr ]
      
      set row [list [list "SKYBOT" $common $row ] ]
      lappend skybot_list2 $row
      incr cpt
   }
   
   set skybot_list2 [list $fields $skybot_list2]
#gren_erreur "$skybot_list2\n"

   ::dom::destroy $votable

   if {$cpt == 0} {
      return -1
   } else {
      if {$log} { gren_info " SKYBOT obecjts: $skybot_list2\n" }
      return $skybot_list2
   }

}
