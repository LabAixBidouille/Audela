   proc ::t1m_roue_a_filtre::init_roue { } {

      # Col : 0 Actif/NonActif
      # Col : 1 Nom court
      # Col : 2 Nom long
      # Col : 3 nbimage
      # Col : 4 sens de debut nuit
      # Col : 5 largeur
      # Col : 6 centre
      # Col : 7 offset exptime
      #                           0  1          2        3   4   5     6     7
      set ::t1m_roue_a_filtre::private(filtre,1) [list 0  "L"        "Large"  0   9   0.1   0.2   0.]
      set ::t1m_roue_a_filtre::private(filtre,2) [list 0  "B"        "B"      0   8   0.1   0.2   0.]
      set ::t1m_roue_a_filtre::private(filtre,3) [list 0  "V"        "V"      0   7   0.1   0.2   0.]
      set ::t1m_roue_a_filtre::private(filtre,4) [list 0  "R"        "R"      0   5   0.1   0.2   0.]
      set ::t1m_roue_a_filtre::private(filtre,5) [list 0  "up_sloan" "Us"     0   6   0.1   0.2   0.]
      set ::t1m_roue_a_filtre::private(filtre,6) [list 0  "gp_sloan" "Gs"     0   4   0.1   0.2   0.]
      set ::t1m_roue_a_filtre::private(filtre,7) [list 0  "rp_sloan" "Rs"     0   2   0.1   0.2   0.]
      set ::t1m_roue_a_filtre::private(filtre,8) [list 0  "ip_sloan" "Is"     0   3   0.1   0.2   0.]
      set ::t1m_roue_a_filtre::private(filtre,9) [list 0  "zp_sloan" "Zs"     0   1   0.1   0.2   0.]

   }
