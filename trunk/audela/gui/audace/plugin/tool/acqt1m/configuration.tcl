   proc init { } {
      variable private
      set private(filtre,1) [list 0  "L"        "Large"  0   9   0.1   0.2   0.]
      set private(filtre,2) [list 0  "B"        "B"      0   8   0.1   0.2   0.]
      set private(filtre,3) [list 0  "V"        "V"      0   7   0.1   0.2   0.]
      set private(filtre,4) [list 0  "R"        "R"      0   5   0.1   0.2   0.]
      set private(filtre,5) [list 0  "up_sloan" "Us"     0   6   0.1   0.2   0.]
      set private(filtre,6) [list 0  "gp_sloan" "Gs"     0   4   0.1   0.2   0.]
      set private(filtre,7) [list 0  "rp_sloan" "Rs"     0   2   0.1   0.2   0.]
      set private(filtre,8) [list 0  "ip_sloan" "Is"     0   3   0.1   0.2   0.]
      set private(filtre,9) [list 0  "zp_sloan" "Zs"     0   1   0.1   0.2   0.]
   }
